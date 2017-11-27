import 'package:WebAnnotation/services/model/Word.dart';

class AnnotationText {
  String originalText;

  List<Word> words = new List<Word>();

  void addWord(Word word) {
    words.add(word);
  }

  Word nextMissingWord() {
    for(Word w in this.words) {
      if(w.type == WordType.NotFound) {
        return w;
      }
    }

    return null;
  }

  void updateWord(String word, String hyphenation, String stressPattern) {
    for(Word w in this.words) {
      if(w.text == word) {
        w.parseHyphenationUsingOriginalText(hyphenation);
        w.parseStressPattern(stressPattern);
        w.type = WordType.Annotated;
      }
    }
  }

  int numberOfUnknownWords() {
    int n = 0;

    for(Word w in this.words) {
      if(w.type == WordType.NotFound) {
        n++;
      }
    }

    return n;
  }

  Word previousWordTo(Word word) {
    Word previous;

    for(Word w in this.words) {
      if(w.type == WordType.NotFound) {
        if(w == word) {
          return previous;
        }

        previous = w;
      }
    }

    return null;
  }

  Word nextWordTo(Word word) {
    bool found = false;

    for(Word w in this.words) {
      if(w.type == WordType.NotFound) {
        if(found) {
          return w;
        }

        if(w == word) {
          found = true;
        }
      }
    }

    return null;
  }

  void editWord(Word word) {
    for(Word w in words) {
      w.editing = false;
    }

    if(word != null) {
      word.editing = true;
    }
  }
}