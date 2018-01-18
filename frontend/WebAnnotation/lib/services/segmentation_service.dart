import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/model/common/Segmentation.dart';
import 'package:angular/core.dart';

import 'package:WebAnnotation/app_service.dart';

import 'package:WebAnnotation/model/text_annotation/Word.dart';

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