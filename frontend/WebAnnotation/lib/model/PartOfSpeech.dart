enum POSPolicy {
  Annotate,
  Unstressed,
  Ignore
}

class PartOfSpeech {
  String name;
  String cssClassName;
  String color;

  List<String> posTags;

  POSPolicy policy;

  static PartOfSpeech withTag(String posTag) {
    for(PartOfSpeech pos in _availablePOS) {
      if(pos.posTags.contains(posTag)) {
        return pos;
      }
    }

    return unknownPOS();
  }

  static PartOfSpeech unknownPOS() {
    return _availablePOS[0];
  }

  PartOfSpeech(this.name, this.cssClassName, this.color, this.posTags, this.policy);

  static List<PartOfSpeech> _availablePOS = [
    new PartOfSpeech("Unbekannt", "pos-na" , "#000000", [""],POSPolicy.Annotate),
    new PartOfSpeech("Nomen", "pos-noun" , "#000000", ["NOUN"],POSPolicy.Annotate),
    new PartOfSpeech("Eigenname", "pos-propn", "#000000", ["PROPN"], POSPolicy.Annotate),
    new PartOfSpeech("Verb", "pos-verb", "#000000", ["VERB"], POSPolicy.Annotate),
    new PartOfSpeech("Hilfsverb", "pos-aux", "#000000", ["AUX"], POSPolicy.Annotate),
    new PartOfSpeech("Adjektiv", "pos-adj", "#000000", ["ADJ"], POSPolicy.Annotate),
    new PartOfSpeech("Adverb", "pos-adv", "#000000", ["ADV"], POSPolicy.Annotate),
    new PartOfSpeech("Artikel", "pos-det", "#000000", ["DET"], POSPolicy.Annotate),
    new PartOfSpeech("Adposition", "pos-adp", "#000000", ["ADP"], POSPolicy.Annotate),
    new PartOfSpeech("Pronomen", "pos-pron", "#000000", ["PRON"], POSPolicy.Annotate),
    new PartOfSpeech("Konjunktion", "pos-conj", "#000000", ["CONJ", "SCONJ"], POSPolicy.Annotate),
    new PartOfSpeech("Zahl", "pos-num", "#000000", ["NUM"], POSPolicy.Annotate),
    new PartOfSpeech("Partikel", "pos-part", "#000000", ["PART"], POSPolicy.Annotate),
  ];

  static List<PartOfSpeech> list() {
    return _availablePOS;
  }
}