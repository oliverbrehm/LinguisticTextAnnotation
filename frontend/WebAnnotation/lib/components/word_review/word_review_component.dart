import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/components/segmentation_selection/segmentation_selection_component.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/segmentation_proposal_service.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/segmentation_service.dart';

@Component(
    selector: 'word-review',
    templateUrl: 'word_review_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives,
      SegmentationSelectionComponent
    ]
)
class WordReviewComponent implements OnInit {

  Word word;

  bool busyAdding = false;
  bool loadingProposals = false;

  Word previousWord = null;
  Word nextWord = null;

  final Router router;
  final RouteParams routeParams;
  final TextAnalysisService textAnalysisService;
  final AppService appService;
  final UserAccountService userAccountService;
  final SegmentationProposalService segmentationProposalService;

  List<Segmentation> segmentations;

  @ViewChild(SegmentationSelectionComponent)
  SegmentationSelectionComponent segmentationSelection;

  WordReviewComponent(this.router, this.routeParams, this.appService,
      this.textAnalysisService, this.userAccountService, this.segmentationProposalService) {
  }

  int numWordsLeft() {
    return textAnalysisService.annotatedText.numberOfUnknownWords();
  }

  @override
  Future<Null> ngOnInit() async {
    int wordIndex = int.parse(routeParams.get('wordIndex'));

    this.word = textAnalysisService.annotatedText.words[wordIndex];

    loadProposals();
  }

  void loadProposals() {
    this.loadingProposals = true;

    this.segmentations = [];

    this.segmentationProposalService.wordText = this.word.text;
    this.segmentationProposalService.query().then((success) {
      if (!success) {
        appService.errorMessage("Unable to retrieve segmentation proposals.");
      } else {
        this.segmentations = segmentationProposalService.segmentationProposals();

        // delay to next detection cycle
        new Future.delayed(const Duration(microseconds: 100), () {
          this.segmentationSelection.loadDefault();
        });
      }

      this.loadingProposals = false;
    });

    this.previousWord = textAnalysisService.annotatedText.previousWordTo(this.word);
    this.nextWord = textAnalysisService.annotatedText.nextWordTo(this.word);
  }

  void nextWordClicked() {
    appService.clearMessage();

    segmentationSelection.reset();

    busyAdding = true;

    Word segmentationWord = segmentationSelection.segmentationWord;

    String hyphenation = segmentationWord.getHyphenation();
    String stressPattern = segmentationWord.getStressPattern();

    this.userAccountService.addWord(word.text, hyphenation, stressPattern)
        .then((bool success) {
      if(success) {
        this.textAnalysisService.annotatedText.updateWord(word.text, hyphenation, stressPattern);

        gotoNextWord();
      } else {
        appService.errorMessage("Fehler beim hinzufügen des Wortes zur"
            "lokalen Datenbank.");
      }

      busyAdding = false;
    });
  }

  void gotoNextWord() {
    if(nextWord != null) {
      gotoWord(nextWord);
    } else {
      // find first unknown word
      Word w = textAnalysisService.annotatedText.nextMissingWord();
      if(w == null) {
        // no more unknown words, back to text
        router.navigate(['TextAnalysis']);
        return;
      }

      gotoWord(w);
    }
  }

  void ignoreClicked() {
    segmentationSelection.reset();
    this.word.type = WordType.Ignored;
    gotoNextWord();
  }

  void gotoWord(Word word) {
    this.word = word;
    loadProposals();
  }

  void doneButtonClicked() {
    router.navigate(['TextAnalysis']);
  }
}