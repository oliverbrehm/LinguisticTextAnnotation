import spacy
import json

from DictionaryService import DictionaryService
from UserService import UserService, Authentication
from VerificationService import VerificationService
from Database import Database

DB_USERS_PATH = 'sqlite:///../db/user.db'
DB_WORDS_PATH = 'sqlite:///../db/celex.db'

userDatabase = Database(DB_USERS_PATH)
wordsDatabase = Database(DB_WORDS_PATH)

dictionaryService = DictionaryService(wordsDatabase)
verificationService = VerificationService(userDatabase)
userService = UserService(userDatabase)

user = userService.get_user('olibrehm@gmail.com')

configs = userService.get_configurations(user)

for c in configs:
    print('=================================')
    pos = c['part_of_speech_configuration']

    print(c['name'])
    print('len:', len(pos))

    for p in pos:
        print(str(p))