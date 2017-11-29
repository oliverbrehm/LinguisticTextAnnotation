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

text = '!@#$%^&*()_Die Metall- und Elektroindustrie schrumpft, statt 32.000 Menschen leben nur noch 17.000 Einwohner dort.'

response = dictionaryService.query_text(text, userService, user)
print(response)

