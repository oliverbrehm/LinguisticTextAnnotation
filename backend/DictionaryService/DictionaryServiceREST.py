#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import getopt
import json

from DictionaryService import DictionaryService

from flask import Flask, request
from flask import Response

app = Flask(__name__)  # Initialize flask

service = DictionaryService()


def create_response(code, data={}):
    string = json.dumps(data)
    response = Response(response=string, status=code, mimetype="application/json")
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response


def create_error_response(errcode, message):
    return create_response(errcode, {"error":str(message)})


'''
@app.route('/packetStatus/<packetId>', methods=['GET'])
def restPacketStatus(packetId):
    if not packet_regex.regex_matches_exactly(packet_regex.regex_id, packetId):
        return create_invalid_key_error(packetId)

    res = tracking_service.packetStatus(packetId)
    if res is None:
        return rest_common.create_error_response(404, "Packet not found")
    else:
        return rest_common.create_response(200, res)


@app.route('/packetStatus/', methods=['GET'])
def invalidPacketId():
    return create_invalid_key_error()
'''


@app.route('/', methods=['GET'])
def say_hello():
    # return create_response(create_response(200, "Hello dictionary service."))
    return "Hello dictionary service"


@app.route('/queryWord/<text>', methods=['GET'])
def query_word(text):
    response = service.query_word(text)
    print(response)
    if response is None:
        return create_error_response(404, "Word not found.")
    else:
        return create_response(200, response)


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

    app.run(debug=True, port=port, host="0.0.0.0")