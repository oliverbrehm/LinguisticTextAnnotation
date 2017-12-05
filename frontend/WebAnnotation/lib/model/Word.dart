import 'package:WebAnnotation/model/PartOfSpeech.dart';
import 'package:WebAnnotation/model/Syllable.dart';
import 'package:WebAnnotation/model/TextConfiguration.dart';

enum WordState {
  Ignored,
  LineBreak,
  Annotated,
  Unstressed,
  NotFound,
}

class Word {
  String text;

  // syllables in cleartext, containing umlaut and upper case letters
  List<Syllable> syllables = [];

  WordState state = WordState.Ignored;

  PartOfSpeech partOfSpeech = PartOfSpeechConfiguration.unknownPOS;
  String lemma = "";

  bool editing = false;

  Word(this.text);

  Map<String, bool> cssClasses = {};
  Map<String, String> styles = {};
  void updateStyles(TextConfiguration c) {
    cssClasses =  {
      'word': true,
      'popup': !isNotFound(),
      'unstressed': isIgnored(),
      'notFound': isNotFound(),
      partOfSpeech.posId: true
    };

    styles = {
      'margin-bottom': (c.line_height - 1.0).toString() + "em",
      'margin-right': c.word_distance.toString() + "em",
      'background-color': c.use_background ? c.word_background : "inherit",
    };

    bool previousAlternated = true;
    for(Syllable syllable in this.syllables) {
      bool isLastSyllable =
        (this.syllables.indexOf(syllable) == this.syllables.length - 1);
      bool alternate = (c.use_alternate_color && !syllable.stressed && !previousAlternated);

      syllable.updateStyles(c, this.isIgnored(), this.isUnstressed(), isLastSyllable, alternate);

      previousAlternated = (alternate || syllable.stressed);
    }
  }

  bool isEditable() {
    return this.state == WordState.Ignored
        || this.state == WordState.Annotated
        || this.state == WordState.Unstressed;
  }

  bool isIgnored() {
    return this.state == WordState.Ignored;
  }

  bool isUnstressed() {
    return this.state == WordState.Unstressed;
  }

  bool isAnnotated() {
    return this.state == WordState.Annotated;
  }

  bool isLineBreak() {
    return this.state == WordState.LineBreak;
  }

  bool isNotFound() {
    return this.state == WordState.NotFound;
  }

  void addSyllable(String text, bool stressed) {
    this.syllables.add(new Syllable(text, stressed));
  }

  bool hasStress() {
    for(Syllable s in syllables) {
      if(s.stressed) {
        return true;
      }
    }

    return false;
  }

  void removeStress() {
    for(Syllable s in syllables) {
      s.stressed = false;
    }
  }

  void setStressedSyllable(Syllable syllable) {
    for(Syllable s in this.syllables) {
      s.stressed = false;
    }

    if(syllable != null) {
      syllable.stressed = true;
    }
  }

  bool parseHyphenationUsingOriginalText(String hyphenation) {
    this.syllables = [];

    List<String> syllables = hyphenation.split("-");

    // use the given hyphenation as hint, but use the original text
    // in order to keep capitalization of original
    String remaining = this.text;
    for (int i = 0; i < syllables.length; i++) {
      String lookupSyllable = syllables[i];
      lookupSyllable = lookupSyllable.replaceAll("ae", "ä")
          .replaceAll("oe", "ö")
          .replaceAll("ue", "ü");

      String syllable = remaining; // default
      if(remaining.length >= lookupSyllable.length) {
        syllable = remaining.substring(0, lookupSyllable.length);
      }

      if (syllable.toLowerCase() != lookupSyllable) {
        // this should match, but if it does not, use lookup as fallback
        syllable = lookupSyllable;
      }

      if(remaining.length > lookupSyllable.length) {
        remaining = remaining.substring(lookupSyllable.length);
      } else {
        remaining = "";
      }

      if(syllable.length > 0) {
        this.addSyllable(syllable, false);
      }
    }

    return true;
  }

  bool parseHyphenation(String hyphenation) {
    this.syllables = [];

    List<String> syllables = hyphenation.split("-");

    for (String s in syllables) {
      if(s.length > 0) {
        this.addSyllable(s, false);
      }
    }

    return true;
  }

  bool parseStressPattern(String stressPattern) {
    if(stressPattern.length != syllables.length) {
      // stress pattern does not match number of syllables
      return false;
    }

    for (int i = 0; i < syllables.length; i++) {
      String c = stressPattern.substring(i, i + 1);
      bool stressed = (c == "1");
      if(stressed) {
        syllables[i].stressed = true;
        return true;
      }
    }

    // no stress found
    return true;
  }

  String getHyphenation() {
    String h = "";

    for (int i = 0; i < syllables.length; i++) {
      if(i > 0) {
        h += "-";
      }

      h += syllables[i].text;
    }

    return h;
  }

  String getStressPattern() {
    String s = "";

    for (int i = 0; i < syllables.length; i++) {
      if(syllables[i].stressed) {
        s += "1";
      } else {
        s += "0";
      }
    }

    return s;
  }
}