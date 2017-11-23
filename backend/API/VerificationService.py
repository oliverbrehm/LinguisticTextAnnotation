import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from sqlalchemy.orm import sessionmaker

from DictionaryService import DictionaryService, Word
from UserService import UserService, User, UserWord

DATABASE_PATH = 'sqlite:///../db/user.db'
SCORE_GOAL = 3

from Database import Base as Base

class VerificationProposal(Base):

    __tablename__ = 'verification_proposal'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    stress_pattern = sqlalchemy.Column(sqlalchemy.String(32))
    hyphenation = sqlalchemy.Column(sqlalchemy.String(128))

    user_word_id = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user_word.id'))
    user_word = relationship(UserWord)

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    def json(self):
        return {
            'id': self.id,
            'user_word_id:': self.user_word_id,
            'user': self.user_email,
            'stress_pattern': self.stress_pattern,
            'hyphenation': self.hyphenation
        }


class VerificationService:
    def __init__(self, database):
        self.database = database

    def list_proposals(self):
        proposals = self.database.session.query(VerificationProposal).all()
        result = []

        for p in proposals:
            result.append(p.json())

        return result

    def next_word(self, user):
        # exclude all words by user himself
        words = self.database.session.query(UserWord)\
            .filter(UserWord.user != user).all()

        # TODO maybe possible to do both queries in one (join)
        for w in words:
            # search for first word where no proposal from user exists
            proposal = self.database.session.query(VerificationProposal)\
                .filter(VerificationProposal.user_word == w).filter(VerificationProposal.user == user).first()

            if proposal is None:
                # no proposal exists for that user and wor
                return w

        return None

    def num_words(self):
        num = self.database.session.query(UserWord).count()
        return num

    def proposals_for_word(self, user_word):
        # get proposals for user_word
        proposals = self.database.session.query(VerificationProposal)\
            .filter(VerificationProposal.user_word == user_word).all()

        return proposals

    def submit(self, user, word_id, stress_pattern, hyphenation, dictionaryService):
        user_word = self.database.session.query(UserWord).filter(UserWord.id == word_id).first()

        if not user_word:
            print('user word not found')
            return False

        #  add verification proposal
        if not self.add_proposal(user, user_word, stress_pattern, hyphenation):
            print('error adding VerificationProposal')
            return False

        #  check all verification proposals for that UserWord
        should_transfer = self.check_proposals(user_word, stress_pattern, hyphenation)

        #  if condition matched (enough votes):
        if should_transfer:
            #  add word in global db
            if not self.transfer_to_global_db(user_word, dictionaryService):
                print('error adding word in global db')
                return False

            #  remove all proposals and user word
            if not self.cleanup_proposals(user_word):
                print('error cleaning up')
                return False

        return True

    def add_proposal(self, user, user_word, stress_pattern, hyphenation):
        proposal = VerificationProposal(stress_pattern=stress_pattern, hyphenation=hyphenation, user=user, user_word=user_word)

        try:
            self.database.session.add(proposal)
            self.database.session.commit()
        except Exception as e:
            self.database.session.rollback()
            print(e)
            return False

        return True

    def check_proposals(self, user_word, stress_pattern, hyphenation):
        proposals = self.database.session.query(VerificationProposal)\
            .filter(VerificationProposal.user_word == user_word).all()

        score = 0

        for p in proposals:
            user = user_word.user

            # compare proposal in list to new proposal
            if p.stress_pattern != stress_pattern or p.hyphenation != hyphenation:
                continue

            # proposals match, raise score according to user group
            if user.is_admin:
                score += SCORE_GOAL # admin has full power
            elif user.is_expert:
                score += 2
            else:
                score += 1

        print('proposal score: ', score)

        if score >= SCORE_GOAL:
            return True

        return False

    def transfer_to_global_db(self, user_word, dictionary_service):
        db_word = dictionary_service.add_word(user_word.text, user_word.stress_pattern, user_word.hyphenation)

        if not db_word:
            print('error adding entry in word database')
            return False

        return True

    def cleanup_proposals(self, user_word):
        #  remove all proposals
        try:
            self.database.session.query(VerificationProposal)\
                .filter(VerificationProposal.user_word == user_word).delete()
            self.database.session.commit()
        except Exception as e:
            print('error deleting verification proposals')
            print(e)
            self.database.session.rollback()
            return False

        #  remove UserWord
        try:
            self.database.session.delete(user_word)
            self.database.session.commit()
        except Exception as e:
            print('error deleting UserWord')
            self.database.session.rollback()
            print(e)
            return False

        return True