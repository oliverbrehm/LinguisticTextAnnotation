import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/model/common/Segmentation.dart';
import 'package:angular/core.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/segmentation_service.dart';

import 'package:WebAnnotation/model/text_annotation/Word.dart';

/// service description
@Injectable()
class SegmentationVerificationService extends SegmentationService {

  SegmentationVerificationService(): super();

  var userData = null;

  int _numWords = -1;
  Word verificationWord = null;
  int _wordId = -1;

  int numberOfVerificationWords() {
    return _numWords;
  }

  @override
  Future<bool> query() async {
    if(userData == null) {
      print('ERROR: set userData first');
      return false;
    }

    this.segmentations = [];

    String url = AppService.SERVER_URL + "/user/verification/query";

    return HttpRequest.postFormData(url, userData).then((request) {
      var response = JSON.decode(request.response);

      var word = response['word'];

      _numWords = -1;
      if(response.containsKey('num_words')) {
        _numWords = response['num_words'].toInt();
      }

      _wordId = -1;
      if(word.containsKey('id')) {
        _wordId = word['id'].toInt();
      }

      String wordText = word['text'];
      String hyphenation = word['hyphenation'];
      String stressPattern = word['stress_pattern'];
      String authorFirstName = word['user_first_name'];
      String authorLastName = word['user_last_name'];

      this.verificationWord = new Word.initialize(wordText, "", "");
      this.verificationWord.parseHyphenationUsingOriginalText(hyphenation);
      this.verificationWord.parseStressPattern(stressPattern);

      Segmentation s = new Segmentation(wordText, authorFirstName + " " + authorLastName, 'Benutzer', hyphenation, stressPattern);
      this.segmentations.add(s);

      var segmentationProposals = response['segmentations'];

      for(var proposal in segmentationProposals) {
        var s = new Segmentation(proposal['text'], proposal['origin']
            , proposal['source'], proposal['hyphenation'], proposal['stress_pattern']);
        this.segmentations.add(s);
      }

      return true;
    }, onError: (error) {
      // TODO check if 404 then no error, just empty list
      return false;
    });
  }

  Future<bool> submitVerification(var userData, Word segmentation) async {
    var data =  {
      'id': _wordId.toString(),
      'word': segmentation.text,
      'stress_pattern': segmentation.getStressPattern(),
      'hyphenation': segmentation.getHyphenation(),
      'lemma': segmentation.lemma
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