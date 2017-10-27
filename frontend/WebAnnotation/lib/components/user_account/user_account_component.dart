import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';

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

  final AppService appService;
  final UserAccountService userAccountService;

  final Router router;

  String emailText = "";
  String passwordText = "";

  String userListText = "";

  List<String> userTexts = [];

  String newText = "";

  UserAccountComponent(this.appService, this.userAccountService, this.router);

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
    appService.clearMessage();
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.login(emailText, passwordText).then((success) {
      if(success) {
        this.queryUserTexts();
      }
      else {
        appService.errorMessage("Login fehlgeschlagen");
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
    appService.clearMessage();
    if(this.newText.isEmpty) {
      appService.errorMessage("Bitte Text eingeben.");
      return;
    }

    userAccountService.addText(this.newText).then((success) {
      if(success) {
        appService.infoMessage("Text hinzugefügt.");
        queryUserTexts();
      }
    });
  }

  void analyseText(String userText) {
    router.navigate(['TextAnalysisParam', {'text': userText}]);
  }

  void logout() {
    appService.clearMessage();
    userAccountService.logout();
    appService.infoMessage("Logout erfolgreich.");
  }

  void register() {
    appService.clearMessage();
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.register(emailText, passwordText).then((success) {
      if(success) {
        appService.infoMessage("Registrierung erfolgreich als " + emailText + ".");
      } else {
        appService.errorMessage("Registrierung nicht erfolgreich.");
      }
    });
  }

}