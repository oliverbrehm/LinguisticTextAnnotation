import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';

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
class TextSettingsComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  String newConfigurationName = 'Neue Vorlage';

  String lineHeightValue = "10"; // value divided by 10, for double mapping
  String syllableDistanceValue = "3"; // divided by 10
  String wordDistanceValue = "7"; // divided by 10
  String fontSizeValue = "14"; // not divided

  TextSettingsComponent(this.appService, this.textAnalysisService,
      this.userAccountService);

  @override
  ngOnInit() {

  }

  List<TextConfiguration> textConfigurations() {
    return userAccountService.textConfigurations;
  }

  TextConfiguration selectedConfiguration() {
    return textAnalysisService.selectedConfiguration;
  }

  void applyCurrentConfiguration() {
    textAnalysisService.applyCurrentConfiguration();

    fontSizeValue =
        selectedConfiguration().font_size.toInt().toString();
    lineHeightValue =
        (selectedConfiguration().line_height * 10).toInt().toString();
    syllableDistanceValue =
        (selectedConfiguration().syllable_distance * 10).toInt().toString();
    wordDistanceValue =
        (selectedConfiguration().word_distance * 10).toInt().toString();
  }

  void configurationSelected(TextConfiguration configuration) {
    newConfigurationName = configuration.name;
    textAnalysisService.selectedConfiguration = new TextConfiguration.copy(configuration);

    applyCurrentConfiguration();
  }

  void saveConfiguration() {
    if(selectedConfiguration().name == newConfigurationName) {
      userAccountService.updateTextConfiguration(selectedConfiguration()).then((success) {
        if(!success) {
          appService.errorMessage("Vorlage konnte nicht gespeichert werden.");
        } else {
          appService.infoMessage("Vorlage gespeichert.");
        }
      });
    } else {
      selectedConfiguration().name = newConfigurationName;
      userAccountService.addTextConfiguration(selectedConfiguration()).then((success) {
        if(!success) {
          appService.errorMessage("Neue Vorlage konnte nicht angelegt werden.");
        } else {
          appService.infoMessage("Neue Vorlage angelegt.");
          userAccountService.textConfigurations.add(selectedConfiguration());
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

  void stressedBoldChanged(event) {
    var checked = event.target.checked;
    if(checked) {
      selectedConfiguration().stressed_bold = true;
    } else {
      selectedConfiguration().stressed_bold = false;
    }

    applyCurrentConfiguration();
  }

  void useWordBackgroundChanged(event) {
    var checked = event.target.checked;
    if(checked) {
      selectedConfiguration().use_background = true;
    } else {
      selectedConfiguration().use_background = false;
    }

    applyCurrentConfiguration();
  }

  void fontSizeSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().font_size = lh;
  }

  void radioSyllableColorChanged(event) {
    var value = event.target.value;
    if(value == 'foreground') {
      selectedConfiguration().highlight_foreground = true;
    } else if(value == 'background') {
      selectedConfiguration().highlight_foreground = false;
    } else {
      print('ERROR: checkbox syllable color none selected');
    }

    textAnalysisService.resetColors();
    applyCurrentConfiguration();
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
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().syllable_distance = lh / 10.0;
  }

  void wordDistanceSliderMoved(event) {
    var value = event.target.value;
    double lh = double.parse(value, (error) {
      print(error);
      return;
    });

    selectedConfiguration().word_distance = lh / 10.0;
  }
}