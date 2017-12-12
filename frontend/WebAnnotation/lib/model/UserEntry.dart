import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/model/PartOfSpeech.dart';

class UserEntry {
  int id;

  String text;
  String stressPattern;
  String hyphenation;
  String lemma;
  String posId;

  UserEntry(this.id, this.text, this.stressPattern, this.hyphenation, this.lemma, this.posId);

  String posName() {
    String posName = PartOfSpeechConfiguration.defaultWithPosId(this.posId).name;
    return posName;
  }

  static Future<bool> add(String text, String hyphenation,
      String stressPattern, String pos, String lemma, var credentials) async {
    String url = AppService.SERVER_URL + "/user/word/add";

    var data = {
      'text': text,
      'hyphenation': hyphenation,
      'pos': pos,
      'lemma': lemma,
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
        String lemma = t['lemma'];
        String pos = t['pos'];

        userWords.add(new UserEntry(id, text, stress_pattern, hyphenation, lemma, pos));
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