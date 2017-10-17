import 'package:angular/core.dart';

import 'dart:async';

import 'dart:html';

import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';

/// service description
@Injectable()
class UserAccountService {

  String email = "";
  String password = "";

  bool loggedIn = false;

  Map<String, String> appendCredentials(Map<String, String> data) {
    data['email'] = this.email;
    data['password'] = this.password;
    return data;
  }

  Future<bool> login(String email, String password) async {
    String url = AppService.SERVER_URL + "/user/login";

    var data = {'email': email, 'password': password};

    return HttpRequest.postFormData(url, data).then((request) {
      this.email = email;
      this.password = password;
      this.loggedIn = true;

      return true;
    }
    , onError: (error) {
      this.email = "";
      this.password = "";
      this.loggedIn = false;

      return false;
    });
  }

  Future<String> userList() async {
    if(!loggedIn) {
      return "";
    }

    String url = AppService.SERVER_URL + "/user/list";

    return HttpRequest.getString(url).then((s) {
      return s;
    });
  }

  Future<List<String>> queryTexts() async {
    if(!loggedIn) {
      return [];
    }

    String url = AppService.SERVER_URL + "/user/get_texts";

    var data = {};
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      return JSON.decode(request.response)['texts'];
    });
  }

  logout()  {
    this.email = "";
    this.password = "";
    this.loggedIn = false;
  }

  Future<bool> addText(String text) async {
    String url = AppService.SERVER_URL + "/user/add_text";

    var data = {'text': text};
    data = appendCredentials(data);

    //String authHeader = "Basic " + this.email + ":" + this.password;
    //return HttpRequest.request(url, method: 'POST', withCredentials: true, sendData: data, requestHeaders: {'Authorization': authHeader}).then((request) {
    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> register(String email, String password) async {
    String url = AppService.SERVER_URL + "/user/register";

    var data = {'email': email, 'password': password};

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

}