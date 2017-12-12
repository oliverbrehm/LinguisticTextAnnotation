#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import getopt
import json
import datetime

from DictionaryService import DictionaryService, Segmentation
from UserService import UserService, Authentication
from VerificationService import VerificationService
from Database import Database

from flask import Flask, request
from flask import Response

DB_WORDS_PATH = 'sqlite:///../db/words.db'
DB_USERS_PATH = 'sqlite:///../db/user.db'

app = Flask(__name__)

wordsDatabase = Database(DB_WORDS_PATH)
userDatabase = Database(DB_USERS_PATH)

dictionaryService = DictionaryService(wordsDatabase)
userService = UserService(userDatabase)
verificationService = VerificationService(userDatabase)

def map_boolean(value):
    if value is True or value == 'True' or value == 'true' or value == 1:
        return True
    return False

def create_response(code, data={}):
    response_string = json.dumps(data)
    response = Response(response=response_string, status=code, mimetype="application/json")
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    response.headers['Access-Control-Max-Age'] = 1000

    # note that '*' is not valid for Access-Control-Allow-Headers
    response.headers['Access-Control-Allow-Headers'] = 'origin, x-csrftoken, content-type, accept'
    return response


def create_error_response(errcode, message):
    return create_response(errcode, {"error": str(message)})


@app.route('/', methods=['GET'])
def api_intro():
    return "LinguisticTextAnnotation API"

@app.route('/error', methods=['GET'])
def test_error():
    print(thiswillcauseanerror)
    return create_response(201)


''' ---------------------------------------------------------
    Text analysis
    --------------------------------------------------------- '''


@app.route('/query/word/<text>/<pos>', methods=['GET'])
def query_word(text, pos):
    user = userService.authenticate(Authentication.read(request))
    # TODO better method than to pass userService as a parameter?
    response = dictionaryService.query_word(text, pos, userService, user)

    if response is None:
        return create_error_response(404, "Word not found.")

    return create_response(200, response)


@app.route('/query/text', methods=['POST'])
def query_text():
    user = userService.authenticate(Authentication.read(request))
    text = request.form.get("text")

    # TODO better method than to pass userService as a parameter?
    response = dictionaryService.query_text(text, userService, user)

    if response is None:
        return create_error_response(404, "Error analyzing text.")

    return create_response(200, response)


@app.route('/query/segmentation/<word>', methods=['GET'])
def query_segmentation(word):
    response = dictionaryService.query_segmentation(word)

    if response is None:
        return create_error_response(404, "Error querying segmentation.")

    return create_response(200, response)


''' ---------------------------------------------------------
    User Words
    --------------------------------------------------------- '''


@app.route('/user/word/add', methods=['POST'])
def user_add_word():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    text = request.form.get("text")
    stress_pattern = request.form.get("stress_pattern")
    hyphenation = request.form.get("hyphenation")
    lemma = request.form.get("lemma")
    pos = request.form.get("pos")

    if not text or not stress_pattern or not hyphenation or not lemma or not pos:
        return create_error_response(400, "Data not provided.")

    db_word = userService.add_word(user, text, lemma, pos, stress_pattern, hyphenation)

    if not db_word:
        return create_error_response(404, "Error adding word.")

    return create_response(201)


@app.route('/user/word/delete', methods=['POST'])
def user_delete_word():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    wordId = request.form.get("id")

    if not wordId:
        return create_error_response(400, "Word id not provided.")

    if not userService.delete_word(wordId):
        return create_error_response(404, "Error deleting text.")

    return create_response(204)


@app.route('/user/word/list', methods=['POST'])
def user_get_words():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    user_words = userService.list_words(user)

    if user_words is None:
        return create_error_response(404, "Error getting user words.")

    return create_response(200, {'user_words': user_words})


''' ---------------------------------------------------------
    Text configuration
    --------------------------------------------------------- '''


