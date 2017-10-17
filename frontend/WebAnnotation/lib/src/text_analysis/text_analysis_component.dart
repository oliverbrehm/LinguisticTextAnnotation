import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';


import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/src/text_analysis/text_analysis_service.dart';
import 'package:WebAnnotation/src/user_account/user_account_service.dart';


@Component(
  selector: 'text-analysis',
  styleUrls: const ['text_analysis_component.css'],
  templateUrl: 'text_analysis_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives
  ],
  providers: const [TextAnalysisService],
)
class TextAnalysisComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  final RouteParams routeParams;

  String lookupText = '';
  String lineHeightText = '1.0';

  String colorStressed = '#98FB98';
  String colorUnstressed = '#FFEBCD';

  AnnotationText annotatedText;

  bool analyzing = false;

  double lineHeight = 1.0;

  TextAnalysisComponent(this.appService, this.textAnalysisService, this.userAccountService, this.routeParams);

  @override
  Future<Null> ngOnInit() async {
    var routerText = routeParams.get('text');
    if(routerText.isNotEmpty) {
      lookupText = routerText;
      lookup();
    }
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

  void saveText(String text) {
    appService.clearMessage();
    userAccountService.addText(text).then((success) {
      if(success) {
        appService.infoMessage("Text hinzugefügt.");
      } else {
        appService.errorMessage("Fehler beim speichern des Texts.");
      }
    });
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
    textAnalysisService.lookupText(lookupText).then((response) {
      annotatedText = response;
      analyzing = false;
    }, onError: (e) {
      // TODO error properties
      print(e.toString());
      appService.errorMessage("Der Text konnte nicht analysiert werden.");
      analyzing = false;
    });
  }

  void newText() {
    appService.clearMessage();
    annotatedText = null;
  }
}
