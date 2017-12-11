import sys, os

sys.path.append(os.path.relpath('../API'))

import API.DictionaryService
from Database import Database

DB_WORDS_PATH = 'sqlite:///../db/words.db'

wordsDatabase = Database(DB_WORDS_PATH)


def write_sqlite(dictionary, step_size):
    print("--- connecting to database ---")

    dictionary_service = API.DictionaryService.DictionaryService(wordsDatabase)

    print("--- writing database entries ---")

    # write model to db
    num_added = 0
    num_skipped = 0
    current = 0

    for word in dictionary.words:

        if current > 0 and current % step_size == 0:
            #dictionary_service.commit()
            print("added to database: " + str(num_added))
            print("skipped: " + str(num_skipped))

        current = current + 1

        if dictionary_service.add_word(word.text, word.stress_pattern, word.hyphenation, word.lemma, word.pos, bulk_add=True):
            num_added = num_added + 1
        else:
            num_skipped = num_skipped + 1

    #dictionary_service.commit()
    print("added to database: " + str(num_added))
    print("skipped: " + str(num_skipped))
