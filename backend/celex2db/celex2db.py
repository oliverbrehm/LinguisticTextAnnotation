# import celex2db.writeJSON as WriteJSON
# import celex2db.writeFirebase as WriteFirebase

import celex
import writeSQLite

# frequency of status output
STEP_SIZE = 1000
MAX_LINES_LEMMAS = 1000000
MAX_LINES_WORDLIST = 1000000

# create model
dictionary = celex.CelexDictionary()

# parse lemma file
print("--- parsing celex2 lemmas (gol) ---")
dictionary.parse_lemmas(MAX_LINES_LEMMAS, STEP_SIZE)

# parse word list
print("--- parsing celex2 word list (gpw, gow) ---")
dictionary.parse_words(MAX_LINES_WORDLIST, STEP_SIZE)


# write to json file
# WriteJSON.write_json(dictionary, STEP_SIZE)

# write to firebase
# WriteFirebase.write_firebase(dictionary, STEP_SIZE)

# write to SQLite database
writeSQLite.write_sqlite(dictionary, STEP_SIZE)

print("--- DONE ---")
