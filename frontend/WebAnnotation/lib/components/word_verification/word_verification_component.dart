import 'dart:async';

import 'package:WebAnnotation/components/segmentation_selection/segmentation_selection_component.dart';
import 'package:WebAnnotation/services/segmentation_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/segmentation_verification_service.dart';

enum WordVerificationComponentState {
  NotLoggedIn,
  Querying,
  Submitting,
  UserInput,
  Error
}

@Component(
    selector: 'word-verification',
    templateUrl: 'word_verification_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives,
      ROUTER_DIRECTIVES,
      SegmentationSelectionComponent
    ],
    providers: const []
)
class WordVerificationComponent implements OnInit {

  WordVerificationComponentState state = WordVerificationComponentState.UserInput;

  bool loadingProposals = false;

  List<Segmentation> segmentations;

  String currentWord = '';

  final Router router;
  final RouteParams routeParams;
  final TextAnalysisService textAnalysisService;
  final AppService appService;
  final UserAccountService userAccountService;
  final SegmentationVerificationService segmentationVerificationService;

  WordVerificationComponent(this.router, this.routeParams, this.appService,
      this.textAnalysisService, this.userAccountService,
      this.segmentationVerificationService);

  @ViewChild(SegmentationSelectionComponent)
  SegmentationSelectionComponent segmentationSelection;

  @override
  ngOnInit() {
    if(!userAccountService.loggedIn) {
      this.state = WordVerificationComponentState.NotLoggedIn;
    } else {
      queryWord();
    }
  }

  bool busySubmitting() {
    return state == WordVerificationComponentState.Submitting;
  }

  bool busyQuerying() {
    return state == WordVerificationComponentState.Querying;
  }

  bool hadError() {
    return state == WordVerificationComponentState.Error;
  }

  bool awaitingUserInput() {
    return state == WordVerificationComponentState.UserInput;
  }

  bool notLoggedIn() {
    return state == WordVerificationComponentState.NotLoggedIn;
  }

  String userLevel() {
    return "Expert";
  }

  String wordsLeft() {
    int numWords = segmentationVerificationService.numberOfVerificationWords();
    if(numWords > -1) {
      return numWords.toString();
    }
    return "?";
  }

  void queryWord() {
    state = WordVerificationComponentState.Querying;
    segmentationVerificationService.userData = userAccountService.credentials();
    segmentationVerificationService.query().then((success) {
      if(success) {
        this.segmentations = segmentationVerificationService.segmentationProposals();

        this.state = WordVerificationComponentState.UserInput;

        if(segmentations != null && segmentations.length > 0) {
          this.currentWord = segmentations.first.text;
        }

        // delay to next detection cycle
        new Future.delayed(const Duration(microseconds: 100), () {
          this.segmentationSelection.loadDefault();
        });
      } else {
        this.state = WordVerificationComponentState.Error;
      }
    });
  }

  void submitWord() {
    state = WordVerificationComponentState.Submitting;

    Word segmentationWord = segmentationVerificationService.verificationWord;
    segmentationVerificationService.submitVerification(userAccountService.credentials(),
        segmentationWord).then((success) {
      if(!success) {
        appService.errorMessage("Vorschlag konnte nicht gesendet werden.");
      }

      this.state = WordVerificationComponentState.Querying;
      queryWord();
    });
  }
}