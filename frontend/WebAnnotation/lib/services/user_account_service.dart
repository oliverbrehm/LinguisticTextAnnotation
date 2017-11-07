import 'package:angular/core.dart';

import 'dart:async';

import 'dart:html';

import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';

class UserText {
  int id;

  String title;
  String text;

  bool expanded = false;

  void toggle() {
    expanded = !expanded;
  }

  UserText(this.id, this.title, this.text);
}

class UserWord {
  int id;

  String text;
  String stressPattern;
  String hyphenation;

  UserWord(this.id, this.text, this.stressPattern, this.hyphenation);
}

class TextConfiguration {
  int id;

  String name;

  String stressed_color;
  String unstressed_color;

  double line_height;

  TextConfiguration(this.id, this.name, this.stressed_color, this.unstressed_color, this.line_height);

  TextConfiguration.copy(TextConfiguration c) {
    this.id = c.id;
    this.name = c.name;
    this.stressed_color = c.stressed_color;
    this.unstressed_color = c.unstressed_color;
    this.line_height = c.line_height;
  }
}

/// service description
@Injectable()
class UserAccountService {

  String email = "oliver";
  String password = "1234";
  bool loggedIn = true;

  List<UserText> userTexts = [];
  List<UserWord> userWords = [];
  List<TextConfiguration> textConfigurations = [];

  Map<String, String> appendCredentials(Map<String, String> data) {
    if (loggedIn) {
      data['email'] = this.email;
      data['password'] = this.password;
    }
    return data;
  }

  //----------------------------------------------------------------------------
  // User
  //----------------------------------------------------------------------------

  Future<bool> register(String email, String password) async {
    String url = AppService.SERVER_URL + "/user/register";

    var data = {'email': email, 'password': password};

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> login(String email, String password) async {
    String url = AppService.SERVER_URL + "/user/authenticate";

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

  void logout() {
    this.email = "";
    this.password = "";
    this.loggedIn = false;
  }

  Future<String> userList() async {
    if (!loggedIn) {
      return "";
    }

    String url = AppService.SERVER_URL + "/user/list";

    return HttpRequest.getString(url).then((s) {
      return s;
    });
  }

  //----------------------------------------------------------------------------
  // UserText
  //----------------------------------------------------------------------------

  Future<bool> queryTexts() async {
    if (!loggedIn) {
      return false;
    }

    String url = AppService.SERVER_URL + "/user/text/list";

    var data = {};
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      var texts = JSON.decode(request.response)['texts'];

      this.userTexts = [];

      for (var t in texts) {
        int id = t['id'];
        String title = t['title'];
        String text = t['text'];

        this.userTexts.add(new UserText(id, title, text));
      }

      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> addText(String title, String text) async {
    String url = AppService.SERVER_URL + "/user/text/add";

    var data = {
      'title': title,
      'text': text
    };
    data = appendCredentials(data);

    //String authHeader = "Basic " + this.email + ":" + this.password;
    //return HttpRequest.request(url, method: 'POST', withCredentials: true, sendData: data, requestHeaders: {'Authorization': authHeader}).then((request) {
    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> deleteText(UserText userText) async {
    String url = AppService.SERVER_URL + "/user/text/delete";

    var data = {
      'id': userText.id.toString()
    };
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      this.userTexts.remove(userText);
      return true;
    }, onError: (error) {

      return false;
    });
  }

  //----------------------------------------------------------------------------
  // UserWord
  //----------------------------------------------------------------------------
  Future<bool> addWord(String text, String hyphenation,
      String stressPattern) async {
    String url = AppService.SERVER_URL + "/user/word/add";

    var data = {
      'text': text,
      'hyphenation': hyphenation,
      'stress_pattern': stressPattern
    };
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> queryWords() async {
    if (!loggedIn) {
      return false;
    }

    String url = AppService.SERVER_URL + "/user/word/list";

    var data = {};
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      var words = JSON.decode(request.response)['user_words'];

      this.userWords = [];

      for (var t in words) {
        int id = t['id'];
        String text = t['text'];
        String stress_pattern = t['stress_pattern'];
        String hyphenation = t['hyphenation'];

        this.userWords.add(new UserWord(id, text, stress_pattern, hyphenation));
      }

      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> deleteWord(UserWord userWord) async {
    String url = AppService.SERVER_URL + "/user/word/delete";

    var data = {
      'id': userWord.id.toString()
    };
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      this.userWords.remove(userWord);
      return true;
    }, onError: (error) {
      return false;
    });
  }

  //----------------------------------------------------------------------------
  // TextConfiguration
  //----------------------------------------------------------------------------
  Future<bool> queryTextConfigurations() async {
    if (!loggedIn) {
      return false;
    }

    String url = AppService.SERVER_URL + "/user/configuration/list";

    var data = {};
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      var configurations = JSON.decode(request.response)['configurations'];

      textConfigurations = [];

      for (var c in configurations) {
        int id = c['id'];
        String name = c['name'];
        String stressed_color = c['stressed_color'];
        String unstressed_color = c['unstressed_color'];
        double line_height = c['line_height'];
        
        textConfigurations.add(new TextConfiguration(id, name, stressed_color, unstressed_color, line_height));
      }

      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> addTextConfiguration(TextConfiguration configuration) async {
    if (!loggedIn) {
      return false;
    }

    String url = AppService.SERVER_URL + "/user/configuration/add";

    var data = {
      'name': configuration.name,
      'stressed_color': configuration.stressed_color,
      'unstressed_color': configuration.unstressed_color,
      'line_height': configuration.line_height.toString()
    };
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> updateTextConfiguration(TextConfiguration configuration) async {
    if (!loggedIn) {
      return false;
    }

    String url = AppService.SERVER_URL + "/user/configuration/update";

    var data = {
      'id': configuration.id.toString(),
      'name': configuration.name,
      'stressed_color': configuration.stressed_color,
      'unstressed_color': configuration.unstressed_color,
      'line_height': configuration.line_height.toString()
    };
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> deleteTextConfiguration(TextConfiguration configuration) async {
    if (!loggedIn) {
      return false;
    }

    String url = AppService.SERVER_URL + "/user/configuration/delete";

    var data = {
      'id': configuration.id.toString()
    };
    data = appendCredentials(data);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }
}