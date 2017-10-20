import UserService
import DictionaryService

userService = UserService.UserService()
dictionaryService = DictionaryService.DictionaryService()

#userService.register('test', 'blub')

user = userService.get_user('oliver')

#userService.add_text(user, "hallo i bims 1 text")

print(str(user.email))

#texts = userService.get_texts(user)
#print(texts)

#users = userService.get_word(user, 'test1')
#print(users)

#userService.engine.execute("DROP TABLE IF EXISTS text_config")

dictionaryService.add_word('test4', '01', 'test-4')