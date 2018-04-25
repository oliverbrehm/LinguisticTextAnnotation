import sys, os

sys.path.append(os.path.relpath('../API'))

import DictionaryService
from DictionaryService import Word
from Database import Database

DB_WORDS_PATH = 'sqlite:///../db/words.db'

wordsDatabase = Database(DB_WORDS_PATH)

dictionary_service = DictionaryService.DictionaryService(wordsDatabase)

def print_hyphenation(text):
    word = wordsDatabase.session.query(Word).filter(Word.text == text).first()
    print(word.text, ':', word.hyphenation)

def replace_kk_ck():
    words = wordsDatabase.session.query(Word).filter(Word.text.like('%ck%')).all()

    for word in words:
        old_hyphenation = word.hyphenation
        updated_hyphenation = old_hyphenation.replace('k-k', '-ck')
        word.hyphenation = updated_hyphenation

    wordsDatabase.session.commit()

def print_ck_hyphenation():
    words = wordsDatabase.session.query(Word).filter(Word.text.like('hacken')).all()

    for word in words:
        print(word.text, ':', word.hyphenation, '-', word.pos)

# TEST
#print_hyphenation('hacken')
#print_ck_hyphenation()