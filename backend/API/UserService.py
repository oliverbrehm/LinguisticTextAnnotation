import sqlalchemy
from flask import json
from sqlalchemy.orm import relationship

from DictionaryService import DictionaryService

from Database import Base as Base


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

    first_name = sqlalchemy.Column(sqlalchemy.String(256))
    last_name = sqlalchemy.Column(sqlalchemy.String(256))

    is_admin = sqlalchemy.Column(sqlalchemy.Boolean)
    is_expert = sqlalchemy.Column(sqlalchemy.Boolean)

    def json(self):
        return {
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'is_admin': self.is_admin,
            'is_expert': self.is_expert
        }

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
    alternate_color = sqlalchemy.Column(sqlalchemy.String(9))

    line_height = sqlalchemy.Column(sqlalchemy.Float)
    word_distance = sqlalchemy.Column(sqlalchemy.Float)
    syllable_distance = sqlalchemy.Column(sqlalchemy.Float)
    font_size = sqlalchemy.Column(sqlalchemy.Float)
    letter_spacing = sqlalchemy.Column(sqlalchemy.Float)

    use_background = sqlalchemy.Column(sqlalchemy.Boolean)
    highlight_foreground = sqlalchemy.Column(sqlalchemy.Boolean)
    stressed_bold = sqlalchemy.Column(sqlalchemy.Boolean)
    use_alternate_color = sqlalchemy.Column(sqlalchemy.Boolean)

    user_email = sqlalchemy.Column(sqlalchemy.String(256), sqlalchemy.ForeignKey('user.email'))
    user = relationship(User)

    def json(self):
        return {
            "id": self.id,
            "name": self.name,

            "stressed_color": self.stressed_color,
            "unstressed_color": self.unstressed_color,
            "word_background": self.word_background,
            "alternate_color": self.alternate_color,

            "line_height": self.line_height,
            "word_distance": self.word_distance,
            "syllable_distance": self.syllable_distance,
            "font_size": self.font_size,
            "letter_spacing": self.letter_spacing,

            "use_background": self.use_background,
            "highlight_foreground": self.highlight_foreground,
            "stressed_bold": self.stressed_bold,
            "use_alternate_color": self.use_alternate_color,
        }

class PartOfSpeechConfiguration(Base):

    __tablename__ = 'pos_config'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)

    pos_id = sqlalchemy.Column(sqlalchemy.String(16))
    policy = sqlalchemy.Column(sqlalchemy.String(16))

    text_config_id = sqlalchemy.Column(sqlalchemy.Integer, sqlalchemy.ForeignKey('text_config.id'))
    text_config = relationship(TextConfiguration)

    def json(self):
        return {
            "pos_id": self.pos_id,
            "policy": self.policy
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
            "hyphenation": self.hyphenation,
            "user_first_name": self.user.first_name,
            "user_last_name": self.user.last_name
        }


