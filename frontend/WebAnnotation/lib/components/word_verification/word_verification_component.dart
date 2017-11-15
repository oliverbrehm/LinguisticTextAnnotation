import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/segmentation_proposal_service.dart' as SPS;
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/word_verification_service.dart';

enum WordVerificationComponentState {
  NotLoggedIn,
  Querying,
  Submitting,
  UserInput,
  Error
}

@Component(
    selector: 'word-verification',
    styleUrls: const ['word_verification.css'],
    templateUrl: 'word_verification_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives,
      ROUTER_DIRECTIVES
    ],
    providers: const [WordVerificationService]
)
class WordVerificationComponent implements OnInit {

  String word = '';

  WordVerificationComponentState state = WordVerificationComponentState.UserInput;

  final Router router;
  final RouteParams routeParams;
  final TextAnalysisService textAnalysisService;
  final AppService appService;
  final UserAccountService userAccountService;
  final SPS.SegmentationProposalService segmentationProposalService;

  final WordVerificationService wordVerificationService;

  WordVerificationComponent(this.router, this.routeParams, this.appService,
      this.textAnalysisService, this.userAccountService,
      this.segmentationProposalService, this.wordVerificationService);

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
    int numWords = wordVerificationService.numWords;
    if(numWords > -1) {
      return numWords.toString();
    }
    return "?";
  }

  void queryWord() {
    state = WordVerificationComponentState.Querying;
    wordVerificationService.getNextWord(userAccountService.credentials()).then((result) {
      if(result != null) {
        this.word = result;
        this.state = WordVerificationComponentState.UserInput;
      } else {
        appService.errorMessage("Wort konnte nicht geladen werden.");
        this.state = WordVerificationComponentState.Error;
      }
    });
  }

  void submitWord() {
    state = WordVerificationComponentState.Submitting;

    String text = 'Neueintrag';
    String stressPatern = '100';
    String hyphenation = 'Neu-ein-trag';

    wordVerificationService.submitSegmentation(userAccountService.credentials(),
        text, stressPatern, hyphenation).then((success) {
      if(!success) {
        appService.errorMessage("Vorschlag konnte nicht gesendet werden.");
      }

      this.state = WordVerificationComponentState.Querying;
      queryWord();
    });
  }
}