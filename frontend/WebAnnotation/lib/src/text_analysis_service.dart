import 'dart:async';

import 'package:angular/core.dart';

import 'dart:html';

/// service description
@Injectable()
class TextAnalysisService {
  Future<String> lookup(String text) async {
    String url = "http://localhost:8000/queryWord/" + text;
    return HttpRequest.getString(url);
  }
}
