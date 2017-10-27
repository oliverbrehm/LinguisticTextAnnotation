import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/segmentation_proposal_service.dart' as SPS;

@Component(
    selector: 'word-review',
    styleUrls: const ['word_review_component.css'],
    templateUrl: 'word_review_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives
    ]
)
class WordReviewComponent implements OnInit {

  String word;

  bool busyAdding = false;

  String hyphenationText = "";
  String currentHyphenation = "";
  int selectedIndex = 0;

  SPS.Segmentation currentSegmentation;

  final Router router;
  final RouteParams routeParams;
  final TextAnalysisService textAnalysisService;
  final AppService appService;
  final UserAccountService userAccountService;
  final SPS.SegmentationProposalService segmentationProposalService;

  WordReviewComponent(this.router, this.routeParams, this.appService,
      this.textAnalysisService, this.userAccountService, this.segmentationProposalService) {
    this.setSegmentation("loading", 0);
  }

  List<SPS.SegmentationProposal> segmentationProposals() {
    return this.segmentationProposalService.segmentationProposals;
  }

  @override
  Future<Null> ngOnInit() async {
    this.word = routeParams.get('word');
    this.hyphenationText = word;
    this.currentHyphenation = this.hyphenationText;

    this.setSegmentation(this.word, 0);

    this.segmentationProposalService.querySegmentationProposals(this.word).then((success) {
      if(!success || segmentationProposals() == null ||
          segmentationProposals().length == 0) {
        appService.errorMessage("Unable to retrieve segmentation proposals.");
      } else {
        // apply first proposal as default
        this.applySegmentationProposal(segmentationProposals()[0]);
      }
    });
  }

  void applySegmentationProposal(SPS.SegmentationProposal segmentationProposal) {
    if(segmentationProposal == null) {
      return;
    }

    this.currentSegmentation = segmentationProposal.segmentation;

    this.currentHyphenation = segmentationProposal.hyphenation;
    this.hyphenationText = segmentationProposal.hyphenation;
  }

  void setSegmentation(String hyphenation, int stressed) {
    var segments = hyphenation.split('-');
    var syllables = [];

    for(int i = 0; i < segments.length; i++) {
      if(i == stressed) {
        syllables.add(new SPS.Syllable(segments[i], true));
      } else {
        syllables.add(new SPS.Syllable(segments[i], false));
      }
    }

    this.currentSegmentation = new SPS.Segmentation(syllables);
  }

  void proposalSelected(SPS.SegmentationProposal segmentation) {
    applySegmentationProposal(segmentation);
  }

  void nextWordClicked() {
    appService.clearMessage();

    busyAdding = true;

    String hyphenation = currentHyphenation;

    // extract stress pattern
    String stressPattern = "";
    for(var s in this.currentSegmentation.syllables) {
      stressPattern = stressPattern + (s.selected ? "1" : "0");
    }

    this.userAccountService.addWord(word, hyphenation, stressPattern).then((bool success) {
      if(success) {
        this.textAnalysisService.updateWord(word, hyphenation, stressPattern);

        Word w = textAnalysisService.nextMissingWord();
        if(w == null) {
          // no more unknown words, back to text
          router.navigate(['TextAnalysis']);
          return;
        }

        // navigate to next unknown word
        router.navigate(['WordReview', {'word': w.text}]);
      } else {
        appService.errorMessage("Fehler beim hinzufügen des Wortes zur"
            "lokalen Datenbank.");
      }

      busyAdding = false;
    });
  }

  void hyphenationChanged() {
    // test valid input (string without - marks should be identical to word)
    String testOriginal = hyphenationText.replaceAll("-", "");
    if(testOriginal != word) {
      hyphenationText = currentHyphenation;
    } else {
      currentHyphenation = hyphenationText;
    }

    this.setSegmentation(currentHyphenation, selectedIndex);
  }

  void syllableSelected(int i) {
    this.selectedIndex = i;
    this.setSegmentation(currentHyphenation, selectedIndex);
  }

  void doneButtonClicked() {
    router.navigate(['TextAnalysis']);
  }
}