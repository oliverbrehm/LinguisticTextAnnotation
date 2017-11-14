import 'package:angular/angular.dart';
import 'dart:html';

import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/components/text_analysis/word_detail_component.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/model/Word.dart';
import 'package:WebAnnotation/services/model/AnnotationText.dart';

@Component(
  selector: 'text-preview',
  styleUrls: const ['text_analysis.css'],
  templateUrl: 'text_preview_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives,
    WordDetailComponent
  ],
  providers: const [],
)
class TextPreviewComponent implements OnInit {
  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  final Router router;

  TextPreviewComponent(this.appService, this.textAnalysisService,
      this.userAccountService, this.router);

  @override
  ngOnInit() {
    // TODO: implement ngOnInit
  }

  AnnotationText annotatedText() {
    return textAnalysisService.annotatedText;
  }

  void startWordReview() {
    // search first unknown word
    Word w = textAnalysisService.annotatedText.nextMissingWord();
    if(w == null) {
      appService.infoMessage("Keine unbekannten Wörter.");
      return;
    }

    wordReview(w);
  }

  void wordReview(Word word) {
    if(userAccountService.loggedIn) {
      router.navigate(['WordReview', {'word': word.text}]);
    } else {
      router.navigate(['UserAccount']);
      appService.infoMessage('Sie müssen eingeloggt sein, um Wörter hinzuzufügen.');
    }
  }

  void editWord(Word word) {
    print('edit WORD');
    annotatedText().editWord(word);
  }
}