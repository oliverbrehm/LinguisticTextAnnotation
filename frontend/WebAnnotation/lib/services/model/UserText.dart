import 'package:WebAnnotation/app_service.dart';

import 'dart:async';
import 'dart:html';
import 'dart:convert';


class UserText {
  int id;

  String title;
  String text;

  bool expanded = false;

  void toggle() {
    expanded = !expanded;
  }

  UserText(this.id, this.title, this.text);

  static Future<List<UserText>> query(var data) async {
    String url = AppService.SERVER_URL + "/user/text/list";

    return HttpRequest.postFormData(url, data).then((request) {
      var texts = JSON.decode(request.response)['texts'];

      List<UserText> userTexts = [];

      for (var t in texts) {
        int id = t['id'];
        String title = t['title'];
        String text = t['text'];

        userTexts.add(new UserText(id, title, text));
      }

      return userTexts;
    }, onError: (error) {
      return null;
    });
  }

  static Future<bool> add(String title, String text, var credentials) async {
    String url = AppService.SERVER_URL + "/user/text/add";

    var data = {
      'title': title,
      'text': text
    };
    data.addAll(credentials);

    //String authHeader = "Basic " + this.email + ":" + this.password;
    //return HttpRequest.request(url, method: 'POST', withCredentials: true, sendData: data, requestHeaders: {'Authorization': authHeader}).then((request) {
    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> delete(var credentials) async {
    String url = AppService.SERVER_URL + "/user/text/delete";

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