import sqlite3
import nltk # natural language toolkit
import pyphen

import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import sessionmaker

DATABASE_PATH = 'sqlite:///../db/celex.db'

Base = declarative_base()


class Word(Base):

    __tablename__ = 'word'

    text = sqlalchemy.Column(sqlalchemy.String(128), primary_key=True)
    stress_pattern = sqlalchemy.Column(sqlalchemy.String(32))
    hyphenation = sqlalchemy.Column(sqlalchemy.String(128))

    def json(self):
        return {
            "stress_pattern": self.stress_pattern,
            "hyphenation": self.hyphenation
        }


class DictionaryService:
    def __init__(self):
        nltk.download('punkt')
        nltk.download('averaged_perceptron_tagger')

        # init pyphen
        language = 'de_DE'

        if language in pyphen.LANGUAGES:
            self.pyphen_dict = pyphen.Pyphen(lang=language)
        else:
            print('language not found.')
            self.pyphen_dict = pyphen.Pyphen()

        pyphen.language_fallback(language + '_variant1')

        # init sqlalchemy
        self.engine = sqlalchemy.create_engine(DATABASE_PATH)
        Base.metadata.bind = self.engine
        Base.metadata.create_all(self.engine)
        DBSession = sessionmaker(bind=self.engine)
        self.session = DBSession()

    def add_word(self, word, stress_pattern, hyphenation):
        # insert word
        user_word = Word(text=word, stress_pattern=stress_pattern, hyphenation=hyphenation)

        try:
            self.session.add(user_word)
            self.session.commit()
        except:
            self.session.rollback()
            return False

        return True

    def query_word(self, word, user_service, user):
        # handle umlaut
        query_text = word.replace("ä", "ae")\
            .replace("ö", "oe")\
            .replace("ü", "ue")\
            .replace("Ä", "Ae")\
            .replace("Ö", "Oe")\
            .replace("Ü", "Ue")\
            .replace("ß", "ss")

        # first query user words (local preferences)
        if user_service and user:
            word = user_service.get_word(user, query_text)

            # try lower case
            if word is None:
                word = user_service.get_word(user, query_text.lower())

            if word is not None:
                return word

        # if not found in user database, search the global word database
        word = self.session.query(Word).filter(Word.text == query_text).first()

        if word is None:
            # try lower case
            word = self.session.query(Word).filter(Word.text == query_text.lower()).first()

        if word is None:
            return None

        return word.json()

    def query_text(self, text, user_service, user):
        if not text:
            return None

        # TODO german language?
        words = nltk.word_tokenize(text)
        taggedWords = nltk.pos_tag(words)

        analyzed = []

        for (word, tag) in taggedWords:
            #print(word, tag); # DEBUG tags

            # don't analyze special tokens
            # part of speech tags: http://www.ims.uni-stuttgart.de/forschung/ressourcen/lexika/TagSets/stts-table.html
            if tag is 'CD':
                analyzed.append({'type': 'number', 'text': word}); continue
            if tag in ['.', ',']:
                analyzed.append({'type': 'punctuation', 'text': word}); continue
            if len(word) < 2 or tag is 'XY' or tag in ["''"]:
                analyzed.append({'type': 'unknown', 'text': word}); continue

            annotated = self.query_word(word, user_service, user)
            if annotated is None:
                analyzed.append({'type': 'not_found', 'text': word})
            else:
                analyzed.append({'type': 'annotated_word', 'text': word, 'annotation': annotated})

        return analyzed

    def query_segmentation(self, word):
        hyphenation = self.pyphen_dict.inserted(word)
        syllables = hyphenation.split("-")

        print(len(syllables))

        # no stress pattern available, mock first syllable stressed
        stress_pattern = "1"
        for s in range(1, len(syllables)):
            stress_pattern = stress_pattern + "0"

        # TODO implement more methods for segmentation (MARY...)
        response = [
            {
                'origin': 'pyphen',
                'hyphenation': hyphenation,
                'stress_pattern': stress_pattern
            }
        ]

        return response

