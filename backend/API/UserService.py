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


class TextConfiguration(Base):

    __tablename__ = 'text_config'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    name = sqlalchemy.Column(sqlalchemy.String(128))
    stressed_color = sqlalchemy.Column(sqlalchemy.String(9))
    unstressed_color = sqlalchemy.Column(sqlalchemy.String(9))
    line_height = sqlalchemy.Column(sqlalchemy.Float)

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    def json(self):
        return {
            "stressed_color": self.stressed_color,
            "unstressed_color": self.unstressed_color,
            "line_height": self.line_height
        }


class UserWord(Base):

    __tablename__ = 'user_word'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    text = sqlalchemy.Column(sqlalchemy.String(128))
    stress_pattern = sqlalchemy.Column(sqlalchemy.String(32))
    hyphenation = sqlalchemy.Column(sqlalchemy.String(128))

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    def json(self):
        return {
            "stress_pattern": self.stress_pattern,
            "hyphenation": self.hyphenation
        }


class UserService:
    def __init__(self):
        self.engine = sqlalchemy.create_engine(DATABASE_PATH)
        Base.metadata.bind = self.engine
        Base.metadata.create_all(self.engine)
        DBSession = sessionmaker(bind=self.engine)
        self.session = DBSession()

    def get_user(self, email):
        return self.session.query(User).filter(User.email == email).first()

    def authenticate(self, authentication):
        if not authentication:
            return None

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

    def add_word(self, user, text, stress_pattern, hyphenation):
        user_word = UserWord(user=user, text=text, stress_pattern=stress_pattern, hyphenation=hyphenation)
        self.session.add(user_word)
        self.session.commit()

        return True

    def add_configuration(self, user, name, stressed_color, unstressed_color, line_height):
        configuration = TextConfiguration(user=user, name=name, stressed_color=stressed_color,
                                          unstressed_color= unstressed_color, line_height=line_height)
        self.session.add(configuration)
        self.session.commit()

        return True

    def get_texts(self, user):
        texts = self.session.query(UserText).filter(UserText.user == user).all()

        text_list = []
        for t in texts:
            text_list.append(t.text)

        return text_list

    def get_configurations(self, user):
        configurations = self.session.query(TextConfiguration).filter(TextConfiguration.user == user).all()

        configuration_list = []
        for c in configurations:
            configuration_list.append(c.json())

        return configuration_list

    def get_word(self, user, text):
        word = self.session.query(UserWord).filter(UserWord.user == user).filter(UserWord.text == text).first()
        if word is None:
            return None

        return word.json()

    def list_words(self, user):
        words = self.session.query(UserWord).all()

        word_list = []

        for word in words:
            word_list.append(word.json())

        return word_list

    def list(self):
        users = self.session.query(User).all()

        user_list = []

        for user in users:
            user_list.append({'user': user.email})

        return user_list
