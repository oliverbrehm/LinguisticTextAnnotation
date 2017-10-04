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
  String annotatedText = '';

  TextAnalysisComponent(this.textAnalysisService);

  @override
  Future<Null> ngOnInit() async {

  }

  void lookup() {
    textAnalysisService.lookup(lookupText).then((text) {
      annotatedText = text;
    }, onError: (e) {
      // TODO error properties
      annotatedText = "Word not found.";
    });
    lookupText = '';
  }
}
