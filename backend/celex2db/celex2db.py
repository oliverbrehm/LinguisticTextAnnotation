import celex2
import writeSQLite
import writeFirebase

# frequency of status output
STEP_SIZE = 100

# open celex2 file (gpw.cd)
gpwFile = open("./celex2/german/gpw/gpw.cd")

# create model
dictionary = celex2.Dictionary()

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


# write to firebase
writeFirebase.write_firebase(dictionary, STEP_SIZE)

# write to SQLite database
# writeSQLite.write_sqlite(dictionary, STEP_SIZE)

print("--- DONE ---")
