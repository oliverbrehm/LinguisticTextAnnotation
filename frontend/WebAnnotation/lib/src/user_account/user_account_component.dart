import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/src/user_account/user_account_service.dart';

@Component(
  selector: 'user-account',
  styleUrls: const ['user_account_component.css'],
  templateUrl: 'user_account_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    formDirectives
  ]
)
class UserAccountComponent implements OnInit {
  final UserAccountService userAccountService;

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

  String emailText = "";
  String passwordText = "";

  String userListText = "";

  List<String> userTexts = [];

  String newText = "";

  UserAccountComponent(this.userAccountService);

  @override
  Future<Null> ngOnInit() async {
    if(this.loggedIn()) {
      this.queryUserTexts();
    }
  }

  bool loggedIn() {
    return userAccountService.loggedIn;
  }

  String userEmail() {
    return userAccountService.email;
  }

  void login() {
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.login(emailText, passwordText).then((success) {
      if(success) {
        this.queryUserTexts();
      }
      else {
        errorMessage("Login fehlgeschlagen");
        passwordText = "";
      }
    });
  }

  void queryUserTexts() {
    userAccountService.queryTexts().then((texts) {
      this.userTexts = texts;
    });
  }

  void addUserText() {
    if(this.newText.isEmpty) {
      errorMessage("Bitte Text eingeben.");
      return;
    }

    userAccountService.addText(this.newText).then((success) {
      if(success) {
        infoMessage("Text hinzugefügt.");
        queryUserTexts();
      }
    });
  }

  void analyseText(String userText) {
    // TODO link to analyse text
    infoMessage("TODO link to: " + userText);
  }

  void logout() {
    userAccountService.logout();
    infoMessage("Logout erfolgreich.");
  }

  void register() {
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.register(emailText, passwordText).then((success) {
      if(success) {
        infoMessage("Registrierung erfolgreich als " + emailText + ".");
      } else {
        errorMessage("Registrierung nicht erfolgreich.");
      }
    });
  }

}