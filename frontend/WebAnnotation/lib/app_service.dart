import 'package:angular/core.dart';

@Injectable()
class AppService {
  //static final SERVER_URL = "http://ec2-18-221-249-140.us-east-2.compute.amazonaws.com:8000";
  static final SERVER_URL = "http://localhost:8000";

  String infoMessageText = "";
  String errorMessageText = "";

  void infoMessage(String message) {
    infoMessageText = message;
    errorMessageText = "";
  }
  void errorMessage(String message) {
    errorMessageText = message;
    infoMessageText = "";
  }

  void clearMessage() {
    errorMessageText = "";
    infoMessageText = "";
  }
}