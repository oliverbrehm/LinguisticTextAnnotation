import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'text_analysis_service.dart';

@Component(
  selector: 'text-analysis',
  styleUrls: const ['text_analysis_component.css'],
  templateUrl: 'text_analysis_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
  providers: const [TextAnalysisService],
)
class TextAnalysisComponent implements OnInit {
  final TextAnalysisService textAnalysisService;

  String lookupText = '';

  Text annotatedText;

  String errorText = '';

  bool analyzing = false;

  TextAnalysisComponent(this.textAnalysisService);

  @override
  Future<Null> ngOnInit() async {

  }

  void lookupWord() {
    analyzing = true;
    textAnalysisService.lookupWord(lookupText).then((text) {
      annotatedText = new Text(new List<Word>());
      analyzing = false;
    }, onError: (e) {
      // TODO error properties
      errorText = "Word not found.";
      analyzing = false;
    });
  }

  void lookup() {
    analyzing = true;
    textAnalysisService.lookupText(lookupText).then((response) {
      annotatedText = response;
      analyzing = false;
    }, onError: (e) {
      // TODO error properties
      print(e.toString());
      errorText = "Text could not be analyzed.";
      analyzing = false;
    });
  }

  void newText() {
    annotatedText = null;
  }
}
