import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from sqlalchemy.orm import sessionmaker

from DictionaryService import DictionaryService, Word
from UserService import UserService, User, UserWord

DATABASE_PATH = 'sqlite:///../db/user.db'

from Database import Base as Base

class VerificationProposal(Base):

    __tablename__ = 'verification_proposal'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    text = sqlalchemy.Column(sqlalchemy.String(128), primary_key=True)
    stress_pattern = sqlalchemy.Column(sqlalchemy.String(32))
    hyphenation = sqlalchemy.Column(sqlalchemy.String(128))

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    user_word_id = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user_word.id'))
    user_word = relationship(UserWord)

    def __init__(self):
        pass  # TODO

    def json(self):
        pass  # TODO


class AddedEntry(Base):
    __tablename__ = 'added_entry'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    word_text = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('word.text'))
    word = relationship(Word)

    def __init__(self):
        pass  # TODO

    def json(self):
        pass  # TODO


class VerificationService:
    def __init__(self, database):
        self.database = database

    def next_word(self):
        word = self.database.session.query(UserWord).first()
        if word is None:
            return None

        return word.json()

    def num_words(self):
        num = self.database.session.query(UserWord).count()
        print('num:', num)
        return num

    def submit(self, user, word, stress_pattern, hyphenation):
        #  add verification proposal

        #  check all verification proposals for that UserWord

        #  if condition matched (enough votes):
            #  add word in global db

            #  create AddedEntry

            #  remove all proposals

            #  remove UserWord

        pass  # TODO