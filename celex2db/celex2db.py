import sys
import os

import sqlite3

from celex2 import Celex2, Word

# script arguments


# open celex2 file (gpw.cd)
gpwFile = open("./celex2/german/gpw/gpw.cd")

# create model
celex = Celex2()

# parse celex2 file
print("--- parsing celex2 file ---")
maxLines = 10
current = 0
while True:
    line = gpwFile.readline()
    if not line:
        break

    components = line.split('\\')
    if len(components) < 5:
        # phonetic pattern should be the 5th part
        continue

    text = components[1]
    phon = components[4]
    # syllables are split by - delimiter
    parts = phon.split('-')

    stressed = -1
    syllables = []
    for i, p in enumerate(parts):
        syllable = p
        if len(p) > 0 and p[0] == '\'':
            # stressed syllables have ' annotation as first char
            syllable = p[1:] # remove ' annotation
            stressed = i

        syllables.append(syllable)

    celex.add_word(text, syllables, stressed)

    # read only max lines
    current = current + 1
    if current > maxLines:
        break


print("--- connecting to database ---")

# create/open database
db = sqlite3.connect('celex.db')
cursor = db.cursor()

# create table if not existing
# TODO check existing
createTableCommand = """
    CREATE TABLE word (
        text VARCHAR(256),
        pattern VARCHAR(256)
        );
"""
cursor.execute(createTableCommand)
db.commit()


print("--- writing database entries ---")

# write model to db
for word in celex.words:

    # TODO check word already in DB

    insertFormat = """
        INSERT INTO word (text, pattern)
        VALUES ("{text}", "{pattern}");            
    """

    insertCommand = insertFormat.format(text = word.text, pattern = word.pattern())
    cursor.execute(insertCommand)
    db.commit()

print("--- DONE ---")
