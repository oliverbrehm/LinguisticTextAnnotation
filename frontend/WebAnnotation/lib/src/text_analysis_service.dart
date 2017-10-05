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
  bool analyzed;

  List<Syllable> syllables = [];

  Word(this.text, this.analyzed);

  void addSyllable(String text, bool stressed) {
    this.syllables.add(new Syllable(text, stressed));
  }

  void parseSyllables(String hyphenation, String stressPattern) {
    List<String> syllables = hyphenation.split("-");

    if(stressPattern.length != syllables.length) {
      // stress pattern does not match number of syllables
      this.analyzed = false;
      return;
    }

    for(int i = 0; i < syllables.length; i++) {
      String c = stressPattern.substring(i, i + 1);
      bool stressed =  c == "1";
      this.addSyllable(syllables[i], stressed);
    }
  }
}

class Text {
  String originalText;

  List<Word> words;

  Text(this.words);
}

/// service description
@Injectable()
class TextAnalysisService {
  Future<String> lookupWord(String text) async {
    String url = "http://localhost:8000/queryWord/" + text;
    return HttpRequest.getString(url);
  }

  Future<Text> lookupText(String text) async {
    String url = "http://localhost:8000/queryText";

    var data = {'text': text};

    return HttpRequest.postFormData(url, data).then((request) {
      var response = JSON.decode(request.responseText);

      if(response == null) {
        return null;
      }

      List<Word> words = new List<Word>();

      for(var entry in response) {
        if(entry['type'] == 'not_found') {
          words.add(new Word(entry['data'], false));
        } else if(entry['type'] == 'annotated_word') {
          var data = entry['data'];
          Word w = new Word(data['text'], true);
          w.parseSyllables(data['hyphenation'], data['stress_pattern']);
          words.add(w);
        }
      }

      Text annotatedText = new Text(words);
      annotatedText.originalText = text;

      return annotatedText;
    });
  }
}
