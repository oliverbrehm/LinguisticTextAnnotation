import celex2

import sqlite3

DATABASE_PATH = '../db/celex.db'


def write_sqlite(dictionary, step_size):
    print("--- connecting to SQLite database ---")

    # create/open database
    db = sqlite3.connect(DATABASE_PATH)
    cursor = db.cursor()

    # create table if not existing
    createTableCommand = """
        CREATE TABLE IF NOT EXISTS word (
            text VARCHAR(512),
            stress_pattern VARCHAR(64),
            hyphenation VARCHAR(512)
            );
    """
    cursor.execute(createTableCommand)
    db.commit()

    print("--- writing database entries ---")

    # write model to db
    numAdded = 0
    numSkipped = 0
    current = 0

    for word in dictionary.words:

        if current > 0 and current % step_size == 0:
            db.commit()
            print("added to database: " + str(numAdded))
            print("skipped: " + str(numSkipped))

        current = current + 1

        # TODO this query takes too long as db size increases... workaround?
        '''# check if word already in DB
        rowExistsFormat = 'SELECT * FROM word WHERE (text="{text}")'
        rowExistsCommand = rowExistsFormat.format(text=word.text)
        cursor.execute(rowExistsCommand)
        row = cursor.fetchone()
        if row is not None:
            numSkipped = numSkipped + 1
            continue'''

        # insert word
        insertFormat = """
            INSERT INTO word (text, stress_pattern, hyphenation)
            VALUES ("{text}", "{stress_pattern}", "{hyphenation}");            
        """
        insertCommand = insertFormat.format(text=word.text, stress_pattern=word.stress_pattern,
                                            hyphenation=word.hyphenation)
        cursor.execute(insertCommand)

        numAdded = numAdded + 1

    db.commit()

    print("added to database: " + str(numAdded))
    print("skipped: " + str(numSkipped))
