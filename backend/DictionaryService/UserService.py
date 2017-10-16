import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from sqlalchemy.orm import sessionmaker

DATABASE_PATH = 'sqlite:///../db/user.db'

Base = declarative_base()


class Authentication:
    def __init__(self, email, password):
        self.email = email
        self.password = password

    @staticmethod
    def read(request):
        if not request:
            return None

        email = request.form.get("email")
        password = request.form.get("password")

        if not email or not password:
            return None

        return Authentication(email, password)


class User(Base):

    __tablename__ = 'user'

    email = sqlalchemy.Column(sqlalchemy.String(256), primary_key=True)
    password = sqlalchemy.Column(sqlalchemy.String(256))


class UserText(Base):

    __tablename__ = 'user_text'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)
    text = sqlalchemy.Column(sqlalchemy.String(8192))

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)


class UserService:
    def __init__(self):
        self.engine = sqlalchemy.create_engine(DATABASE_PATH)
        Base.metadata.bind = self.engine
        Base.metadata.create_all(self.engine)
        DBSession = sessionmaker(bind=self.engine)
        self.session = DBSession()

    def get_user(self, email):
        return self.session.query(User).filter(User.email == email).first()

    def authenticate(self, authentication: Authentication):
        user = self.get_user(authentication.email)

        if not user:  # user not existing
            return None

        if authentication.password != user.password:  # wrong password
            return None

        return user

    def register(self, email, password):
        user = User(email=email, password=password)
        try:
            self.session.add(user)
            self.session.commit()
        except:
            self.session.rollback()
            return False

        return True

    def add_text(self, user, text):
        user_text = UserText(user=user, text=text)
        self.session.add(user_text)
        self.session.commit()

        return True

    def get_texts(self, user):
        texts = self.session.query(UserText).filter(UserText.user == user).all()

        text_list = []
        for t in texts:
            text_list.append(t.text)

        return text_list

    def list(self):
        users = self.session.query(User).all()

        user_list = []

        for user in users:
            user_list.append({'user': user.email})

        return user_list
