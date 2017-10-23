import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/src/user_account/user_account_service.dart';
import 'package:WebAnnotation/src/text_analysis/text_analysis_service.dart';

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
  String stressPatternText = "";


  final Router router;
  final RouteParams routeParams;
  final TextAnalysisService textAnalysisService;
  final AppService appService;
  final UserAccountService userAccountService;

  WordReviewComponent(this.router, this.routeParams, this.appService, this.textAnalysisService, this.userAccountService);

  @override
  ngOnInit() {
    this.word = routeParams.get('word');
    this.hyphenationText = word;
    this.stressPatternText = "00";
  }

  void nextWordClicked() {
    if(this.hyphenationText.isEmpty || this.stressPatternText.isEmpty) {
      appService.errorMessage("Bitte Segmentierung und Betonungsmuster eingeben.");
      return;
    }

    String hyphenation = this.hyphenationText;
    String stressPattern = this.stressPatternText;

    busyAdding = true;

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

  void doneButtonClicked() {
    router.navigate(['TextAnalysis']);
  }
}