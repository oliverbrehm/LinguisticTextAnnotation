import 'dart:async';

import 'package:angular/core.dart';

/// service description
@Injectable()
class TextAnalysisService {
  String lookup(String text) {
    return "lookup: " + text;
  }
}
