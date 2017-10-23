import UserService
import DictionaryService

userService = UserService.UserService()
dictionaryService = DictionaryService.DictionaryService()

#userService.register('test', 'blub')

user = userService.get_user('oliver')

#userService.add_text(user, "hallo i bims 1 text")

#print(str(user.email))

#userService.add_word(user, 'test9', '01', 'test-9')

#words = userService.list_words(user)
#print(words)

#resp = dictionaryService.query_word('im', userService, user)
#print(resp)

#word = userService.get_word(user, 'im')
#print(word)

#userService.engine.execute("DROP TABLE IF EXISTS user_word")

#dictionaryService.add_word('test4', '01', 'test-4')

print(dictionaryService.query_segmentation("hallo"))