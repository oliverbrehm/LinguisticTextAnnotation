import spacy
import json

from DictionaryService import DictionaryService, Word
from UserService import UserService, Authentication
from VerificationService import VerificationService
from Database import Database

DB_USERS_PATH = 'sqlite:///../db/user.db'
DB_WORDS_PATH = 'sqlite:///../db/words.db'

userDatabase = Database(DB_USERS_PATH)
wordsDatabase = Database(DB_WORDS_PATH)

dictionaryService = DictionaryService(wordsDatabase)
verificationService = VerificationService(userDatabase)
userService = UserService(userDatabase)

user = userService.get_user('olibrehm@gmail.com')

#entries = dictionaryService.database.session.query(Word).all()
#print('length: ', len(entries))

w = dictionaryService.query_word('Überblick', '', userService, user)
print(w)