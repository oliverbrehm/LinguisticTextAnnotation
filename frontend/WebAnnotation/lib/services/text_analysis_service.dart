import 'dart:async';
import 'dart:convert';

import 'package:angular/core.dart';

import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/model/AnnotationText.dart';

abstract class TextAnalysisObserver {
  void update();
}

/// service description
@Injectable()
class TextAnalysisService {

  List<TextAnalysisObserver> observers = [];

  bool analyzing = false;

  String lookupText = '';

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
          case 'unknown': w.type = WordType.Ignored; break;
          case 'number': w.type = WordType.Number; break;
          case 'punctuation': w.type = WordType.Punctuation; break;
          case 'not_found': w.type = WordType.NotFound; break;
          case 'annotated_word':
            var annotation = entry['annotation'];
            if(w.parseHyphenationUsingOriginalText(annotation['hyphenation'])
                && w.parseStressPattern(annotation['stress_pattern'])) {
              w.type = WordType.Annotated;
            } else {
              w.type = WordType.NotFound;
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

  void addObserver(TextAnalysisObserver observer) {
    this.observers.add(observer);
  }

  void clearText() {
    annotatedText = null;
  }

  void applyCurrentConfiguration() {
    new Future.delayed(const Duration(microseconds: 100), () {
      resetColors();

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
        if(selectedConfiguration.use_background) {
          querySelectorAll(".stressed").style.backgroundColor = selectedConfiguration.word_background;
          querySelectorAll(".unstressed").style.backgroundColor = selectedConfiguration.word_background;
        }
      } else {
        querySelectorAll(".stressed").style.backgroundColor =
            selectedConfiguration.stressed_color;
        querySelectorAll(".unstressed").style.backgroundColor =
            selectedConfiguration.unstressed_color;
      }

      if(selectedConfiguration.use_background) {
        querySelectorAll(".word").style.backgroundColor =
            selectedConfiguration.word_background;
      }

      for(TextAnalysisObserver o in this.observers) {
        o.update();
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
