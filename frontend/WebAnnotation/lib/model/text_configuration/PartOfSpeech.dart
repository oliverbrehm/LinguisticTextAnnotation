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
      'pos_id': this.posId,
      'policy': policy
    };
  }
}

class PartOfSpeechConfiguration {
  static PartOfSpeechConfiguration defaultConfiguration = new PartOfSpeechConfiguration();

  List<PartOfSpeech> _posItems = [
    new PartOfSpeech("Nomen", "noun", ["noun", "NOUN"],POSPolicy.Annotate),
    new PartOfSpeech("Eigenname", "propn", ["propn", "PROPN"], POSPolicy.Annotate),
    new PartOfSpeech("Verb", "verb", ["verb", "VERB"], POSPolicy.Annotate),
    new PartOfSpeech("Hilfsverb", "aux", ["aux", "AUX"], POSPolicy.Annotate),
    new PartOfSpeech("Adjektiv", "adj", ["adj", "ADJ"], POSPolicy.Annotate),
    new PartOfSpeech("Adverb", "adv", ["adv", "ADV"], POSPolicy.Annotate),
    new PartOfSpeech("Artikel", "det", ["det", "DET"], POSPolicy.Annotate),
    new PartOfSpeech("Adposition", "adp", ["adp", "ADP"], POSPolicy.Annotate),
    new PartOfSpeech("Pronomen", "pron", ["pron", "PRON"], POSPolicy.Annotate),
    new PartOfSpeech("Konjunktion", "conj", ["conj", "CONJ", "SCONJ"], POSPolicy.Annotate),
    new PartOfSpeech("Zahl", "num", ["num", "NUM"], POSPolicy.Annotate),
    new PartOfSpeech("Partikel", "part", ["part", "PART"], POSPolicy.Annotate),
    unknownPOS()
  ];

  static defaultWithPosId(String posId) {
    return defaultConfiguration.withPosId(posId);
  }

  PartOfSpeech withTag(String posTag) {
    for(PartOfSpeech pos in _posItems) {
      if(pos.posTags.contains(posTag)) {
        return pos;
      }
    }

    return unknownPOS();
  }

  PartOfSpeech withPosId(String posId) {
    for(PartOfSpeech pos in _posItems) {
      if(pos.posId == posId) {
        return pos;
      }
    }

    return unknownPOS();
  }

  static PartOfSpeech unknownPOS() {
    return new PartOfSpeech("Unbekannt", "na", [""], POSPolicy.Annotate);
  }

  void setPartOfSpeechPolicyString(String posId, String policy) {
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

  void setPartOfSpeechPolicy(String posId, POSPolicy policy) {
    for(PartOfSpeech pos in this._posItems) {
      if(pos.posId == posId) {
        pos.policy = policy;
      }
    }
  }

  List<PartOfSpeech> list() {
    return _posItems;
  }

  List json() {
    var ret = [];
    for(PartOfSpeech pos in _posItems) {
      ret.add(pos.json());
    }

    return ret;
  }

  PartOfSpeechConfiguration copy() {
    PartOfSpeechConfiguration posConfig = new PartOfSpeechConfiguration();
    for(PartOfSpeech pos in _posItems) {
      posConfig.setPartOfSpeechPolicy(pos.posId, pos.policy);
    }
    return posConfig;
  }
}