@app.route('/user/configuration/add', methods=['POST'])
def user_add_configuration():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    name = request.form.get("name")

    stressed_color = request.form.get("stressed_color")
    unstressed_color = request.form.get("unstressed_color")
    word_background = request.form.get('word_background')
    alternate_color = request.form.get('alternate_color')
    syllable_separator = request.form.get('syllable_separator')

    line_height = request.form.get("line_height")
    word_distance = request.form.get('word_distance')
    syllable_distance = request.form.get('syllable_distance')
    font_size = request.form.get('font_size')
    letter_spacing = request.form.get('letter_spacing')

    use_background = map_boolean(request.form.get('use_background'))
    highlight_foreground = map_boolean(request.form.get('highlight_foreground'))
    stressed_bold = map_boolean(request.form.get('stressed_bold'))
    use_alternate_color = map_boolean(request.form.get('use_alternate_color'))
    use_syllable_separator = map_boolean(request.form.get('use_syllable_separator'))

    pos_config_list = request.form.get("part_of_speech_configuration")
    pos_config_list = json.loads(pos_config_list)

    if not name or not stressed_color or not unstressed_color or not word_background or not line_height \
            or not word_distance or not syllable_distance or not font_size or not letter_spacing \
            or not alternate_color or not pos_config_list or not syllable_separator:
        return create_error_response(400, "Data not provided.")

    success = userService.add_configuration(user, name, stressed_color, unstressed_color, word_background, alternate_color, syllable_separator,
                                            word_distance, syllable_distance, font_size, letter_spacing, use_background,
                                            highlight_foreground, stressed_bold, line_height,
                                            use_alternate_color, use_syllable_separator, pos_config_list)

    if not success:
        return create_error_response(404, "Error adding configuration.")

    return create_response(201)


@app.route('/user/configuration/update', methods=['POST'])
def user_update_configuration():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    configuration_id = request.form.get("id")
    name = request.form.get("name")

    stressed_color = request.form.get("stressed_color")
    unstressed_color = request.form.get("unstressed_color")
    word_background = request.form.get('word_background')
    alternate_color = request.form.get('alternate_color')
    syllable_separator = request.form.get('syllable_separator')

    line_height = request.form.get("line_height")
    word_distance = request.form.get('word_distance')
    syllable_distance = request.form.get('syllable_distance')
    font_size = request.form.get('font_size')
    letter_spacing = request.form.get('letter_spacing')

    use_background = map_boolean(request.form.get('use_background'))
    highlight_foreground = map_boolean(request.form.get('highlight_foreground'))
    stressed_bold = map_boolean(request.form.get('stressed_bold'))
    use_alternate_color = map_boolean(request.form.get('use_alternate_color'))
    use_syllable_separator = map_boolean(request.form.get('use_syllable_separator'))

    pos_config_list = json.loads(request.form.get("part_of_speech_configuration"))

    if not name or not stressed_color or not unstressed_color or not word_background or not line_height \
            or not word_distance or not syllable_distance or not font_size or not letter_spacing\
            or not alternate_color or not pos_config_list or not syllable_separator:
        return create_error_response(400, "Data not provided.")

    success = userService.update_configuration(configuration_id, name, stressed_color, unstressed_color,
                                               word_background, alternate_color, syllable_separator, word_distance, syllable_distance, font_size, letter_spacing,
                                               use_background, highlight_foreground, stressed_bold, line_height,
                                               use_alternate_color, use_syllable_separator, pos_config_list)

    if not success:
        return create_error_response(404, "Configuration to be updated not found.")

    return create_response(201)


@app.route('/user/configuration/list', methods=['POST'])
def user_get_configurations():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    configurations = userService.get_configurations(user)

    if configurations is None:
        return create_error_response(404, "Error getting configurations.")

    return create_response(200, {'configurations': configurations})


@app.route('/user/configuration/delete', methods=['POST'])
def user_delete_configuration():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    configId = request.form.get("id")

    if not configId:
        return create_error_response(400, "Configuration id not provided.")

    if not userService.delete_configuration(configId):
        return create_error_response(404, "Error deleting configuration.")

    return create_response(204)


''' ---------------------------------------------------------
    User Texts
    --------------------------------------------------------- '''


@app.route('/user/text/add', methods=['POST'])
def user_add_text():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    title = request.form.get("title")
    text = request.form.get("text")

    if not text:
        return create_error_response(400, "Text not provided.")

    if not title:
        return create_error_response(400, "Title not provided.")

    if not userService.add_text(user, title, text):
        return create_error_response(404, "Error adding text.")

    return create_response(201)


@app.route('/user/text/delete', methods=['POST'])
def user_delete_text():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    textId = request.form.get("id")

    if not textId:
        return create_error_response(400, "Text id not provided.")

    if not userService.delete_text(textId):
        return create_error_response(404, "Error deleting text.")

    return create_response(204)


@app.route('/user/text/list', methods=['POST'])
def user_get_texts():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    texts = userService.get_texts(user)

    if texts is None:
        return create_error_response(404, "Error getting texts.")

    return create_response(200, {'texts': texts})


''' ---------------------------------------------------------
    Word verification
    --------------------------------------------------------- '''


