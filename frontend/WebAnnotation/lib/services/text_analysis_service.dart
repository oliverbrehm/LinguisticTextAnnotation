import 'dart:async';
import 'dart:convert';

import 'package:angular/core.dart';

import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/model/AnnotationText.dart';

/// service description
@Injectable()
class TextAnalysisService {

  bool analyzing = false;

  String lookupText = 'Kreidefelsen sind wahnsinnig toll.';

  AnnotationText annotatedText;

  TextConfiguration selectedConfiguration = new TextConfiguration(-1, "",
      '#4DE8D0', '#FFEBCD', '#FFFFFF', 16.0, 1.5, 0.2, 0.4, false, false, true);

  Future<bool> lookup(var userData) async {
    String url = AppService.SERVER_URL + "/query/text";

    var data = userData;
    data['text'] = lookupText;

    analyzing = true;

    return HttpRequest.postFormData(url, data).then((request) {
      analyzing = false;

      var response = JSON.decode(request.responseText);

      if(response == null) {
        return false;
      }

      this.annotatedText = new AnnotationText();

      for(var entry in response) {
        Word w = new Word(entry['text']);

        switch(entry['type']) {
          case 'unknown': w.unknown = true; break;
          case 'number': w.number = true; break;
          case 'punctuation': w.punctuation = true; break;
          case 'not_found': w.notFound = true; break;
          case 'annotated_word':
            var annotation = entry['annotation'];
            if(w.parseSyllables(annotation['hyphenation'], annotation['stress_pattern'])) {
              w.annotated = true;
            } else {
              w.notFound = true;
            }
            break;
          default: continue;
        }

        annotatedText.addWord(w);
      }

      annotatedText.originalText = lookupText;

      return true;
    }, onError: (error) {
      analyzing = false;
      return false;
    });
  }

  void clearText() {
    annotatedText = null;
  }

  void applyCurrentConfiguration() {
    new Future.delayed(const Duration(microseconds: 100), () {
      querySelectorAll(".word").style.fontSize =
          selectedConfiguration.font_size.toString() + "px";
      querySelectorAll(".word").style.marginBottom =
          (selectedConfiguration.line_height - 1.0).toString() + "em";
      querySelectorAll(".word").style.marginRight =
          selectedConfiguration.word_distance.toString() + "em";
      querySelectorAll(".syllable").style.marginRight =
          selectedConfiguration.syllable_distance.toString() + "em";

      if(selectedConfiguration.stressed_bold) {
        querySelectorAll(".stressed").style.fontWeight = 'bold';
      } else {
        querySelectorAll(".stressed").style.fontWeight = 'normal';
      }

      if(selectedConfiguration.highlight_foreground) {
        querySelectorAll(".stressed").style.color =
            selectedConfiguration.stressed_color;
        querySelectorAll(".unstressed").style.color =
            selectedConfiguration.unstressed_color;
      } else {
        querySelectorAll(".stressed").style.backgroundColor =
            selectedConfiguration.stressed_color;
        querySelectorAll(".unstressed").style.backgroundColor =
            selectedConfiguration.unstressed_color;
      }

      if(selectedConfiguration.use_background) {
        querySelectorAll(".word").style.backgroundColor =
            selectedConfiguration.word_background;
      } else {
        querySelectorAll(".word").style.backgroundColor = '#FFFFFF';
      }
    });
  }

  void resetColors() {
    querySelectorAll(".stressed").style.backgroundColor = '#FFFFFF';
    querySelectorAll(".unstressed").style.backgroundColor = '#FFFFFF';
    querySelectorAll(".word").style.backgroundColor = '#FFFFFF';

    querySelectorAll(".stressed").style.color = '#000000';
    querySelectorAll(".unstressed").style.color = '#000000';
  }
}
