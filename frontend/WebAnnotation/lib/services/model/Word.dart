enum WordType {
  Ignored,
  Annotated,
  Unstressed,
  NotFound,
}

class Syllable {
  String text;
  bool stressed;

  Syllable(this.text, this.stressed);
}

class Word {
  String text;

  // syllables in cleartext, containing umlaut and upper case letters
  List<Syllable> syllables = [];

  WordType type = WordType.Ignored;

  String partOfSpeech = "";
  String lemma = "";

  bool editing = false;

  Word(this.text);

  String getCssPosClass() {
    switch(partOfSpeech) {
      case "NOUN":
        return "pos-noun";
      case "PROPN":
        return "pos-propn";
      case "VERB":
        return "pos-verb";
      case "AUX":
        return "pos-aux";
      case "ADJ":
        return "pos-adj";
      case "ADV":
        return "pos-adv";
      case "ADP":
        return "pos-adp";
      case "DET":
        return "pos-det";
      case "PRON":
        return "pos-pron";
      case "CONJ":
        return "pos-conj";
      case "SCONJ":
        return "pos-conj";
      case "PART":
        return "pos-part";
      case "NUM":
        return "pos-num";
      default:
        return "";
    }
  }

  Map<String, bool> cssClasses = {};

  void updateCssClasses() {
    cssClasses =  {
      'word': true,
      'popup': !isNotFound(),
      'unstressed': isIgnored(),
      'notFound': isNotFound(),
      getCssPosClass(): true
    };
  }

  bool isIgnored() {
    return this.type == WordType.Ignored;
  }

  bool isAnnotated() {
    return this.type == WordType.Annotated;
  }

  bool isUnstressed() {
    return this.type == WordType.Unstressed;
  }

  bool isNotFound() {
    return this.type == WordType.NotFound;
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
    print("parseHyphenationUsingOriginalText");
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

      print("lookupSyllable: " + lookupSyllable);

      String syllable = remaining; // default
      if(remaining.length >= lookupSyllable.length) {
        syllable = remaining.substring(0, lookupSyllable.length);
      }

      print("syllable: " + syllable);

      if (syllable.toLowerCase() != lookupSyllable) {
        // this should match, but if it does not, use lookup as fallback
        syllable = lookupSyllable;
      }

      if(remaining.length > lookupSyllable.length) {
        remaining = remaining.substring(lookupSyllable.length);
      } else {
        remaining = "";
      }

      print("remaining: " + remaining);

      if(syllable.length > 0) {
        this.addSyllable(syllable, false);
      }
    }

    return true;
  }

  bool parseHyphenation(String hyphenation) {
    print("parseHyphenation");
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