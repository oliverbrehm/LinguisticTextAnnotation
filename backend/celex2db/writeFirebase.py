from firebase import firebase


def write_firebase(dictionary, step_size):
    print("--- connecting to firebase database ---")

    database = firebase.FirebaseApplication('https://linguistictextannotation.firebaseio.com', None)

    counter = 0

    for item in dictionary.words:
        database.post(url='/words', data=item.to_json(), headers={'print': 'silent'})
        counter = counter + 1
        if counter % step_size == 0:
            print("Written " + str(counter) + " words to firebase...")

    print("Finished: Written " + str(counter) + " words to firebase in total.")