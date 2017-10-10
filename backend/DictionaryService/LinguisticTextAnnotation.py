#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import getopt
import json
import hashlib

from DictionaryService import DictionaryService
from UserService import UserService, User

from flask import Flask, request
from flask import Response

from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)

auth = HTTPBasicAuth()

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


@auth.get_password
def get_pw(username):
    user = userService.get_user(username)

    if user:
        return user.password

    return None


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
    response = dictionaryService.query_word(text)
    if response is None:
        return create_error_response(404, "Word not found.")

    return create_response(200, response)


@app.route('/queryText', methods=['POST'])
def query_text():
    text = request.form.get("text")
    response = dictionaryService.query_text(text)

    if response is None:
        # TODO status code
        return create_error_response(404, "Error analyzing text.")

    return create_response(200, response)


@app.route('/user/register', methods=['POST'])
def user_register():
    email = request.form.get("email")
    password = request.form.get("password")

    if not email or not password:
        return create_error_response(404, "Email or password not provided.")  # TODO check code

    response = userService.register(email, password)

    if not response:
        create_error_response(404, "User already existing")

    return create_response(200)


@app.route('/user/login', methods=['POST'])
def user_login():
    email = request.form.get("email")
    password = request.form.get("password")

    if not email or not password:
        return create_error_response(404, "Email or password not provided.")  # TODO check code

    user = userService.login(email, password)

    if not user:
        return create_error_response(404, "Wrong email or password")  # TODO check code (forbidden?)

    return create_response(200)


@app.route('/user/add_text', methods=['POST'])
@auth.login_required
def user_add_text():
    text = request.form.get("text")

    if not text:
        return create_error_response(404, "Text not provided.")  # TODO check code

    user: User = userService.get_user(auth.username())

    if not userService.add_text(user, text):
        return create_error_response(404, "Error adding text")  # TODO check code

    return create_response(200)


@app.route('/user/get_texts', methods=['GET'])
@auth.login_required
def user_get_texts():
    user: User = userService.get_user(auth.username())

    texts = userService.get_texts(user)

    if not texts:
        return create_error_response(404, "Error getting texts")  # TODO check code, error message

    return create_response(200, {'texts': texts})


@app.route('/user/list', methods=['GET'])
def user_list():
    print("session: ", request.cookies.get('session'))
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
    app.run(debug=True, port=port, host="dev.localhost")