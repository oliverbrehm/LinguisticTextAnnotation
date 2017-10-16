import UserService

userService = UserService.UserService()

userService.register('test', 'blub')

user = userService.get_user('oliver')

#userService.add_text(user, "hallo i bims 1 text")

print(str(user.password))

texts = userService.get_texts(user)
print(texts)

users = userService.list()
print(users)