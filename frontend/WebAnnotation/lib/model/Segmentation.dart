import 'package:WebAnnotation/model/Word.dart';

class Segmentation {
  String text;
  String origin;
  String source;
  String hyphenation;
  String stressPattern;
  String pos;
  String lemma;

  Word word;

  Segmentation(this.text, this.origin, this.source, this.hyphenation, this.stressPattern, this.pos, this.lemma) {
    this.word = new Word(this.text);
    this.word.parseHyphenation(this.hyphenation);
    this.word.parseStressPattern(this.stressPattern);
  }
}