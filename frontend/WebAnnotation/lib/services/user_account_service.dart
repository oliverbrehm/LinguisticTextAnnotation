import 'package:angular/core.dart';

import 'dart:async';
import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';
import 'package:WebAnnotation/services/model/UserText.dart';
import 'package:WebAnnotation/services/model/UserWord.dart';

/// service description
@Injectable()
class UserAccountService {

  String email = "oliver";
  String password = "1234";
  bool loggedIn = true;

  List<UserText> userTexts = [];
  List<UserWord> userWords = [];
  List<TextConfiguration> textConfigurations = [];

  bool queryingTexts = false;
  bool queryingWords = false;
  bool queryingConfigurations = false;

  Map<String, String> credentials() {
    return {
      'email': this.email,
      'password': this.password
    };
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

    this.queryingTexts = true;

    return UserText.query(credentials()).then((textList) {
      this.queryingTexts = false;

      if(textList != null) {
        this.userTexts = textList;
        return true;
      }

      return false;
    });
  }

  Future<bool> addText(String title, String text) async {
    return UserText.add(title, text, credentials());
  }

  Future<bool> deleteText(UserText userText) async {
    return userText.delete(credentials()).then((success) {
      if(success) {
        this.userTexts.remove(userText);
        return true;
      }

      return false;
    });
  }

  //----------------------------------------------------------------------------
  // UserWord
  //----------------------------------------------------------------------------
  Future<bool> queryWords() async {
    if (!loggedIn) {
      return false;
    }

    this.queryingWords = true;

    return UserWord.query(credentials()).then((wordList) {
      this.queryingWords = false;

      if(wordList != null) {
        this.userWords = wordList;
        return true;
      }

      return false;
    });
  }

  Future<bool> addWord(String text, String hyphenation,
      String stressPattern) async {
    return UserWord.add(text, hyphenation, stressPattern, credentials());
  }

  Future<bool> deleteWord(UserWord userWord) async {
    return userWord.delete(credentials()).then((success) {
      if(success) {
        this.userWords.remove(userWord);
        return true;
      }

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

    this.queryingConfigurations = true;

    return TextConfiguration.queryTextConfigurations(credentials()).then((configurations) {
      this.queryingConfigurations = false;

      if(configurations != null) {
        this.textConfigurations = configurations;
        return true;
      }

      return false;
    });
  }

  Future<bool> addTextConfiguration(TextConfiguration configuration) async {
    return TextConfiguration.add(configuration, credentials());
  }

  Future<bool> updateTextConfiguration(TextConfiguration configuration) async {
    return configuration.update(credentials());
  }

  Future<bool> deleteTextConfiguration(TextConfiguration configuration) async {
    return configuration.delete(credentials());
  }
}