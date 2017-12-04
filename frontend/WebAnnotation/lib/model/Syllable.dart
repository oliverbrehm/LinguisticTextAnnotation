import 'package:WebAnnotation/model/TextConfiguration.dart';

class Syllable {
  String text;
  bool stressed;

  Map<String, String> styles = {};
  void updateStyles(TextConfiguration c, bool ignored, bool unstressed, bool isLastSyllable) {
    if(ignored) {
      styles = {
        'margin-right': "0",
        'font-weight': "normal",
        'color': c.highlight_foreground ? c.unstressed_color : "inherit",
        'background-color': !c.highlight_foreground ? c.unstressed_color : "inherit"
      };
    } else {
      String highlightColor = (!unstressed && this.stressed) ? c.stressed_color : c.unstressed_color;
      styles = {
        'margin-right': !isLastSyllable ? (c.syllable_distance.toString() + "em") : "0",
        'font-weight': (!unstressed && this.stressed && c.stressed_bold) ? "bold" : "normal",
        'color': c.highlight_foreground ? highlightColor : "inherit",
        'background-color': !c.highlight_foreground ? highlightColor : "inherit"
      };
    }
  }

  Syllable(this.text, this.stressed);
}