import sqlite3

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
        pass

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

    def query_word(self, word):
        # create/open database
        db = sqlite3.connect(DATABASE_PATH)
        cursor = db.cursor()

        query_format = 'SELECT * FROM word WHERE (text="{text}")'
        query_command = query_format.format(text=word)
        cursor.execute(query_command)
        entry = cursor.fetchone()

        if entry is None or len(entry) is not 3:
            return None

        response = {
            'text': entry[0],
            'stress_pattern': entry[1],
            'hyphenation': entry[2]
        }

        return response

    def query_text(self, text):
        return ""