class UserService:
    def __init__(self, database):
        self.database = database

    def get_user(self, email):
        return self.database.session.query(User).filter(User.email == email).first()

    def authenticate(self, authentication):
        if not authentication:
            return None

        user = self.get_user(authentication.email)

        if not user:  # user not existing
            return None

        if authentication.password != user.password:  # wrong password
            return None

        return user

    def register(self, email, password, first_name, last_name, is_expert):
        user = User(email=email, password=password, first_name=first_name, last_name=last_name, is_expert=is_expert,
            is_admin=False)
        try:
            self.database.session.add(user)
            self.database.session.commit()
        except:
            self.database.session.rollback()
            return False

        return True

    def add_text(self, user, title, text):
        user_text = UserText(user=user, title=title, text=text)
        self.database.session.add(user_text)
        self.database.session.commit()

        return True

    def delete_text(self, text_id):
        n_id = int(text_id)

        try:
            user_text = self.database.session.query(UserText).filter(UserText.id == n_id).first()
            self.database.session.delete(user_text)
            self.database.session.commit()
        except Exception as e:
            print(e)
            return False

        return True

    def add_word(self, user, text, stress_pattern, hyphenation):
        text = DictionaryService.preprocess_entry(text)
        hyphenation = DictionaryService.preprocess_entry(hyphenation)

        user_word = UserWord(user=user, text=text, stress_pattern=stress_pattern, hyphenation=hyphenation)
        self.database.session.add(user_word)
        self.database.session.commit()

        return True

    def delete_word(self, word_id):
        n_id = int(word_id)

        try:
            user_word = self.database.session.query(UserWord).filter(UserWord.id == n_id).first()
            self.database.session.delete(user_word)
            self.database.session.commit()
        except Exception as e:
            print(e)
            return False

        return True

    def add_configuration(self, user, name, stressed_color, unstressed_color, word_background, alternate_color, word_distance,
                          syllable_distance, font_size, letter_spacing, use_background, highlight_foreground, stressed_bold,
                          line_height, use_alternate_color, pos_config_list):
        configuration = TextConfiguration(user=user, name=name, stressed_color=stressed_color,
                                          unstressed_color= unstressed_color, word_background=word_background,
                                          word_distance=word_distance, syllable_distance=syllable_distance,
                                          use_background=use_background, highlight_foreground=highlight_foreground,
                                          stressed_bold=stressed_bold, font_size=font_size,
                                          letter_spacing=letter_spacing, line_height=line_height,
                                          alternate_color=alternate_color, use_alternate_color=use_alternate_color)
        self.database.session.add(configuration)
        self.database.session.commit()

        print('add pos')

        for pos_config in pos_config_list:
            pos_id = pos_config['pos_id']
            policy = pos_config['policy']

            print('adding', pos_id, policy)

            pos = PartOfSpeechConfiguration(pos_id=pos_id, policy=policy, text_config=configuration)

            self.database.session.add(pos)

        self.database.session.commit()

        # TODO maybe return id here (also other add methods), so that frontend does not have to reload the list
        return True

    def update_configuration(self, configuration_id, name, stressed_color, unstressed_color, word_background, alternate_color,
                             word_distance, syllable_distance, font_size, letter_spacing, use_background, highlight_foreground,
                             stressed_bold, line_height, use_alternate_color, pos_config_list):
        n_id = int(configuration_id)

        configuration = self.database.session.query(TextConfiguration).filter(TextConfiguration.id == n_id).first()

        if not configuration:
            return False

        configuration.name = name

        configuration.stressed_color = stressed_color
        configuration.unstressed_color = unstressed_color
        configuration.word_background = word_background
        configuration.alternate_color = alternate_color

        configuration.line_height = line_height
        configuration.word_distance = word_distance
        configuration.syllable_distance = syllable_distance
        configuration.font_size = font_size
        configuration.letter_spacing = letter_spacing

        configuration.use_background = use_background
        configuration.highlight_foreground = highlight_foreground
        configuration.stressed_bold = stressed_bold
        configuration.use_alternate_color = use_alternate_color

        self.database.session.commit()

        print('update pos')

        try:
            pos_config = self.database.session.query(PartOfSpeechConfiguration)\
                .filter(PartOfSpeechConfiguration.text_config == configuration).all()
            for pc_db in pos_config:
                for pc_update in pos_config_list:
                    pos_id = pc_update['pos_id']
                    pos_policy = pc_update['policy']
                    if pc_db.pos_id == pos_id:
                        pc_db.policy = pos_policy

            self.database.session.commit()
        except Exception as e:
            print("Error updating part of speech for TextConfiguration")
            print(str(e))

        return True

    def delete_configuration(self, conf_id):
        n_id = int(conf_id)

        try:
            text_config = self.database.session.query(TextConfiguration).filter(TextConfiguration.id == n_id).first()

            self.database.session.query(PartOfSpeechConfiguration) \
                .filter(PartOfSpeechConfiguration.text_config == text_config).delete()

            self.database.session.delete(text_config)
            self.database.session.commit()
        except Exception as e:
            print(e)
            return False

        return True

    def get_texts(self, user):
        texts = self.database.session.query(UserText).filter(UserText.user == user).all()

        text_list = []
        for t in texts:
            text_list.append(t.json())

        return text_list

    def get_configurations(self, user):
        configurations = self.database.session.query(TextConfiguration).filter(TextConfiguration.user == user).all()

        configuration_list = []
        for c in configurations:
            config = c.json()
            pos_config_list = []

            try:
                pos_config = self.database.session.query(PartOfSpeechConfiguration) \
                    .filter(PartOfSpeechConfiguration.text_config == c).all()
                for pc in pos_config:
                    pos_config_list.append(pc.json())
            except Exception as e:
                print("Error querying part of speech for TextConfiguration")
                print(str(e))

            config['part_of_speech_configuration'] = pos_config_list
            configuration_list.append(config)

        return configuration_list

    def get_word(self, user, text):
        word = self.database.session.query(UserWord).filter(UserWord.user == user).filter(UserWord.text == text).first()
        if word is None:
            return None

        return word.json()

    def list_words(self, user):
        words = self.database.session.query(UserWord).filter(UserWord.user == user).all()

        word_list = []

        for word in words:
            word_list.append(word.json())

        return word_list

    def list_all_words(self):
        words = self.database.session.query(UserWord).all()

        word_list = []

        for word in words:
            word_list.append(word.json())

        return word_list

    def list(self):
        users = self.database.session.query(User).all()

        user_list = []

        for user in users:
            user_list.append({'user': user.email})

        return user_list
