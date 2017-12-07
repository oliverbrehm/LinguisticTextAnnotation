import 'dart:async';
import 'dart:convert';

import 'package:WebAnnotation/model/PartOfSpeech.dart';
import 'package:WebAnnotation/model/Syllable.dart';
import 'package:angular/core.dart';

import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/model/TextConfiguration.dart';
import 'package:WebAnnotation/model/Word.dart';
import 'package:WebAnnotation/model/AnnotationText.dart';

abstract class TextAnalysisObserver {
  void textUpdated();
}

/// service description
@Injectable()
class TextAnalysisService {

  List<TextAnalysisObserver> observers = [];

  bool analyzing = false;

  String lookupText = '';

  AnnotationText annotatedText;

  TextConfiguration selectedConfiguration = new TextConfiguration(-1, "",
      '#4DE8D0', '#FFEBCD', '#FFFFFF', '#F4D1A8', '|', 16.0, 1.5, 0.2, 0.4, 0.0,
      false, false, true, true, true, new PartOfSpeechConfiguration());

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

        // default annotation, overwritten if type == annotated_word
        w.parseHyphenationUsingOriginalText(w.text);
        w.parseStressPattern("0");

        switch(entry['type']) {
          case 'ignored': w.state = WordState.Ignored; break;
          case 'linebreak': w.state = WordState.LineBreak; break;
          case 'not_found': w.state = WordState.NotFound; break;
          case 'annotated_word':
            var annotation = entry['annotation'];
            if(w.parseHyphenationUsingOriginalText(annotation['hyphenation'])
                && w.parseStressPattern(annotation['stress_pattern'])) {
              w.state = WordState.Annotated;
            } else {
              w.state = WordState.NotFound;
            }
            break;
          default:
             w.state = WordState.Ignored; break;
        }

        if(entry.containsKey("pos")) {
          w.posId = selectedConfiguration.partOfSpeechConfiguration.withTag(entry['pos']).posId;
        }

        if(entry.containsKey("lemma")) {
          w.lemma = entry['lemma'];
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

  void updatePOS() {
    annotatedText.updatePOS(this.selectedConfiguration);
  }

  void applyCurrentConfiguration() {
    new Future.delayed(const Duration(microseconds: 10), () {
      this.annotatedText.updateStyles(selectedConfiguration);
      this.textUpdated();
    });
  }

  void textUpdated() {
    for(TextAnalysisObserver o in this.observers) {
      o.textUpdated();
    }
  }

  void applyToAllWords(Word word) {
    for(Word w in this.annotatedText.words) {
      if(w != word && w.text == word.text) {
        w.syllables = [];

        for(Syllable s in word.syllables) {
          w.addSyllable(s.text, s.stressed);
        }

        w.updateStyles(this.selectedConfiguration);
      }
    }
  }
}
