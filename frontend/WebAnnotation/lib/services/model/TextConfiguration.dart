import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';

enum WordPOSPolicy {
  Annotate,
  Unstressed,
  Ignore
}

class WordPOS {
  String name;
  String cssClassName;
  String color;
  WordPOSPolicy policy;

  bool posTagMatches(String posTag) {
    switch(name) {
      case 'Nomen':
        return posTag == 'NOUN';
      case 'Eigenname':
        return posTag == 'PROPN';
      case 'Verb':
        return posTag == 'VERB';
      case 'Hilfsverb':
        return posTag == 'AUX';
      case 'Adjektiv':
        return posTag == 'ADJ';
      case 'Adverb':
        return posTag == 'ADV';
      case 'Artikel':
        return posTag == 'DET';
      case 'Adposition':
        return posTag == 'ADP';
      case 'Pronomen':
        return posTag == 'PRON';
      case 'Konjunktion':
        return posTag == 'CONJ' || posTag == 'SCONJ';
      case 'Zahl':
        return posTag == 'NUM';
      case 'Partikel':
        return posTag == 'PART';
      default:
        return false;
    }
  }

  WordPOS(this.name, this.cssClassName, this.color, this.policy);
}

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

  List<WordPOS> wordPosList = [
    new WordPOS("Nomen", "pos-noun" , "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Eigenname", "pos-propn", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Verb", "pos-verb", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Hilfsverb", "pos-aux", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Adjektiv", "pos-adj", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Adverb", "pos-adv", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Artikel", "pos-det", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Adposition", "pos-adp", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Pronomen", "pos-pron", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Konjunktion", "pos-conj", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Zahl", "pos-num", "#000000", WordPOSPolicy.Annotate),
    new WordPOS("Partikel", "pos-part", "#000000", WordPOSPolicy.Annotate),
  ];

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

  Map<String, String> json() {
    return {
      'id': this.id.toString(),
      'name': this.name,

      'stressed_color': this.stressed_color,
      'unstressed_color': this.unstressed_color,
      'word_background': this.word_background,

      'line_height': this.line_height.toString(),
      'word_distance': this.word_distance.toString(),
      'syllable_distance': this.syllable_distance.toString(),
      'font_size': this.font_size.toString(),

      'use_background': this.use_background.toString(),
      'highlight_foreground': this.highlight_foreground.toString(),
      'stressed_bold': this.stressed_bold.toString()
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

        double line_height = c['line_height'];
        double word_distance = c['word_distance'];
        double syllable_distance = c['syllable_distance'];
        double font_size = c['font_size'];

        bool use_background = c['use_background'];
        bool highlight_foreground = c['highlight_foreground'];
        bool stressed_bold = c['stressed_bold'];

        textConfigurations.add(new TextConfiguration(id, name, stressed_color,
            unstressed_color, word_background, font_size, line_height,
            word_distance, syllable_distance, use_background,
            highlight_foreground, stressed_bold));
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