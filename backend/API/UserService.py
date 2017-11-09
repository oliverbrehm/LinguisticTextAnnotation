import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from sqlalchemy.orm import sessionmaker

from DictionaryService import DictionaryService

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

    title = sqlalchemy.Column(sqlalchemy.String(128))
    text = sqlalchemy.Column(sqlalchemy.String(8192))

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    def json(self):
        return {
            'id': self.id,
            'title': self.title,
            'text': self.text
        }


class TextConfiguration(Base):

    __tablename__ = 'text_config'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    name = sqlalchemy.Column(sqlalchemy.String(128))

    stressed_color = sqlalchemy.Column(sqlalchemy.String(9))
    unstressed_color = sqlalchemy.Column(sqlalchemy.String(9))
    word_background = sqlalchemy.Column(sqlalchemy.String(9))

    line_height = sqlalchemy.Column(sqlalchemy.Float)
    word_distance = sqlalchemy.Column(sqlalchemy.Float)
    syllable_distance = sqlalchemy.Column(sqlalchemy.Float)
    font_size = sqlalchemy.Column(sqlalchemy.Float)

    use_background = sqlalchemy.Column(sqlalchemy.Boolean)
    highlight_foreground = sqlalchemy.Column(sqlalchemy.Boolean)
    stressed_bold = sqlalchemy.Column(sqlalchemy.Boolean)

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    def json(self):
        return {
            "id": self.id,
            "name": self.name,

            "stressed_color": self.stressed_color,
            "unstressed_color": self.unstressed_color,
            "word_background": self.word_background,

            "line_height": self.line_height,
            "word_distance": self.word_distance,
            "syllable_distance": self.syllable_distance,
            "font_size": self.font_size,

            "use_background": self.use_background,
            "highlight_foreground": self.highlight_foreground,
            "stressed_bold": self.stressed_bold
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
            "id": self.id,
            "text": self.text,
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

    def add_text(self, user, title, text):
        user_text = UserText(user=user, title=title, text=text)
        self.session.add(user_text)
        self.session.commit()

        return True

    def delete_text(self, text_id):
        n_id = int(text_id)

        try:
            user_text = self.session.query(UserText).filter(UserText.id == n_id).first()
            self.session.delete(user_text)
            self.session.commit()
        except Exception as e:
            print(e)
            return False

        return True

    def add_word(self, user, text, stress_pattern, hyphenation):
        text = DictionaryService.preprocess_entry(text)
        hyphenation = DictionaryService.preprocess_entry(hyphenation)

        user_word = UserWord(user=user, text=text, stress_pattern=stress_pattern, hyphenation=hyphenation)
        self.session.add(user_word)
        self.session.commit()

        return True

    def delete_word(self, word_id):
        n_id = int(word_id)

        try:
            user_word = self.session.query(UserWord).filter(UserWord.id == n_id).first()
            self.session.delete(user_word)
            self.session.commit()
        except Exception as e:
            print(e)
            return False

        return True

    def add_configuration(self, user, name, stressed_color, unstressed_color, word_background, word_distance,
                          syllable_distance, font_size, use_background, highlight_foreground, stressed_bold,
                          line_height):
        # TODO check how booleans are mapped, does not work
        configuration = TextConfiguration(user=user, name=name, stressed_color=stressed_color,
                                          unstressed_color= unstressed_color, word_background=word_background,
                                          word_distance=word_distance, syllable_distance=syllable_distance,
                                          use_background=use_background, highlight_foreground=highlight_foreground,
                                          stressed_bold=stressed_bold, font_size=font_size, line_height=line_height)
        self.session.add(configuration)
        self.session.commit()

        return True

    def update_configuration(self, configuration_id, name, stressed_color, unstressed_color, word_background,
                             word_distance, syllable_distance, font_size, use_background, highlight_foreground,
                             stressed_bold, line_height):
        n_id = int(configuration_id)

        configuration:TextConfiguration = self.session.query(TextConfiguration).filter(TextConfiguration.id == n_id).first()

        if not configuration:
            return False

        configuration.name = name

        configuration.stressed_color = stressed_color
        configuration.unstressed_color = unstressed_color
        configuration.word_background = word_background

        configuration.line_height = line_height
        configuration.word_distance = word_distance
        configuration.syllable_distance = syllable_distance
        configuration.font_size = font_size

        configuration.use_background = use_background
        configuration.highlight_foreground = highlight_foreground
        configuration.stressed_bold = stressed_bold

        self.session.commit()

        return True

    def delete_configuration(self, conf_id):
        n_id = int(conf_id)

        try:
            text_config = self.session.query(TextConfiguration).filter(TextConfiguration.id == n_id).first()
            self.session.delete(text_config)
            self.session.commit()
        except Exception as e:
            print(e)
            return False

        return True

    def get_texts(self, user):
        texts = self.session.query(UserText).filter(UserText.user == user).all()

        text_list = []
        for t in texts:
            text_list.append(t.json())

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
        words = self.session.query(UserWord).filter(User.email == user.email).all()

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
