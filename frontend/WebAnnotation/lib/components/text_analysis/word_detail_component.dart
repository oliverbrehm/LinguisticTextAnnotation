import 'package:angular/angular.dart';

import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/model/AnnotationText.dart';

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

  WordDetailComponent(this.appService, this.textAnalysisService);

  @Input()
  Word word;

  @override
  ngOnInit() {
    hyphenationText = word.getHyphenation();
  }

  syllableSelected(Syllable syllable) {
    word.setStressedSyllable(syllable);

    textAnalysisService.applyCurrentConfiguration();
  }

  void radioAnnotatedChanged(event) {
    var value = event.target.value;
    if(value == 'annotated') {
      word.type = WordType.Annotated;
    } else if(value == 'ignored') {
      word.type = WordType.Ignored;
    } else {
      print('ERROR: radio annotated color none selected');
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

  void closePopup() {
    print('CLOSE POPUP');
    textAnalysisService.annotatedText.editWord(null);
  }
}