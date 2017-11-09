import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/app_service.dart';

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
        double line_height = c['line_height'];

        // TODO
        String word_background = '#FFFFFF';

        double word_distance = 0.3;
        double syllable_distance = 0.1;
        double font_size = 1.0;

        bool use_background = false;
        bool highlight_foreground = false;
        bool stressed_bold = true;

        textConfigurations.add(new TextConfiguration(id, name, stressed_color,
            word_background, unstressed_color, font_size, line_height,
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

    var data = {
      'name': configuration.name,
      'stressed_color': configuration.stressed_color,
      'unstressed_color': configuration.unstressed_color,
      'line_height': configuration.line_height.toString()
    };
    data.addAll(credentials);

    return HttpRequest.postFormData(url, data).then((request) {
      return true;
    }, onError: (error) {
      return false;
    });
  }

  Future<bool> update(var credentials) async {
    String url = AppService.SERVER_URL + "/user/configuration/update";

    var data = {
      'id': this.id.toString(),
      'name': this.name,
      'stressed_color': this.stressed_color,
      'unstressed_color': this.unstressed_color,
      'line_height': this.line_height.toString()
    };
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