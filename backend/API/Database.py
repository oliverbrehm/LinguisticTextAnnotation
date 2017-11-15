import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()


class Database:

    def __init__(self, path):
        # init sqlalchemy
        self.engine = sqlalchemy.create_engine(path)

        Base.metadata.bind = self.engine
        Base.metadata.create_all(self.engine)

        DBSession = sessionmaker(bind=self.engine)
        self.session = DBSession()