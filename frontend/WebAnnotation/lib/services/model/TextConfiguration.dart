class TextConfiguration {
  int id;

  String name;

  String stressed_color;
  String unstressed_color;
  String word_background;

  double font_size;
  double line_height;
  double syllable_distance;
  double word_distance;

  bool use_background;
  bool highlight_foreground;
  bool stressed_bold;

  TextConfiguration(this.id, this.name, this.stressed_color, this.unstressed_color,
      this.word_background, this.font_size, this.line_height, this.word_distance,
      this.syllable_distance, this.use_background, this.highlight_foreground, this.stressed_bold);

  TextConfiguration.copy(TextConfiguration c) {
    this.id = c.id;
    this.name = c.name;

    this.stressed_color = c.stressed_color;
    this.unstressed_color = c.unstressed_color;
    this.word_background = c.word_background;

    this.font_size = c.font_size;
    this.line_height = c.line_height;
    this.syllable_distance = c.syllable_distance;
    this.word_distance = c.word_distance;

    this.use_background = c.use_background;
    this.highlight_foreground = c.highlight_foreground;
    this.stressed_bold = c.stressed_bold;
  }
}