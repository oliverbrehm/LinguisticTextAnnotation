import sqlite3
import pyphen
import requests
import spacy

from datetime import datetime

import xml.etree.ElementTree as ET

import sqlalchemy
from sqlalchemy.orm import relationship

from Database import Base as Base

TOKENS_TO_IGNORE = ['X', 'PUNCT', 'NUM', 'SPACE']


class Segmentation:
    def __init__(self, text, origin, source, hyphenation, stress_pattern):
        self.text = text
        self.origin = origin
        self.source = source
        self.hyphenation = hyphenation
        self.stress_pattern = stress_pattern

    def json(self):
        return {
            "text": self.text,
            "origin": self.origin,
            "source": self.source,
            "hyphenation": self.hyphenation,
            "stress_pattern": self.stress_pattern
        }


class Word(Base):

    __tablename__ = 'word'

    text = sqlalchemy.Column(sqlalchemy.String(128), primary_key=True)
    pos = sqlalchemy.Column(sqlalchemy.String(8), primary_key=True)
    stress_pattern = sqlalchemy.Column(sqlalchemy.String(32))
    hyphenation = sqlalchemy.Column(sqlalchemy.String(128))
    lemma = sqlalchemy.Column(sqlalchemy.String(128))

    def __init__(self, text, stress_pattern, hyphenation, lemma, pos):
        self.text = text
        self.stress_pattern = stress_pattern
        self.hyphenation = hyphenation
        self.pos = pos
        self.lemma = lemma

    def __str__(self):
        return self.text + ", " \
               + self.stress_pattern \
               + ", " + self.hyphenation \
               + ", " + self.pos

    def json(self):
        return {
            "text": self.text,
            "stress_pattern": self.stress_pattern,
            "hyphenation": self.hyphenation,
            "lemma": self.lemma,
            "pos": self.pos
        }


class AddedEntry(Base):
    __tablename__ = 'added_entry'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    time_added = sqlalchemy.Column(sqlalchemy.TIMESTAMP, default=datetime.utcnow, nullable=False)

    word_text = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('word.text'))
    word = relationship(Word)

    def json(self):
        return {
            'id': self.id,
            'word': self.word_text,
            'time_added': str(self.time_added)
        }


