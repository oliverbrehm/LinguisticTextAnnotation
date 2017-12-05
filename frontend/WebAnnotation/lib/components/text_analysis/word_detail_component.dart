import 'package:WebAnnotation/model/Syllable.dart';
import 'package:angular/angular.dart';

import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/model/Word.dart';
import 'package:WebAnnotation/model/AnnotationText.dart';

@Component(
  selector: 'word-detail',
  styleUrls: const ['text_analysis.css'],
  templateUrl: 'word_detail_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives
  ],
  providers: const [],
)
class WordDetailComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;

  String hyphenationText = "";

  bool isAnnotatedToggleChecked = false;

  WordDetailComponent(this.appService, this.textAnalysisService);

  @Input()
  Word word;

  @override
  ngOnInit() {
    hyphenationText = word.getHyphenation();

    isAnnotatedToggleChecked = word.isAnnotated();
  }

  syllableSelected(Syllable syllable) {
    word.setStressedSyllable(syllable);

    textAnalysisService.applyCurrentConfiguration();
  }

  void toggleAnnotated() {
    if(isAnnotatedToggleChecked) {
      word.state = WordState.Annotated;
    } else {
      word.state = WordState.Ignored;
    }

    textAnalysisService.applyCurrentConfiguration();
  }

  void hyphenationChanged() {
    word.parseHyphenation(hyphenationText);
    textAnalysisService.applyCurrentConfiguration();
  }

  void removeStress() {
    word.removeStress();
    textAnalysisService.applyCurrentConfiguration();
  }

  void applySameWords() {
    textAnalysisService.applyToAllWords(this.word);
  }

  void closePopup() {
    textAnalysisService.annotatedText.editWord(null);
  }
}