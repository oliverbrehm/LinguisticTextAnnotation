import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';

class UserEntry {
  int id;

  String text;
  String stressPattern;
  String hyphenation;

  UserEntry(this.id, this.text, this.stressPattern, this.hyphenation);

  static Future<bool> add(String text, String hyphenation,
      String stressPattern, var credentials) async {
    String url = AppService.SERVER_URL + "/user/word/add";

    var data = {
      'text': text,
      'hyphenation': hyphenation,
      'stress_pattern': stressPattern
    };
    data.addAll(credentials);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  static Future<List<UserEntry>> query(var credentials) async {
    String url = AppService.SERVER_URL + "/user/word/list";

    var data = credentials;

    return HttpRequest.postFormData(url, data).then((request) {
      var words = JSON.decode(request.response)['user_words'];

      List<UserEntry> userWords = [];

      for (var t in words) {
        int id = t['id'];
        String text = t['text'];
        String stress_pattern = t['stress_pattern'];
        String hyphenation = t['hyphenation'];

        userWords.add(new UserEntry(id, text, stress_pattern, hyphenation));
      }

      return userWords;
    }, onError: (error) {
      return null;
    });
  }

  Future<bool> delete(var credentials) async {
    String url = AppService.SERVER_URL + "/user/word/delete";

    var data = {
      'id': this.id.toString()
    };
    data.addAll(credentials);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }
}