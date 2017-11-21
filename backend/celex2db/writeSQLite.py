import API.DictionaryService

DATABASE_PATH = '../db/celex.db'

def write_sqlite(dictionary, step_size):
    print("--- connecting to database ---")

    dictionary_service = API.DictionaryService.DictionaryService()

    print("--- writing database entries ---")

    # write model to db
    num_added = 0
    num_skipped = 0
    current = 0

    for word in dictionary.words:

        if current > 0 and current % step_size == 0:
            print("added to database: " + str(num_added))
            print("skipped: " + str(num_skipped))

        current = current + 1

        if dictionary_service.add_word(word.text, word.stress_pattern, word.hyphenation, bulk_add=True):
            num_added = num_added + 1
        else:
            num_skipped = num_skipped + 1

    print("added to database: " + str(num_added))
    print("skipped: " + str(num_skipped))
