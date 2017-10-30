import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';


import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';


@Component(
  selector: 'text-analysis',
  styleUrls: const ['text_analysis_component.css'],
  templateUrl: 'text_analysis_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives
  ],
  providers: const [],
)
class TextAnalysisComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  final RouteParams routeParams;
  final Router router;

  String lookupText = 'Kreidefelsen';
  String textTitle = '';
  String lineHeightText = '1.0';

  String colorStressed = '#98FB98';
  String colorUnstressed = '#FFEBCD';

  bool analyzing = false;

  double lineHeight = 1.0;

  TextAnalysisComponent(this.appService, this.textAnalysisService, this.userAccountService, this.router, this.routeParams);

  @override
  Future<Null> ngOnInit() async {
    var routerText = routeParams.get('text');
    if(routerText != null && routerText.isNotEmpty) {
      lookupText = routerText;
      lookup();
    } else if(textAnalysisService.annotatedText != null) {
      lookupText = textAnalysisService.annotatedText.originalText;
    }
  }

  AnnotationText annotatedText() {
    return textAnalysisService.annotatedText;
  }

  void unknownWordClicked(Word word) {
    router.navigate(['WordReview', {'word': word.text}]);
  }

  void lineHeightChanged() {
    double lh = double.parse(lineHeightText, (error) {
      print(error);
      lineHeightText = lineHeight.toString();
      return;
    });

    if(lh == null) {
      lineHeightText = lineHeight.toString();
      return;
    }

    lineHeight = lh;
    if(lineHeight > 5.0) {
      lineHeight = 5.0;
      lineHeightText = lineHeight.toString();
    }
    querySelectorAll(".word *").style.lineHeight = lineHeight.toString() + "em";
  }

  void saveText() {
    String title = textTitle;
    String text = lookupText;

    appService.clearMessage();
    userAccountService.addText(title, text).then((success) {
      if(success) {
        appService.infoMessage("Text hinzugefügt.");
      } else {
        appService.errorMessage("Fehler beim speichern des Texts.");
      }
    });
  }

  void startWordReview() {
    Word w = textAnalysisService.nextMissingWord();
    if(w == null) {
      appService.infoMessage("Keine unbekannten Wörter.");
      return;
    }

    unknownWordClicked(w);
  }

  void colorStressedChanged(value) {
    querySelectorAll(".stressed").style.backgroundColor = value;
  }

  void colorUnstressedChanged(value) {
    querySelectorAll(".unstressed").style.backgroundColor = value;
  }

  void lookup() {
    appService.clearMessage();
    analyzing = true;
    var userData = userAccountService.appendCredentials({});
    textAnalysisService.lookupText(lookupText, userData).then((success) {
      analyzing = false;

      if(!success) {
        appService.errorMessage("Der Text konnte nicht analysiert werden.");
      }
    });
  }

  void newText() {
    appService.clearMessage();
    textAnalysisService.clearText();
  }
}
