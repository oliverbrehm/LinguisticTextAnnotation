import 'package:WebAnnotation/services/model/Word.dart';

class AnnotationText {
  String originalText;

  List<Word> words = new List<Word>();

  void addWord(Word word) {
    words.add(word);
  }

  Word nextMissingWord() {
    for(Word w in this.words) {
      if(w.notFound) {
        return w;
      }
    }

    return null;
  }

  void updateWord(String word, String hyphenation, String stressPattern) {
    for(Word w in this.words) {
      if(w.text == word) {
        w.parseSyllables(hyphenation, stressPattern);
        w.clearType();
        w.annotated = true;
      }
    }
  }

  int numberOfUnknownWords() {
    int n = 0;

    for(Word w in this.words) {
      if(w.notFound) {
        n++;
      }
    }

    return n;
  }

  String previousWordTo(String word) {
    String previous;

    for(Word w in this.words) {
      if(w.notFound) {
        if(w.text == word) {
          return previous;
        }

        previous = w.text;
      }
    }

    return null;
  }

  String nextWordTo(String word) {
    bool found = false;

    for(Word w in this.words) {
      if(w.notFound) {
        if(found) {
          return w.text;
        }

        if(w.text == word) {
          found = true;
        }
      }
    }

    return null;
  }
}