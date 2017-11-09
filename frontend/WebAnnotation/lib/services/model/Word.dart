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

  bool parseSyllables(String hyphenation, String stressPattern) {
    List<String> syllables = hyphenation.split("-");

    if(stressPattern.length != syllables.length) {
      // stress pattern does not match number of syllables
      return false;
    }

    // use the given hyphenation as hint, but use the original text
    // in order to keep capitalization of original
    String remaining = this.text;
    for(int i = 0; i < syllables.length; i++) {
      String lookupSyllable = syllables[i];
      lookupSyllable = lookupSyllable.replaceAll("ae", "ä")
          .replaceAll("oe", "ö")
          .replaceAll("ue", "ü");

      String syllable = remaining.substring(0, lookupSyllable.length);

      if(syllable.toLowerCase() != lookupSyllable)  {
        // this should match, but if it does not, use lookup as fallback
        syllable = lookupSyllable;
      }

      remaining = remaining.substring(lookupSyllable.length);

      String c = stressPattern.substring(i, i + 1);
      bool stressed = (c == "1");
      this.addSyllable(syllable, stressed);
    }

    return true;
  }

  void clearType() {
    unknown = false;
    punctuation = false;
    number = false;
    notFound = false;
    annotated = false;
  }
}