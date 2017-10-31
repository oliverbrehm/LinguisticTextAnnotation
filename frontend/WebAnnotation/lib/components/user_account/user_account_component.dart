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

  UserAccountComponent(this.appService, this.userAccountService, this.router);

  @override
  Future<Null> ngOnInit() async {
    if(this.loggedIn()) {
      queryUserTexts();
      queryUserWords();
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
        this.queryUserWords();
      }
      else {
        appService.errorMessage("Login fehlgeschlagen");
        passwordText = "";
      }
    });
  }

  List<UserText> userTexts() {
    return userAccountService.userTexts;
  }

  List<UserWord> userWords() {
    return userAccountService.userWords;
  }

  void queryUserTexts() {
    userAccountService.queryTexts().then((success) {
      if(!success) {
        appService.errorMessage("Abrufen der User Texte fehlgeschlagen.");
      }
    });
  }

  void analyseText(UserText userText) {
    String text = userText.text;
    router.navigate(['TextAnalysisParam', {'text': text}]);
  }

  void deleteText(UserText userText) {
    String title = userText.title;

    userAccountService.deleteText(userText).then((success) {
      if(!success) {
        appService.errorMessage("Error deleting text " + title);
      }
    });
  }

  void queryUserWords() {
    userAccountService.queryWords().then((success) {
      if(!success) {
        appService.errorMessage("Abrufen der User Wörter fehlgeschlagen.");
      }
    });
  }

  void deleteUserWord(UserWord userWord) {
    userAccountService.deleteWord(userWord).then((success) {
      if(!success) {
        appService.errorMessage("Löschen des Wortes " + userWord.text +" fehlgeschlagen.");
      }
    });
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

  void deleteAccount() {
    appService.errorMessage("deleteAccount: TODO");
  }
}