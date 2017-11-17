import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/core.dart';

import 'package:WebAnnotation/app_service.dart';

import 'package:WebAnnotation/services/model/Word.dart';

class Segmentation {
  String text;
  String origin;
  String source;
  String hyphenation;
  String stressPattern;

  Word word;

  Segmentation(this.text, this.origin, this.source, this.hyphenation, this.stressPattern) {
    this.word = new Word(this.text);
    this.word.parseHyphenation(this.hyphenation);
    this.word.parseStressPattern(this.stressPattern);
  }
}

/// service description
abstract class SegmentationService {
  List<Segmentation> segmentations = [];

  SegmentationService();

  String wordText = null;

  List<Segmentation> segmentationProposals() {
    return segmentations;
  }

  Future<bool> query();
}