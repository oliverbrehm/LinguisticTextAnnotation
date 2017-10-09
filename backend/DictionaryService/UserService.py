import flask_login

DATABASE_PATH = '../db/user.db'


class User:
    def __init__(self, email, password):
        self.email = email
        self.password = password
        self.authenticated = False

        self.texts = []

    def is_active(self):
        return True

    def get_id(self):
        return self.email

    def is_authenticated(self):
        return self.authenticated

    def is_anonymous(self):
        return False


class UserService:
    def __init__(self):
        self.users = []

        self.users.append(User("default", "password"))

    def get_user(self, email):
        for user in self.users:
            if user.email == email:
                return user

        return None

    def login(self, email, password):
        user = self.get_user(email)

        if not user:  # user not existing
            return None

        if password != user.password:  # wrong password
            return None

        user.authenticated = True

        flask_login.login_user(user)

        return user

    def logout(self, user):
        user.authenticated = False

        flask_login.logout_user()

        return True

    def register(self, email, password):
        user = self.get_user(email)
        if user:  # user already registered
            return False

        user = User(email, password)
        self.users.append(user)

        return True

    def add_text(self, user, text):
        user.texts.append(text)
        return True

    def get_texts(self, user):
        return user.texts

    def list(self):
        user_list = []

        for user in self.users:
            user_list.append({'user': user.email})

        return user_list
