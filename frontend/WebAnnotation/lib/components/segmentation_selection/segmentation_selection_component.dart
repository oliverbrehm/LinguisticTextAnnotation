import 'dart:async';

import 'package:WebAnnotation/model/Segmentation.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/segmentation_proposal_service.dart';
import 'package:WebAnnotation/services/segmentation_service.dart';

import 'package:WebAnnotation/model/Word.dart';

@Component(
    selector: 'segmentation-selection',
    styleUrls: const ['segmentation_selection.css'],
    templateUrl: 'segmentation_selection_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives
    ]
)
class SegmentationSelectionComponent implements OnInit {
  String hyphenationText = "";

  String _currentHyphenation = "";
  String _currentStressPattern = "";

  Word segmentationWord;

  final AppService appService;

  SegmentationSelectionComponent(this.appService);

  @Input()
  bool loadingProposals;

  @Input()
  Word word;

  @Input()
  List<Segmentation> segmentations;

  @override
  ngOnInit() {
    if(word != null) {
      segmentationWord = new Word.initialize(word.text, word.posId, word.lemma);
    } else {
      segmentationWord = new Word("");
    }
    this.reset();
  }

  void reset() {
    new Future.delayed(const Duration(microseconds: 100), () {
      if(word != null) {
        hyphenationText = segmentationWord.text;
        _currentHyphenation = hyphenationText;

        updateSegmentation();
      }
    });
  }

  void loadDefault() {
    if(segmentations != null && segmentations.length > 0) {
      applySegmentationProposal(segmentations.first);
    } else {
      print('segmentation-selection: no segmentations to load');
    }
  }

  List<Segmentation> segmentationProposals() {
    return segmentations;
  }

  void hyphenationChanged() {
    // test valid input (string without - marks should be identical to word)
    String testOriginal = hyphenationText.replaceAll("-", "");
    if(testOriginal != segmentationWord.text) {
      hyphenationText = _currentHyphenation;
    } else {
      _currentHyphenation = hyphenationText;
      this.updateSegmentation();
    }
  }

  void syllableSelected(int index) {
    // extract stress pattern
    var segments = _currentHyphenation.split('-');
    _currentStressPattern = "";
    for(int i = 0; i < segments.length; i++) {
      _currentStressPattern = _currentStressPattern + ((i == index) ? "1" : "0");
    }

    this.updateSegmentation();
  }

  void applySegmentationProposal(Segmentation segmentationProposal) {
    if(segmentationProposal == null) {
      return;
    }

    segmentationWord.text = segmentationProposal.text;
    _currentHyphenation = segmentationProposal.hyphenation;
    hyphenationText = segmentationProposal.hyphenation;
    _currentStressPattern = segmentationProposal.stressPattern;

    segmentationWord.lemma = segmentationProposal.lemma;
    segmentationWord.posId = segmentationProposal.pos;

    updateSegmentation();
  }

  void updateSegmentation() {
    if(word != null) {
      this.segmentationWord = new Word.initialize(word.text, word.posId, word.lemma);
    } else {
      this.segmentationWord = new Word.initialize(segmentationWord.text, segmentationWord.posId, segmentationWord.lemma);
    }
    this.segmentationWord.parseHyphenation(_currentHyphenation);
    this.segmentationWord.parseStressPattern(_currentStressPattern);
  }

  void proposalSelected(Segmentation segmentation) {
    applySegmentationProposal(segmentation);
  }
}