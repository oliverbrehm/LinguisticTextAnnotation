import sqlite3
import nltk # natural language toolkit
import pyphen

DATABASE_PATH = '../db/celex.db'


class Word:
    def __init__(self, text, stress_pattern, hyphenation):
        self.text = text
        self.stress_pattern = stress_pattern
        self.hyphenation = hyphenation

    def to_string(self):
        return self.text + ", " + self.stress_pattern + ", " + self.hyphenation


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

    def add_word(self, word, stress_pattern, hyphenation):
        # create/open database
        db = sqlite3.connect(DATABASE_PATH)
        cursor = db.cursor()

        # check if word already in DB
        row_exists_format = 'SELECT * FROM word WHERE (text="{text}")'
        row_exists_command = row_exists_format.format(text=word)
        cursor.execute(row_exists_command)
        row = cursor.fetchone()
        if row is not None:
            return False

        # insert word
        insert_format = """
                INSERT INTO word (text, stress_pattern, hyphenation)
                VALUES ("{text}", "{stress_pattern}", "{hyphenation}");            
            """
        insert_command = insert_format.format(text=word.text, stress_pattern=word.stress_pattern,
                                              hyphenation=word.hyphenation)
        self.cursor.execute(insert_command)

        self.db.commit()

    def query_word(self, word, user_service, user):
        # create/open database
        db = sqlite3.connect(DATABASE_PATH)
        cursor = db.cursor()

        # handle umlaut
        query_text = word.replace("ä", "ae")\
            .replace("ö", "oe")\
            .replace("ü", "ue")\
            .replace("Ä", "Ae")\
            .replace("Ö", "Oe")\
            .replace("Ü", "Ue")\
            .replace("ß", "ss")

        print('user2: ', user)

        # first query user words (local preferences)
        if user_service and user:
            print('budums: ', query_text)

            word = user_service.get_word(user, query_text)

            # try lower case
            if word is None:
                word = user_service.get_word(user, query_text.lower())

            if word is not None:
                return word

        # if not found in user database, search the global word database
        query = 'SELECT * FROM word WHERE (text="{text}")'.format(text=query_text)
        cursor.execute(query)
        entry = cursor.fetchone()

        if entry is None or len(entry) is not 3:
            # try lower case
            query = 'SELECT * FROM word WHERE (text="{text}")'.format(text=query_text.lower())
            cursor.execute(query)
            entry = cursor.fetchone()

            if entry is None or len(entry) is not 3:
                return None

        response = {
            'stress_pattern': entry[1],
            'hyphenation': entry[2]# self.pyphen_dict.inserted(word) # TODO resolve question: hyphenation in database or in backend?
        }

        return response

    def query_text(self, text, user_service, user):
        if not text:
            return None
        print('user1: ', user)

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
