import 'package:WebAnnotation/services/model/PartOfSpeech.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';

class AnnotationText {
  String originalText = "";

  List<Word> words = new List<Word>();

  Map<String, String> styles = {};
  void updateStyles(TextConfiguration c) {
    styles = {
      'font-size': c.font_size.toString() + "px",
      'letter-spacing' : c.letter_spacing.toString() + "px"
    };

    for(Word word in words) {
      word.updateStyles(c);
    }
  }

  void addWord(Word word) {
    words.add(word);
  }

  Word nextMissingWord() {
    for(Word w in this.words) {
      if(w.state == WordState.NotFound) {
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
        w.state = WordState.Annotated;
      }
    }
  }

  int numberOfUnknownWords() {
    int n = 0;

    for(Word w in this.words) {
      if(w.state == WordState.NotFound) {
        n++;
      }
    }

    return n;
  }

  Word previousWordTo(Word word) {
    Word previous;

    for(Word w in this.words) {
      if(w.state == WordState.NotFound) {
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
      if(w.state == WordState.NotFound) {
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

  void updatePOS(PartOfSpeech pos) {
    for (Word w in words) {
      if(w.partOfSpeech == pos) {
        switch(pos.policy) {
          case POSPolicy.Annotate:
            w.state = WordState.Annotated;
            break;
          case POSPolicy.Ignore:
            w.state = WordState.Ignored;
            break;
          case POSPolicy.Unstressed:
            w.state = WordState.Unstressed;
            break;
        }
      }
    }
  }
}