import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';


import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/model/AnnotationText.dart';
import 'package:WebAnnotation/components/text_analysis/text_preview_component.dart';
import 'package:WebAnnotation/components/text_analysis/text_settings_component.dart';
import 'package:WebAnnotation/components/text_analysis/text_input_component.dart';

@Component(
  selector: 'text-analysis',
  styleUrls: const ['text_analysis.css'],
  templateUrl: 'text_analysis_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives,
    TextPreviewComponent,
    TextSettingsComponent,
    TextInputComponent,
    MaterialToggleComponent
  ],
  providers: const [],
)
class TextAnalysisComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  final RouteParams routeParams;
  final Router router;

  TextAnalysisComponent(this.appService, this.textAnalysisService, this.userAccountService, this.router, this.routeParams);

  @override
  Future<Null> ngOnInit() async {
    var routerText = routeParams.get('text');
    if(routerText != null && routerText.isNotEmpty) {
      textAnalysisService.lookupText = routerText;
      lookup();
    } else if(textAnalysisService.annotatedText != null) {
      textAnalysisService.lookupText = textAnalysisService.annotatedText.originalText;
      textAnalysisService.applyCurrentConfiguration();
      appService.scrollToTop();
    }

    if(userAccountService.loggedIn) {
      userAccountService.queryTextConfigurations().then((success) {
        if (!success) {
          print("WARNING: could not load text configurations");
        }
      });
    }
  }

  AnnotationText annotatedText() {
    return textAnalysisService.annotatedText;
  }

  void lookup() {
    appService.clearMessage();
    var userData = userAccountService.credentials();
    textAnalysisService.lookup(userData).then((success) {

      if(!success) {
        appService.errorMessage("Der Text konnte nicht analysiert werden.");
      } else {
        textAnalysisService.applyCurrentConfiguration();
        appService.infoMessage("Der Text wurde erfolgreich analysiert und wird in der Vorschau hervorgehoben dargestellt."
            "Sie Können in der Vorschau jedes Wort bearbeiten indem Sie darauf klicken.");
      }
    });
  }
}
