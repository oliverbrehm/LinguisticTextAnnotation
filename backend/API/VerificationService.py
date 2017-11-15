import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from sqlalchemy.orm import sessionmaker

from DictionaryService import DictionaryService, Word
from UserService import UserService, User, UserWord

DATABASE_PATH = 'sqlite:///../db/user.db'

Base = declarative_base()


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

    word_id = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('word.id'))
    word = relationship(Word)

    def __init__(self):
        pass  # TODO

    def json(self):
        pass  # TODO


class VerificationService:
    def __init__(self):
        # init sqlalchemy
        self.engine = sqlalchemy.create_engine(DATABASE_PATH)
        Base.metadata.bind = self.engine
        Base.metadata.create_all(self.engine)
        DBSession = sessionmaker(bind=self.engine)
        self.session = DBSession()

    def next_word(self):
        pass  # TODO

    def num_words(self):
        pass  # TODO

    def submit(self, user, word, stress_pattern, hyphenation):
        pass  # TODO