class DictionaryService:
    def __init__(self, database):
        self.database = database

        # init pyphen
        language = 'de_DE'

        # init spacy
        self.nlp = spacy.load('de')

        if language in pyphen.LANGUAGES:
            self.pyphen_dict = pyphen.Pyphen(lang=language)
        else:
            print('language not found.')
            self.pyphen_dict = pyphen.Pyphen()

        pyphen.language_fallback(language + '_variant1')

    @staticmethod
    def preprocess_entry(entry):
        return entry.lower() \
            .replace("ä", "ae") \
            .replace("ö", "oe") \
            .replace("ü", "ue") \
            .replace("ß", "ss")

    def add_word(self, word, stress_pattern, hyphenation, lemma, pos, bulk_add=False):
        # insert word
        db_word = Word(text=word, stress_pattern=stress_pattern, hyphenation=hyphenation, lemma=lemma, pos=pos)

        try:
            self.database.session.add(db_word)
            self.database.session.commit()
        except sqlite3.IntegrityError:
            self.database.session.rollback()

            print('Word ', word, 'already in Database.')
            return None
        except Exception as e:
            print('Error adding word "' + word + '" to Database.')
            #if not bulk_add:
            self.database.session.rollback()
            return None

        if bulk_add:
            # do not create added entries for bulk adding (creating the database)
            return db_word

        # create added entry
        entry = AddedEntry(word=db_word)

        try:
            self.database.session.add(entry)
            self.database.session.commit()
        except Exception as e:
            print('error adding AddedEntry')
            print(e)
            self.database.session.rollback()

        return db_word

    def list_added_entries(self):
        entries = self.database.session.query(AddedEntry).all()
        result = []

        for e in entries:
            result.append(e.json())

        return result

    def query_word(self, word, pos, user_service, user):
        # handle umlaut
        query_text = DictionaryService.preprocess_entry(word)

        # first query user words (local preferences)
        if user_service and user:
            word = user_service.get_word(user, query_text, pos)

            if word is not None:
                return word

        # if not found in user database, search the global word database
        candidates = self.database.session.query(Word).filter(Word.text == query_text).all()

        # look for word with the right pos tag (e.g. noun/verb with same text, 'Hacken'/'hacken')
        word = None
        if len(candidates) > 0:
            word = candidates[0]

            for w in candidates:
                if w.pos.lower() == pos.lower():
                    word = w
                    break

        if word is None:
            return None

        return word.json()

    def query_text(self, text, user_service, user):
        if not text:
            return None

        analyzed = []

        doc = self.nlp(text)

        for token in doc:
            word = token.text
            pos = token.pos_
            lemma = token.lemma_

            if '\n' in word:
                # line breaks
                entry = self._lookup_token(word, pos, lemma, user, user_service)
                entry['type'] = 'linebreak'
                analyzed.append(entry)
            elif '-' in word:
                # if double word (containing hyphen)
                composite_text = word.replace('-', ' ')
                composite_tokens = self.nlp(composite_text)

                for i in range(len(composite_tokens)):
                    composite_token = composite_tokens[i]

                    word = composite_token.text
                    pos = composite_token.pos_
                    lemma = composite_token.lemma_

                    entry = self._lookup_token(word, pos, lemma, user, user_service)
                    analyzed.append(entry)

                    if i is not len(composite_tokens) - 1:
                        # in between double word, add hyphen as token
                        entry = self._hyphen_token()
                        analyzed.append(entry)
            else:
                # normal word (without hyphen)
                entry = self._lookup_token(word, pos, lemma, user, user_service)
                analyzed.append(entry)

        return analyzed

    def _lookup_token(self, word, pos, lemma, user, user_service):
        entry = {
            'text': word,
        }

        # don't analyze special tokens
        if len(word) < 2 or pos in TOKENS_TO_IGNORE:
            entry['type'] = 'ignored'

        else:
            annotated = self.query_word(word, pos, user_service, user)
            if annotated is None:
                entry['type'] = 'not_found'
            else:
                entry['type'] = 'annotated_word'

                # if pos or lemma not in word database, use defaults from spacy parser
                if not annotated['pos']:
                    annotated['pos'] = pos
                if not annotated['lemma']:
                    annotated['lemma'] = lemma

                entry['annotation'] = annotated

        return entry

    def _hyphen_token(self):
        return {
            'text': '-',
            'pos': 'PUNCT',
            'lemma': '-',
            'type': 'ignored'
        }

    def query_segmentation(self, word):
        segmentations = []

        # MARY TTS
        url = 'http://mary.dfki.de:59125/process?INPUT_TEXT=' + word + \
              '&INPUT_TYPE=TEXT&OUTPUT_TYPE=ACOUSTPARAMS&LOCALE=de'

        try:
            response = requests.get(url, timeout=2)  # 2 second timeout

            if response:
                print(response)

                stress_pattern, hyphenation = self.parse_mary_xml(word, response.text)

                if stress_pattern and len(stress_pattern) > 0:
                    if "1" not in stress_pattern:
                        # contains no stress, default use first syllable
                        stress_pattern[0] = '1' + stress_pattern[1:]
                    segmentation_mary = Segmentation(word, "MARY TTS", "Source: MARY TTS", hyphenation, stress_pattern)
                    segmentations.append(segmentation_mary.json())
        except requests.exceptions.ReadTimeout:
            print('Timout querying MARY TTS.')
        except Exception:
            print('Error querying MARY TTS.')

        # pyphen: no stress pattern available, default first syllable stressed
        hyphenation = self.pyphen_dict.inserted(word)
        syllables = hyphenation.split("-")
        stress_pattern = "1"
        for s in range(1, len(syllables)):
            stress_pattern = stress_pattern + "0"

        segmentation_pyphen = Segmentation(word, "Pyphen", "Source: Pyphen", hyphenation, stress_pattern)
        segmentations.append(segmentation_pyphen.json())

        return segmentations

    def parse_mary_xml(self, queryWord, xmlText):
        root = ET.fromstring(xmlText)

        stress_pattern = ""
        hyphenation = ""

        if not root:
            print('root not found')
            return "", ""

        wordElement = root[0][0][0][0]  # root: maryxml[0] -> p[0] -> s[0] -> phrase[0] -> t (== Word)

        if not wordElement:
            print('word not found')
            return "", ""

        for syllable in wordElement:
            stressed = syllable.get('stress')
            if stressed == "1":
                stress_pattern = stress_pattern + "1"
            else:
                stress_pattern = stress_pattern + "0"

            # use pyphen hyphenation and hope it matches
            hyphenation = self.pyphen_dict.inserted(queryWord)

        return stress_pattern, hyphenation
