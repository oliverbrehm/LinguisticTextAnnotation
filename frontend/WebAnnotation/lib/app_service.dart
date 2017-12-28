import 'dart:async';
import 'package:angular/core.dart';

import 'dart:html';

@Injectable()
class AppService {
  //static final SERVER_URL = "http://ec2-18-221-249-140.us-east-2.compute.amazonaws.com:8000";
  static final SERVER_URL = "http://localhost:8000";

  String infoMessageText = "";
  String errorMessageText = "";

  void infoMessage(String message) {
    this.scrollToTop();
    infoMessageText = message;
    errorMessageText = "";
  }
  void errorMessage(String message) {
    this.scrollToTop();
    errorMessageText = message;
    infoMessageText = "";
  }

  void clearMessage() {
    this.scrollToTop();
    errorMessageText = "";
    infoMessageText = "";
  }

  void scrollToTop() {
    new Future.delayed(const Duration(microseconds: 10), () {
      querySelector("body").scrollTop = 0;
      window.scrollTo(0, 0);    });
  }
}