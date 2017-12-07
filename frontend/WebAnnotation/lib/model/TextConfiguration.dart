import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/model/PartOfSpeech.dart';

class TextConfiguration {
  int id;

  String name;

  String stressed_color;
  String unstressed_color;
  String word_background;
  String alternate_color;
  String syllable_separator;

  double font_size;
  double line_height;
  double syllable_distance;
  double word_distance;
  double letter_spacing;

  bool use_background;
  bool highlight_foreground;
  bool stressed_bold;
  bool use_alternate_color;
  bool use_syllable_separator;

  PartOfSpeechConfiguration partOfSpeechConfiguration;

  TextConfiguration(this.id, this.name, this.stressed_color, this.unstressed_color,
      this.word_background, this.alternate_color, this.syllable_separator, this.font_size, this.line_height, this.word_distance, this.letter_spacing,
      this.syllable_distance, this.use_background, this.highlight_foreground,
      this.stressed_bold, this.use_alternate_color, this.use_syllable_separator, this.partOfSpeechConfiguration);

  TextConfiguration.copy(TextConfiguration c) {
    this.id = c.id;
    this.name = c.name;

    this.stressed_color = c.stressed_color;
    this.unstressed_color = c.unstressed_color;
    this.word_background = c.word_background;
    this.alternate_color = c.alternate_color;
    this.syllable_separator = c.syllable_separator;

    this.font_size = c.font_size;
    this.line_height = c.line_height;
    this.syllable_distance = c.syllable_distance;
    this.word_distance = c.word_distance;
    this.letter_spacing = c.letter_spacing;

    this.use_background = c.use_background;
    this.highlight_foreground = c.highlight_foreground;
    this.stressed_bold = c.stressed_bold;
    this.use_alternate_color = c.use_alternate_color;
    this.use_syllable_separator = c.use_syllable_separator;

    this.partOfSpeechConfiguration = c.partOfSpeechConfiguration.copy();
  }

  Map json(){
    String posJson = JSON.encode(this.partOfSpeechConfiguration.json());

    return {
      'id': this.id.toString(),
      'name': this.name,

      'stressed_color': this.stressed_color,
      'unstressed_color': this.unstressed_color,
      'word_background': this.word_background,
      'alternate_color': this.alternate_color,
      'syllable_separator': this.syllable_separator,

      'line_height': this.line_height.toString(),
      'word_distance': this.word_distance.toString(),
      'syllable_distance': this.syllable_distance.toString(),
      'font_size': this.font_size.toString(),
      'letter_spacing': this.letter_spacing.toString(),

      'use_background': this.use_background.toString(),
      'highlight_foreground': this.highlight_foreground.toString(),
      'stressed_bold': this.stressed_bold.toString(),
      'use_alternate_color': this.use_alternate_color.toString(),
      'use_syllable_separator': this.use_syllable_separator.toString(),

      'part_of_speech_configuration': posJson
    };
  }

  static Future<List<TextConfiguration>> queryTextConfigurations(var credentials) async {
    String url = AppService.SERVER_URL + "/user/configuration/list";

    var data = credentials;

    return HttpRequest.postFormData(url, data).then((request) {
      var configurations = JSON.decode(request.response)['configurations'];

      List<TextConfiguration> textConfigurations = [];

      for (var c in configurations) {
        int id = c['id'];
        String name = c['name'];

        String stressed_color = c['stressed_color'];
        String unstressed_color = c['unstressed_color'];
        String word_background = c['word_background'];
        String alternate_color = c['alternate_color'];
        String syllable_separator = c['syllable_separator'];

        double line_height = c['line_height'];
        double word_distance = c['word_distance'];
        double syllable_distance = c['syllable_distance'];
        double font_size = c['font_size'];
        double letter_spacing = c['letter_spacing'];

        bool use_background = c['use_background'];
        bool highlight_foreground = c['highlight_foreground'];
        bool stressed_bold = c['stressed_bold'];
        bool use_alternate_color = c['use_alternate_color'];
        bool use_syllable_separator = c['use_syllable_separator'];

        PartOfSpeechConfiguration partOfSpeechConfiguration = new PartOfSpeechConfiguration();
        var posConfList = c['part_of_speech_configuration'];

        print("-----------");

        if(posConfList != null) {
          for(var posConf in posConfList) {
            print(posConf.toString());
            String posId = posConf['pos_id'];
            String posPolicy = posConf['policy'];
            partOfSpeechConfiguration.setPartOfSpeechPolicyString(posId, posPolicy);
          }
        }

        textConfigurations.add(new TextConfiguration(id, name, stressed_color,
            unstressed_color, word_background, alternate_color, syllable_separator, font_size, line_height,
            word_distance, letter_spacing, syllable_distance, use_background,
            highlight_foreground, stressed_bold, use_alternate_color, use_syllable_separator, partOfSpeechConfiguration));
      }

      return textConfigurations;
    }, onError: (error) {
      return null;
    });
  }

  static Future<bool> add(TextConfiguration configuration, var credentials) async {
    String url = AppService.SERVER_URL + "/user/configuration/add";

    var data = configuration.json();
    data.addAll(credentials);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> update(var credentials) async {
    String url = AppService.SERVER_URL + "/user/configuration/update";

    var data = this.json();
    data.addAll(credentials);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> delete(var credentials) async {
    String url = AppService.SERVER_URL + "/user/configuration/delete";

    var data = {
      'id': this.id.toString()
    };
    data.addAll(credentials);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }
}