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

  String lookupText = 'Kreidefelsen sind doof.';
  String textTitle = '';
  String newConfigurationName = 'Neue Vorlage';

  String lineHeightValue = "10"; // value divided by 10, for double mapping
  String syllableDistanceValue = "3"; // divided by 10
  String wordDistanceValue = "7"; // divided by 10
  String fontSizeValue = "14"; // not divided

  TextConfiguration selectedConfiguration = new TextConfiguration(-1, "",
      '#98FB98', '#FFEBCD', '#FFFFFF', 16.0, 1.5, 0.2, 0.4, false, false, true);

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
    new Future.delayed(const Duration(microseconds: 100), () {
      querySelectorAll(".word").style.fontSize =
          selectedConfiguration.font_size.toString() + "px";
      querySelectorAll(".word").style.marginBottom =
          (selectedConfiguration.line_height - 1.0).toString() + "em";
      querySelectorAll(".word").style.marginRight =
          selectedConfiguration.word_distance.toString() + "em";
      querySelectorAll(".syllable").style.marginRight =
          selectedConfiguration.syllable_distance.toString() + "em";

      if(selectedConfiguration.stressed_bold) {
        querySelectorAll(".stressed").style.fontWeight = 'bold';
      } else {
        querySelectorAll(".stressed").style.fontWeight = 'normal';
      }

      if(selectedConfiguration.highlight_foreground) {
        querySelectorAll(".stressed").style.color =
            selectedConfiguration.stressed_color;
        querySelectorAll(".unstressed").style.color =
            selectedConfiguration.unstressed_color;
      } else {
        querySelectorAll(".stressed").style.backgroundColor =
            selectedConfiguration.stressed_color;
        querySelectorAll(".unstressed").style.backgroundColor =
            selectedConfiguration.unstressed_color;
      }

      if(selectedConfiguration.use_background) {
        querySelectorAll(".word").style.backgroundColor =
            selectedConfiguration.word_background;
      } else {
        querySelectorAll(".word").style.backgroundColor = '#FFFFFF';
      }

      fontSizeValue =
          selectedConfiguration.font_size.toInt().toString();
      lineHeightValue =
          (selectedConfiguration.line_height * 10).toInt().toString();
      syllableDistanceValue =
          (selectedConfiguration.syllable_distance * 10).toInt().toString();
      wordDistanceValue =
          (selectedConfiguration.word_distance * 10).toInt().toString();
    });
  }

  void resetColors() {
    querySelectorAll(".stressed").style.backgroundColor = '#FFFFFF';
    querySelectorAll(".unstressed").style.backgroundColor = '#FFFFFF';
    querySelectorAll(".word").style.backgroundColor = '#FFFFFF';

    querySelectorAll(".stressed").style.color = '#000000';
    querySelectorAll(".unstressed").style.color = '#000000';
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

  void stressedBoldChanged(event) {
    var checked = event.target.checked;
    if(checked) {
      selectedConfiguration.stressed_bold = true;
    } else {
      selectedConfiguration.stressed_bold = false;
    }

    applyCurrentConfiguration();
  }

  void useWordBackgroundChanged(event) {
    var checked = event.target.checked;
    if(checked) {
      selectedConfiguration.use_background = true;
    } else {
      selectedConfiguration.use_background = false;
    }

    applyCurrentConfiguration();
  }

  void fontSizeSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration.font_size = lh;
  }

  void radioSyllableColorChanged(event) {
    var value = event.target.value;
    if(value == 'foreground') {
      selectedConfiguration.highlight_foreground = true;
    } else if(value == 'background') {
      selectedConfiguration.highlight_foreground = false;
    } else {
      print('ERROR: checkbox syllable color none selected');
    }

    resetColors();
    applyCurrentConfiguration();
  }

  void lineHeightSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration.line_height = lh / 10.0;
  }

  void syllableDistanceSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration.syllable_distance = lh / 10.0;
  }

  void wordDistanceSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration.word_distance = lh / 10.0;
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

  void lookup() {
    appService.clearMessage();
    analyzing = true;
    var userData = userAccountService.appendCredentials({});
    textAnalysisService.lookupText(lookupText, userData).then((success) {
      analyzing = false;

      if(!success) {
        appService.errorMessage("Der Text konnte nicht analysiert werden.");
      } else {
        applyCurrentConfiguration();
      }
    });
  }

  void newText() {
    appService.clearMessage();
    textAnalysisService.clearText();
  }
}
