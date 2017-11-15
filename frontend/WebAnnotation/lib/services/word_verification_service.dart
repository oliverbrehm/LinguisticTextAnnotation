import 'dart:convert';
import 'package:angular/core.dart';

import 'dart:async';
import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';
import 'package:WebAnnotation/services/model/UserText.dart';
import 'package:WebAnnotation/services/model/UserWord.dart';

/// service description
@Injectable()
class WordVerificationService {

  int numWords = -1;

  WordVerificationService();

  Future<String> getNextWord(var userData) async {
    String url = AppService.SERVER_URL + "/user/verification/query";

    return HttpRequest.postFormData(url, userData).then((request) {
      var response = JSON.decode(request.response);

      var word = response['word'];

      numWords = -1;
      if(response.containsKey('num_words')) {
        numWords = response['num_words'].toInt();
      }

      return word['text'];
    }, onError: (error) {
      return null;
    });
  }

  Future<bool> submitSegmentation(var userData, String word,
      String stressPattern, String hyphenation) async {

      var data =  {
        'word': word,
        'stress_pattern': stressPattern,
        'hyphenation': hyphenation
      };
      data.addAll(userData);

      String url = AppService.SERVER_URL + "/user/verification/submit";

      return HttpRequest.postFormData(url, data).then((request) {
        return true;
      }, onError: (error) {
        return false;
      });
  }
}