from DictionaryService import DictionaryService
from UserService import UserService, Authentication
from VerificationService import VerificationService
from Database import Database

import spacy



DB_USERS_PATH = 'sqlite:///../db/user.db'
DB_WORDS_PATH = 'sqlite:///../db/celex.db'

userDatabase = Database(DB_USERS_PATH)
wordsDatabase = Database(DB_WORDS_PATH)

dictionaryService = DictionaryService(wordsDatabase)
verificationService = VerificationService(userDatabase)
userService = UserService(userDatabase)

user = userService.get_user('olibrehm@gmail.com')
print(user.json())

#text = '!@#$%^&*()_Die Metall- und Elektroindustrie schrumpft, statt 32.000 Menschen leben nur noch 17.000 Einwohner dort.'
text = 'Wir haben in den vergangenen Tagen bereits häufiger über ihn berichtet, jetzt ist es Gewissheit: Nach 37 Jahren ist die Regierungszeit von Diktator Robert Mugabe in Simbabwe zu Ende, die Details dazu hat die Süddeutsche Zeitung. Der 93-Jährige hatte zuletzt vergeblich versucht, seine Frau Grace ins Präsidentschaftsamt zu heben, nun soll stattdessen der Anfang November von Mugabe gefeuerte Emmerson Mnangagwa übernehmen. Der Schweizer SRF porträtiert diesen Nachfolger, den reichsten Mann des Landes, der von vielen „Krokodil“ genannt wird. Ob er wirkliche Veränderung bringt, ist völlig offen. Eine Analyse von Mugabes Amtszeit hat die Deutsche Welle.'

response = dictionaryService.query_text(text, userService, user)
print(response)