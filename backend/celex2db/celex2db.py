# import celex2db.writeJSON as WriteJSON
# import celex2db.writeFirebase as WriteFirebase

import celex
import writeSQLite

# frequency of status output
STEP_SIZE = 1000

# open celex2 file (gpw.cd)
gpwFile = open("./celex2/german/gpw/gpw.cd")

# create model
dictionary = celex.Dictionary()

# parse celex2 file
print("--- parsing celex2 file ---")
maxLines = 1000000
current = 0
numParsed = 0
numErrors = 0
while True:
    line = gpwFile.readline()
    if not line:
        break

    if current > 0 and current % STEP_SIZE == 0:
        print("parsed " + str(numParsed) + " words...", "ERRORS:", numErrors)

    current = current + 1

    components = line.split('\\')
    if len(components) < 5:
        # phonetic pattern should be the 5th part
        continue

    text = components[1]
    phon = components[4]

    if not dictionary.add_word(text, phon):
        numErrors = numErrors + 1

    # read only max lines
    numParsed = numParsed + 1
    if current >= maxLines:
        break

print("parsed " + str(numParsed) + " words...", "ERRORS:", numErrors)

# write to json file
# WriteJSON.write_json(dictionary, STEP_SIZE)

# write to firebase
# WriteFirebase.write_firebase(dictionary, STEP_SIZE)

# write to SQLite database
writeSQLite.write_sqlite(dictionary, STEP_SIZE)

print("--- DONE ---")
