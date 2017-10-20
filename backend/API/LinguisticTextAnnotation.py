#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import getopt
import json

from DictionaryService import DictionaryService
from UserService import UserService, Authentication

from flask import Flask, request
from flask import Response


app = Flask(__name__)

dictionaryService = DictionaryService()
userService = UserService()


def create_response(code, data={}):
    string = json.dumps(data)
    response = Response(response=string, status=code, mimetype="application/json")
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    response.headers['Access-Control-Max-Age'] = 1000
    # note that '*' is not valid for Access-Control-Allow-Headers
    response.headers['Access-Control-Allow-Headers'] = 'origin, x-csrftoken, content-type, accept'
    return response


def create_error_response(errcode, message):
    return create_response(errcode, {"error":str(message)})


@app.route('/', methods=['GET'])
def say_hello():
    # return create_response(create_response(200, "Hello dictionary service."))
    return "Dictionary service\n" \
           "------------------\n" \
           "Available routes:\n" \
           "GET queryWord/<text>\n" \
           "POST queryText, <text>"


@app.route('/queryWord/<text>', methods=['GET'])
def query_word(text):
    user = userService.authenticate(Authentication.read(request))
    # TODO better method than to pass userService as a parameter?
    response = dictionaryService.query_word(text, userService, user)
    if response is None:
        return create_error_response(404, "Word not found.")

    return create_response(200, response)


@app.route('/queryText', methods=['POST'])
def query_text():
    user = userService.authenticate(Authentication.read(request))
    text = request.form.get("text")

    # TODO better method than to pass userService as a parameter?
    response = dictionaryService.query_text(text, userService, user)

    if response is None:
        # TODO status code
        return create_error_response(404, "Error analyzing text.")

    return create_response(200, response)


@app.route('/user/add_word', methods=['POST'])
def user_add_word():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    text = request.form.get("text")
    stress_pattern = request.form.get("stress_pattern")
    hyphenation = request.form.get("hyphenation")

    if not text or not stress_pattern or not hyphenation:
        return create_error_response(404, "Data not provided.")

    success = userService.add_word(user, text, stress_pattern, hyphenation)

    if not success:
        return create_error_response(404, "Error adding word.")

    return create_response(200)


@app.route('/user/configuration/add', methods=['POST'])
def user_add_configuration():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    name = request.form.get("name")
    stressed_color = request.form.get("stressed_color")
    unstressed_color = request.form.get("unstressed_color")
    line_height = request.form.get("line_height")

    if not name or not stressed_color or not unstressed_color or not line_height:
        return create_error_response(404, "Data not provided.")

    success = userService.add_configuration(user, name, stressed_color, unstressed_color, line_height)

    if not success:
        return create_error_response(404, "Error adding configuration.")

    return create_response(200)


@app.route('/user/configuration/list', methods=['POST'])
def user_get_configurations():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    configurations = userService.get_configurations(user)

    return create_response(200, {'configurations': configurations})


@app.route('/user/register', methods=['POST'])
def user_register():
    email = request.form.get("email")
    password = request.form.get("password")

    if not email or not password:
        return create_error_response(404, "Email or password not provided.")  # TODO check code

    response = userService.register(email, password)

    if not response:
        return create_error_response(404, "User already existing")

    return create_response(200)


@app.route('/user/login', methods=['POST'])
def user_login():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    return create_response(200)


@app.route('/user/text/add', methods=['POST'])
def user_add_text():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    text = request.form.get("text")

    if not text:
        return create_error_response(404, "Text not provided.")  # TODO check code

    if not userService.add_text(user, text):
        return create_error_response(404, "Error adding text")  # TODO check code

    return create_response(200)


@app.route('/user/text/list', methods=['POST'])
def user_get_texts():
    user = userService.authenticate(Authentication.read(request))
    if not user: return create_error_response(401, "Invalid credentials.")

    texts = userService.get_texts(user)

    return create_response(200, {'texts': texts})


@app.route('/user/list', methods=['GET'])
def user_list():
    return create_response(200, userService.list())


def print_help():
    print("Options:\n\t-p Port to use")


if __name__ == '__main__':
    port = 0
    try:
        options, args = getopt.getopt(sys.argv[1:], "p:")
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
        else:
            print("Unknown option " + opt)
            sys.exit(1)

    app.secret_key = "ljgq34jgqwihgq3poi" # TODO
    app.run(debug=True, port=port, host="0.0.0.0")