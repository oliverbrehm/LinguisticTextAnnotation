enum POSPolicy {
  Annotate,
  Unstressed,
  Ignore
}

class PartOfSpeech {
  String name;
  String posId;

  List<String> posTags;

  POSPolicy policy;

  PartOfSpeech(this.name, this.posId, this.posTags, this.policy);

  json() {
    String policy = "";
    switch(this.policy) {
      case POSPolicy.Annotate:
        policy = 'annotate';
        break;
      case POSPolicy.Unstressed:
        policy = 'unstressed';
        break;
      case POSPolicy.Ignore:
        policy = 'ignore';
        break;
    }

    return  {
      'posId': this.posId,
      'policy': policy
    };
  }
}

class PartOfSpeechConfiguration {
  List<PartOfSpeech> _posItems = [
    new PartOfSpeech("Nomen", "pos-noun", ["NOUN"],POSPolicy.Annotate),
    new PartOfSpeech("Eigenname", "pos-propn", ["PROPN"], POSPolicy.Annotate),
    new PartOfSpeech("Verb", "pos-verb", ["VERB"], POSPolicy.Annotate),
    new PartOfSpeech("Hilfsverb", "pos-aux", ["AUX"], POSPolicy.Annotate),
    new PartOfSpeech("Adjektiv", "pos-adj", ["ADJ"], POSPolicy.Annotate),
    new PartOfSpeech("Adverb", "pos-adv", ["ADV"], POSPolicy.Annotate),
    new PartOfSpeech("Artikel", "pos-det", ["DET"], POSPolicy.Annotate),
    new PartOfSpeech("Adposition", "pos-adp", ["ADP"], POSPolicy.Annotate),
    new PartOfSpeech("Pronomen", "pos-pron", ["PRON"], POSPolicy.Annotate),
    new PartOfSpeech("Konjunktion", "pos-conj", ["CONJ", "SCONJ"], POSPolicy.Annotate),
    new PartOfSpeech("Zahl", "pos-num", ["NUM"], POSPolicy.Annotate),
    new PartOfSpeech("Partikel", "pos-part", ["PART"], POSPolicy.Annotate),
    unknownPOS
  ];

  PartOfSpeech withTag(String posTag) {
    for(PartOfSpeech pos in _posItems) {
      if(pos.posTags.contains(posTag)) {
        return pos;
      }
    }

    return unknownPOS;
  }

  static PartOfSpeech unknownPOS = new PartOfSpeech("Unbekannt", "pos-na", [""],POSPolicy.Annotate);

  void setPartOfSpeech(String posId, String policy) {
    for(PartOfSpeech pos in this._posItems) {
      if(pos.posId == posId) {
        switch(policy) {
          case 'annotate':
            pos.policy = POSPolicy.Annotate;
            break;
          case 'unstressed':
            pos.policy = POSPolicy.Unstressed;
            break;
          case 'ignore':
            pos.policy = POSPolicy.Ignore;
            break;
          default:
            return;
        }
      }
    }
  }

  List<PartOfSpeech> list() {
    return _posItems;
  }

  json() {
    var ret = [];
    for(PartOfSpeech pos in _posItems) {
      ret.add(pos.json());
    }

    return ret;
  }
}

