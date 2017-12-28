import spacy
import json

from DictionaryService import DictionaryService, Word, AddedEntry
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

# remove added global words
entries = dictionaryService.database.session.query(AddedEntry).all()
if entries:
    for entry in entries:
        w = entry.word
        if w:
            dictionaryService.database.session.delete(w)
            dictionaryService.database.session.commit()
        dictionaryService.database.session.delete(entry)

# add trivial missing words
dictionaryService.add_word("ans", "1", "ans", "", "adp")
dictionaryService.add_word("vom", "1", "vom", "", "adp")
dictionaryService.add_word("im", "1", "im", "", "adp")

w = dictionaryService.query_word('ans', '', userService, user)
print(w)
w = dictionaryService.query_word('vom', '', userService, user)
print(w)
w = dictionaryService.query_word('im', '', userService, user)
print(w)

w = dictionaryService.query_word('fühlte', '', userService, user)
print(w)