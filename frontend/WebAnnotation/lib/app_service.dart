import 'package:angular/core.dart';

import 'dart:html';

@Injectable()
class AppService {
  //static final SERVER_URL = "http://ec2-18-221-249-140.us-east-2.compute.amazonaws.com:8000";
  static final SERVER_URL = "http://localhost:8000";

  String infoMessageText = "";
  String errorMessageText = "";

  void infoMessage(String message) {
    querySelector("body").scrollTop = 0;
    infoMessageText = message;
    errorMessageText = "";
  }
  void errorMessage(String message) {
    querySelector("body").scrollTop = 0;
    errorMessageText = message;
    infoMessageText = "";
  }

  void clearMessage() {
    errorMessageText = "";
    infoMessageText = "";
  }

  String decodeWord(String src) {
    String result = src.replaceAll("ä", "ae")
        .replaceAll("ö", "oe")
        .replaceAll("ü", "ue");
    return result.toLowerCase();
  }
}