import 'package:WebAnnotation/model/text_configuration/TextConfiguration.dart';

class Syllable {
  String text;
  bool stressed;
  bool isLast;

  Map<String, String> styles = {};
  Map<String, String> separatorStyles = {};

  void updateStyles(TextConfiguration c, bool ignored, bool unstressed, bool alternate) {
    if(ignored) {
      styles = {
        'margin-right': "0",
        'font-weight': "normal",
        'color': c.highlight_foreground ? c.unstressed_color : "inherit",
        'background-color': !c.highlight_foreground ? c.unstressed_color : "inherit"
      };
    } else {
      String unstressedColor = alternate ? c.alternate_color : c.unstressed_color;
      String highlightColor = (!unstressed && this.stressed) ? c.stressed_color : unstressedColor;
      styles = {
        'margin-right': !isLast ? (c.syllable_distance.toString() + "em") : "0",
        'font-weight': (!unstressed && this.stressed && c.stressed_bold) ? "bold" : "normal",
        'color': c.highlight_foreground ? highlightColor : "inherit",
        'background-color': !c.highlight_foreground ? highlightColor : "inherit"
      };
    }

    separatorStyles = {
      'margin-right': c.syllable_distance.toString() + "em"
    };
  }

  Syllable(this.text, this.stressed, this.isLast);
}