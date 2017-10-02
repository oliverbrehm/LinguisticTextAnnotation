import sys
import os

import sqlite3

from celex2 import Dictionary, Word

DATABASE_PATH = '../db/celex.db'

# frequency of status output
STEP_SIZE = 1000

# open celex2 file (gpw.cd)
gpwFile = open("./celex2/german/gpw/gpw.cd")

# create model
dictionary = Dictionary()

# parse celex2 file
print("--- parsing celex2 file ---")
maxLines = 1000000
current = 0
numParsed = 0
while True:
    line = gpwFile.readline()
    if not line:
        break

    if current > 0 and current % STEP_SIZE == 0:
        print("parsed " + str(numParsed) + " words...")

    current = current + 1

    components = line.split('\\')
    if len(components) < 5:
        # phonetic pattern should be the 5th part
        continue

    text = components[1]
    phon = components[4]

    dictionary.add_word(text, phon)

    # read only max lines
    numParsed = numParsed + 1
    if current >= maxLines:
        break

print("parsed " + str(numParsed) + " words...")

print("--- connecting to database ---")

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

    if current > 0 and current % STEP_SIZE == 0:
        db.commit()
        print("added to database: " + str(numAdded))
        print("skipped: " + str(numSkipped))

    current = current + 1

    # check if word already in DB
    rowExistsFormat = 'SELECT * FROM word WHERE (text="{text}")'
    rowExistsCommand = rowExistsFormat.format(text=word.text)
    cursor.execute(rowExistsCommand)
    row = cursor.fetchone()
    if row is not None:
        numSkipped = numSkipped + 1
        continue

    # insert word
    insertFormat = """
        INSERT INTO word (text, stress_pattern, hyphenation)
        VALUES ("{text}", "{stress_pattern}", "{hyphenation}");            
    """
    insertCommand = insertFormat.format(text=word.text, stress_pattern=word.stress_pattern, hyphenation=word.hyphenation)
    cursor.execute(insertCommand)

    numAdded = numAdded + 1

db.commit()

print("added to database: " + str(numAdded))
print("skipped: " + str(numSkipped))

print("--- DONE ---")
