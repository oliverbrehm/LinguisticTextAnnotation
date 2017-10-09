import 'dart:async';
import 'dart:convert';

import 'package:angular/core.dart';

import 'dart:html';

class Syllable {
  String text;
  bool stressed;

  Syllable(this.text, this.stressed);
}

class Word {
  String text;

  bool unknown = false;
  bool punctuation = false;
  bool number = false;
  bool notFound = false;
  bool annotated = false;

  List<Syllable> syllables = [];

  Word(this.text);

  void addSyllable(String text, bool stressed) {
    this.syllables.add(new Syllable(text, stressed));
  }

  void parseSyllables(String hyphenation, String stressPattern) {
    List<String> syllables = hyphenation.split("-");

    if(stressPattern.length != syllables.length) {
      // stress pattern does not match number of syllables
      return;
    }

    for(int i = 0; i < syllables.length; i++) {
      String c = stressPattern.substring(i, i + 1);
      bool stressed =  c == "1";
      this.addSyllable(syllables[i], stressed);
    }
  }
}

class AnnotationText {
  String originalText;

  List<Word> words = new List<Word>();

  void addWord(Word word) {
    words.add(word);
  }
}

/// service description
@Injectable()
class TextAnalysisService {
  Future<String> lookupWord(String text) async {
    String url = "http://localhost:8000/queryWord/" + text;
    return HttpRequest.getString(url);
  }

  Future<AnnotationText> lookupText(String text) async {
    String url = "http://localhost:8000/queryText";

    var data = {'text': text};

    return HttpRequest.postFormData(url, data).then((request) {
      var response = JSON.decode(request.responseText);

      if(response == null) {
        return null;
      }

      AnnotationText annotatedText = new AnnotationText();

      for(var entry in response) {
        Word w = new Word(entry['word']);

        switch(entry['type']) {
          case 'unknown': w.unknown = true; break;
          case 'number': w.number = true; break;
          case 'punctuation': w.punctuation = true; break;
          case 'not_found': w.notFound = true; break;
          case 'annotated_word':
            w.annotated = true;
            var annotation = entry['annotation'];
            w.parseSyllables(annotation['hyphenation'], annotation['stress_pattern']);
            break;
          default: continue;
        }

        annotatedText.addWord(w);
      }

      annotatedText.originalText = text;

      return annotatedText;
    });
  }
}
