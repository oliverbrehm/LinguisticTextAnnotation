from firebase import firebase
import time

def format_duration(seconds):
    return str(int(round(seconds / 3600))) \
           + ":" + str(int(round(seconds / 60)) % 60) \
           + ":" + str(seconds % 60)

def write_firebase(dictionary, step_size):
    print("--- connecting to firebase database ---")

    database = firebase.FirebaseApplication('https://linguistictextannotation.firebaseio.com', None)

    counter = 0

    t = time.time()
    numWords = len(dictionary.words)

    for item in dictionary.words:
        database.post(url='/words', data=item.to_json(), headers={'print': 'silent'})
        counter = counter + 1
        if counter % step_size == 0:
            print("Written " + str(counter) + " words to firebase...")
            dt = time.time() - t # in seconds
            time_left = dt * (numWords) / step_size
            print("~ time left: ", format_duration(time_left))
            t = time.time()


    print("Finished: Written " + str(counter) + " words to firebase in total.")