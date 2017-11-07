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
  String newConfigurationName = 'Neue Vorlage';

  String lineHeightText = "30"; // == 0.3 -> integer numbers for input [10 - 60] map to [1.0 - 6.0]

  TextConfiguration selectedConfiguration = new TextConfiguration(-1, "", '#98FB98', '#FFEBCD', 2.5);

  bool analyzing = false;

  TextAnalysisComponent(this.appService, this.textAnalysisService, this.userAccountService, this.router, this.routeParams);

  @override
  Future<Null> ngOnInit() async {
    var routerText = routeParams.get('text');
    if(routerText != null && routerText.isNotEmpty) {
      lookupText = routerText;
      lookup();
    } else if(textAnalysisService.annotatedText != null) {
      lookupText = textAnalysisService.annotatedText.originalText;
      new Future.delayed(const Duration(microseconds: 100), () => applyCurrentConfiguration());
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

  List<TextConfiguration> textConfigurations() {
    return userAccountService.textConfigurations;
  }

  void applyCurrentConfiguration() {
    querySelectorAll(".word *").style.lineHeight =
        selectedConfiguration.line_height.toString() + "em";
    querySelectorAll(".stressed").style.backgroundColor =
        selectedConfiguration.stressed_color;
    querySelectorAll(".unstressed").style.backgroundColor =
        selectedConfiguration.unstressed_color;
    lineHeightText =
        (selectedConfiguration.line_height * 10).toInt().toString();
  }

  void configurationSelected(TextConfiguration configuration) {
    newConfigurationName = configuration.name;
    selectedConfiguration = new TextConfiguration.copy(configuration);

    applyCurrentConfiguration();
  }

  void saveConfiguration() {
    if(selectedConfiguration.name == newConfigurationName) {
      userAccountService.updateTextConfiguration(selectedConfiguration).then((success) {
        if(!success) {
          appService.errorMessage("Vorlage konnte nicht gespeichert werden.");
        } else {
          appService.infoMessage("Vorlage gespeichert.");
        }
      });
    } else {
      selectedConfiguration.name = newConfigurationName;
      userAccountService.addTextConfiguration(selectedConfiguration).then((success) {
        if(!success) {
          appService.errorMessage("Neue Vorlage konnte nicht angelegt werden.");
        } else {
          appService.infoMessage("Neue Vorlage angelegt.");
          userAccountService.textConfigurations.add(selectedConfiguration);
        }
      });
    }
  }

  void deleteConfiguration(TextConfiguration configuration) {
    userAccountService.deleteTextConfiguration(configuration).then((success) {
      if(!success) {
        appService.errorMessage("Vorlage konnte nicht gelöscht werden.");
      } else {
        appService.infoMessage("Vorlage gelöscht.");
        userAccountService.queryTextConfigurations().then((success) {
          if (!success) {
            print("WARNING: could not load text configurations");
          }
        });
      }
    });
  }

  void unknownWordClicked(Word word) {
    if(userAccountService.loggedIn) {
      router.navigate(['WordReview', {'word': word.text}]);
    } else {
      router.navigate(['UserAccount']);
      appService.infoMessage('Sie müssen eingeloggt sein, um Wörter hinzuzufügen.');
    }
  }

  void lineHeightChanged() {
    double lh = double.parse(lineHeightText, (error) {
      print(error);
      return;
    });

    selectedConfiguration.line_height = lh / 10.0;

    applyCurrentConfiguration();
  }

  void saveText() {
    if(textTitle.isEmpty) {
      appService.errorMessage("Bitte Titel eingeben.");
      return;
    }

    if(lookupText.isEmpty) {
      appService.errorMessage("Bitte Text eingeben.");
      return;
    }

    appService.clearMessage();
    userAccountService.addText(textTitle, lookupText).then((success) {
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
    selectedConfiguration.stressed_color = value;
    applyCurrentConfiguration();
  }

  void colorUnstressedChanged(value) {
    selectedConfiguration.unstressed_color = value;
    applyCurrentConfiguration();
  }

  void lookup() {
    appService.clearMessage();
    analyzing = true;
    var userData = userAccountService.appendCredentials({});
    textAnalysisService.lookupText(lookupText, userData).then((success) {
      analyzing = false;

      if(!success) {
        appService.errorMessage("Der Text konnte nicht analysiert werden.");
      } else {
        new Future.delayed(const Duration(microseconds: 100), () => applyCurrentConfiguration());
      }
    });
  }

  void newText() {
    appService.clearMessage();
    textAnalysisService.clearText();
  }
}
