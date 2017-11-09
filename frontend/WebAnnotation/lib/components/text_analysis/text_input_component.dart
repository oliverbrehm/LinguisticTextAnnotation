import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';

@Component(
  selector: 'text-input',
  styleUrls: const ['text_analysis.css'],
  templateUrl: 'text_input_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives
  ],
  providers: const [],
)
class TextInputComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  TextInputComponent(this.appService, this.textAnalysisService, this.userAccountService);

  String textTitle = '';

  @override
  ngOnInit() {

  }

  void newText() {
    appService.clearMessage();
    textAnalysisService.clearText();
  }

  void saveText() {
    if(textTitle.isEmpty) {
      appService.errorMessage("Bitte Titel eingeben.");
      return;
    }

    if(textAnalysisService.lookupText.isEmpty) {
      appService.errorMessage("Bitte Text eingeben.");
      return;
    }

    appService.clearMessage();
    userAccountService.addText(textTitle, textAnalysisService.lookupText).then((success) {
      if(success) {
        appService.infoMessage("Text hinzugefügt.");
      } else {
        appService.errorMessage("Fehler beim speichern des Texts.");
      }
    });
  }

  // TODO CLEANUP copy code from text_analysis_component
  void lookup() {
    appService.clearMessage();
    var userData = userAccountService.appendCredentials({});
    textAnalysisService.lookup(userData).then((success) {
      if(!success) {
        appService.errorMessage("Der Text konnte nicht analysiert werden.");
      } else {
        textAnalysisService.applyCurrentConfiguration();
      }
    });
  }
}