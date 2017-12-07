import 'package:WebAnnotation/model/PartOfSpeech.dart';
import 'package:WebAnnotation/model/Common.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/model/TextConfiguration.dart';

@Component(
  selector: 'text-settings',
  styleUrls: const ['text_analysis.css'],
  templateUrl: 'text_settings_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives,
  ],
  providers: const [],
)
class TextSettingsComponent implements OnInit, TextAnalysisObserver {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  String newConfigurationName = 'Neue Vorlage';

  String syllableSeparatorText = '|';

  String lineHeightValue = "10"; // value divided by 10, for double mapping
  String syllableDistanceValue = "3"; // divided by 10
  String wordDistanceValue = "7"; // divided by 10
  String fontSizeValue = "14"; // not divided
  String letterSpacingValue = "0"; // not divided 0 to 32

  final SelectionModel foregroundSelectionModel = new SelectionModel.withList();
  List<Option> foregroundOptions = [
    new Option("Vordergrundfarbe", false, false),
    new Option("Hintergrundfarbe", false, false)
  ];

  final SelectionModel wordPOSAnnotationSelectionModel = new SelectionModel.withList();
  List<Option> wordPOSAnnotationOptions = [
    new Option("Annotieren", true, false),
    new Option("Unbetont", false, false),
    new Option("Ignorieren", false, false)
  ];

  PartOfSpeech selectedWordPOS = PartOfSpeechConfiguration.unknownPOS();

  TextSettingsComponent(this.appService, this.textAnalysisService,
      this.userAccountService);

  @override
  ngOnInit() {
    updateConfigurationUI();
    textAnalysisService.addObserver(this);

    this.wordPOSSelected(wordPOSList()[0]);
  }

  List<PartOfSpeech> wordPOSList() {
    return selectedConfiguration().partOfSpeechConfiguration.list();
  }

  void syllableSeparatorChanged() {
    if(syllableSeparatorText.length > 1) {
      syllableSeparatorText = syllableSeparatorText[0];
    }

    if(syllableSeparatorText.length == 1) {
      selectedConfiguration().syllable_separator = syllableSeparatorText;
    }

    textAnalysisService.applyCurrentConfiguration();
  }

  void openColorPicker(String inputId) {
    var inputElement = querySelector('#' + inputId);
    inputElement.focus();
    inputElement.click();
  }

  void wordPOSSelected(PartOfSpeech wordPOS) {
    this.selectedWordPOS = wordPOS;
    this.updateConfigurationUI();
  }

  List<TextConfiguration> textConfigurations() {
    return userAccountService.textConfigurations;
  }

  TextConfiguration selectedConfiguration() {
    return textAnalysisService.selectedConfiguration;
  }

  void updateConfigurationUI() {
    fontSizeValue =
        selectedConfiguration().font_size.toInt().toString();
    lineHeightValue =
        (selectedConfiguration().line_height * 10).toInt().toString();
    syllableDistanceValue =
        (selectedConfiguration().syllable_distance * 10).toInt().toString();
    wordDistanceValue =
        (selectedConfiguration().word_distance * 10).toInt().toString();
    letterSpacingValue =
        selectedConfiguration().letter_spacing.toInt().toString();

    foregroundOptions[0].selected = selectedConfiguration().highlight_foreground;
    foregroundOptions[1].selected = !selectedConfiguration().highlight_foreground;

    for(Option o in wordPOSAnnotationOptions) {
      o.selected = false;
    }

    switch(selectedWordPOS.policy) {
      case POSPolicy.Annotate:
        wordPOSAnnotationOptions[0].selected = true;
        break;
      case POSPolicy.Unstressed:
        wordPOSAnnotationOptions[1].selected = true;
        break;
      case POSPolicy.Ignore:
        wordPOSAnnotationOptions[2].selected = true;
        break;
    }

    if(syllableSeparatorText.length > 0) {
      this.syllableSeparatorText = selectedConfiguration().syllable_separator;
    }
  }

  void configurationSelected(TextConfiguration configuration) {
    newConfigurationName = configuration.name;
    textAnalysisService.selectedConfiguration = new TextConfiguration.copy(configuration);
    this.selectedWordPOS = wordPOSList()[0];

    textAnalysisService.updatePOS();
    textAnalysisService.applyCurrentConfiguration();

    updateConfigurationUI();
  }

  void saveConfiguration() {
    if(selectedConfiguration().name == newConfigurationName) {
      userAccountService.updateTextConfiguration(selectedConfiguration()).then((success) {
        if(!success) {
          appService.errorMessage("Vorlage konnte nicht gespeichert werden.");
        } else {
          appService.infoMessage("Vorlage gespeichert.");

          userAccountService.queryTextConfigurations().then((success) {
            if (!success) {
              print("WARNING: could not load text configurations");
            }
          });
        }
      });
    } else {
      selectedConfiguration().name = newConfigurationName;
      userAccountService.addTextConfiguration(selectedConfiguration()).then((success) {
        if(!success) {
          appService.errorMessage("Neue Vorlage konnte nicht angelegt werden.");
        } else {
          appService.infoMessage("Neue Vorlage angelegt.");

          userAccountService.queryTextConfigurations().then((success) {
            if (!success) {
              print("WARNING: could not load text configurations");
            }
          });
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
          } else {
            selectedConfiguration().name = "";
          }
        });
      }
    });
  }

  void fontSizeSliderMoved(event) {
    var value = event.target.value;
    double fs = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().font_size = fs;
  }

  void radioSyllableColorChanged() {
    selectedConfiguration().highlight_foreground = foregroundOptions[0].selected;
    textAnalysisService.applyCurrentConfiguration();
  }

  void wordPOSAnnotationChanged() {
    for(Option o in wordPOSAnnotationOptions) {
      if(o.selected) {
        switch(o.label) {
          case "Annotieren":
            selectedWordPOS.policy = POSPolicy.Annotate;
            break;
          case "Unbetont":
            selectedWordPOS.policy = POSPolicy.Unstressed;
            break;
          case "Ignorieren":
            selectedWordPOS.policy = POSPolicy.Ignore;
            break;
        }
      }
    }

    textAnalysisService.updatePOS();
    textAnalysisService.applyCurrentConfiguration();
  }

  void lineHeightSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().line_height = lh / 10.0;
  }

  void syllableDistanceSliderMoved(event) {
    var value = event.target.value;
    double sd = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().syllable_distance = sd / 10.0;
  }

  void wordDistanceSliderMoved(event) {
    var value = event.target.value;
    double wd = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().word_distance = wd / 10.0;
  }

  void letterSpacingSliderMoved(event) {
    var value = event.target.value;
    double ls = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().letter_spacing = ls;
  }

  @override
  void textUpdated() {
    updateConfigurationUI();
  }
}