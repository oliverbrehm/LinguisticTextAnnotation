import json


def write_json(dictionary, step_size):
    words = {}
    num_words = 0
    for word in dictionary.words:
        words[word.text] = word.to_json()
        num_words = num_words + 1
        if num_words % step_size == 0:
            print("Written " + str(num_words) + " words to json...")

    data = {'words': words}

    with open('../db/words.json', 'w') as file:
        json.dump(data, file)

    print("-------\nWritten " + str(num_words) + " words to json file.")
