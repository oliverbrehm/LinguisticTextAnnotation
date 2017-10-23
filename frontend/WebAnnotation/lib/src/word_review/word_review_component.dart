import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/src/user_account/user_account_service.dart';
import 'package:WebAnnotation/src/text_analysis/text_analysis_service.dart';

class Syllable {
  String text;
  bool selected;

  Syllable(this.text, this.selected);
}

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
  var syllables = [];

  bool busyAdding = false;

  String hyphenationText = "";

  String currentHyphenation = "";

  int selectedIndex = 0;

  final Router router;
  final RouteParams routeParams;
  final TextAnalysisService textAnalysisService;
  final AppService appService;
  final UserAccountService userAccountService;

  WordReviewComponent(this.router, this.routeParams, this.appService, this.textAnalysisService, this.userAccountService);

  @override
  Future<Null> ngOnInit() async {
    this.word = routeParams.get('word');
    this.hyphenationText = word;
    this.currentHyphenation = this.hyphenationText;

    this.textAnalysisService.getSegmentationProposals(this.word).then((success) {
      if(!success ||
          textAnalysisService.segmentationProposals == null ||
          textAnalysisService.segmentationProposals.length == 0) {
        appService.errorMessage("Unable to retrieve segmentation proposals.");
      } else {

        // TODO fill list of proposals

        this.applySegmentation(textAnalysisService.segmentationProposals[0]);
        this.hyphenationChanged();
      }
    });

    this.hyphenationChanged();
  }

  void applySegmentation(Segmentation segmentation) {
    this.currentHyphenation = segmentation.hyphenation;
    this.hyphenationText = segmentation.hyphenation;
    this.selectedIndex = segmentation.stressPattern.indexOf("1");
  }

  void nextWordClicked() {
    if(this.hyphenationText.isEmpty || this.selectedIndex < 0) {
      appService.errorMessage("Bitte Segmentierung und Betonungsmuster eingeben.");
      return;
    }

    busyAdding = true;

    String hyphenation = this.hyphenationText;

    // extract stress pattern
    String stressPattern = "";
    for(var s in this.syllables) {
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

    this.syllables = [];
    var wordSegmentation = currentHyphenation.split("-");
    int i = 0;
    for(var s in wordSegmentation) {
      if(s.isEmpty) {
        continue;
      }

      this.syllables.add(new Syllable(s, (this.selectedIndex == i)));
      i++;
    }
  }

  void syllableSelected(int i) {
    this.selectedIndex = i;
    hyphenationChanged();
  }

  void doneButtonClicked() {
    router.navigate(['TextAnalysis']);
  }
}