@app.route('/user/verification/query', methods=['POST'])
def query_verification():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    user_word = verificationService.next_word(user)

    if user_word is None:
        return create_error_response(404, "No words to verify.")

    word = user_word.json()
    resp = {'word': word}

    num_words = verificationService.num_words()
    if num_words is not None:
        resp['num_words'] = num_words

    segmentations = []

    verification_proposals = verificationService.proposals_for_word(user_word)
    if verification_proposals is not None:
        for p in verification_proposals:
            s = Segmentation(word['text'], p.user.first_name + " " + p.user.last_name, "Benutzer"
                             , p.hyphenation, p.stress_pattern)
            segmentations.append(s.json())

    segmentation_proposals = dictionaryService.query_segmentation(word['text'])
    if segmentation_proposals is not None:
        segmentations = segmentations + segmentation_proposals

    if segmentations is not None:
        resp['segmentations'] = segmentations

    return create_response(200, resp)


@app.route('/user/verification/submit', methods=['POST'])
def submit_verification():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(403, "Invalid credentials.")

    word_id = request.form.get("id")

    if not word_id:
        return create_error_response(400, "Word id not provided.")

    stress_pattern = request.form.get("stress_pattern")
    hyphenation = request.form.get("hyphenation")
    lemma = request.form.get("lemma")

    if not stress_pattern or not hyphenation or not lemma:
        return create_error_response(400, "Data not provided.")

    if not verificationService.submit(user, word_id, lemma, stress_pattern, hyphenation, dictionaryService):
        return create_error_response(404, "Unable to submit proposal.")

    return create_response(201)


''' ---------------------------------------------------------
    User functions
    --------------------------------------------------------- '''


@app.route('/user/register', methods=['POST'])
def user_register():
    email = request.form.get("email")
    password = request.form.get("password")

    if not email or not password:
        return create_error_response(400, "Email or password not provided.")

    first_name = request.form.get("first_name")
    if not first_name:
        return create_error_response(400, "First name not provided.")

    last_name = request.form.get("last_name")
    if not last_name:
        return create_error_response(400, "Last name not provided.")

    s_is_expert = request.form.get("is_expert")
    if s_is_expert is None:
        return create_error_response(400, "Expert status not provided.")
    is_expert = map_boolean(s_is_expert)

    response = userService.register(email, password, first_name, last_name, is_expert)

    if not response:
        return create_error_response(404, "User already existing.")

    return create_response(201)


@app.route('/user/authenticate', methods=['POST'])
def user_authenticate():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    return create_response(200, {'user': user.json()})


@app.route('/user/list', methods=['GET'])
def user_list():
    users = userService.list()

    if not users:
        return create_error_response(404, "Error getting user list.")

    return create_response(200, {'users': users})


''' ---------------------------------------------------------
    Logging and error handling
    --------------------------------------------------------- '''


@app.after_request
def after_request(response):
    app.logger.info("Request on: " + str(datetime.datetime.now()) + str(request) + " | Response: " + str(response))
    return response


@app.errorhandler(404)
def error_not_found(exception):
    app.logger.info("Request on: " + str(datetime.datetime.now()) + str(request) + " | Exception: " + str(exception))
    return create_error_response(404, exception)


@app.errorhandler(500)
def internal_error(exception):
    app.logger.error("\n\n*** ERROR LOG ***\n"
                     "Timestamp: " + str(datetime.datetime.now()) + "\n"
                     + str(exception)
                     + "\n*****************\n\n")
    return create_error_response(500, exception)


''' ---------------------------------------------------------
    Flask app
    --------------------------------------------------------- '''


def print_help():
    print("Options:\n\t"
          "-p Port to use\n\t"
          "-d debug mode")


if __name__ == '__main__':
    port = 0
    debug = False

    try:
        options, args = getopt.getopt(sys.argv[1:], "p:d")
    except getopt.GetoptError:
        print_help()
        sys.exit(1)

    for opt, arg in options:
        if opt == "-p":
            try:
                port = int(arg)
            except ValueError:
                print("Cannot parse port: " + arg)
                sys.exit(1)

        elif opt == "-d":
            debug = True

        else:
            print("Unknown option " + opt)
            sys.exit(1)

    import logging
    from logging.handlers import RotatingFileHandler

    file_info_handler = RotatingFileHandler('info.log', maxBytes=1024 * 1024 * 100, backupCount=20)
    file_info_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_info_handler)

    file_error_handler = RotatingFileHandler('error.log', maxBytes=1024 * 1024 * 100, backupCount=20)
    file_error_handler.setLevel(logging.ERROR)
    app.logger.addHandler(file_error_handler)

    app.secret_key = "ljgq34jgqwihgq3poi" # TODO
    app.run(debug=debug, port=port, host="0.0.0.0")