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
  ],
  providers: const [UserAccountService],
)
class UserAccountComponent implements OnInit {
  final UserAccountService userAccountService;

  String emailText = "";
  String passwordText = "";

  String userListText = "";

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

  bool loggedIn = false;
  String userEmail = "";
  List<String> userTexts = [];
  String newText = "";

  UserAccountComponent(this.userAccountService);

  @override
  Future<Null> ngOnInit() async {

  }

  void login() {
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.login(emailText, passwordText).then((success) {
      if(success) {
        loggedIn = true;
        userEmail = emailText;

        this.queryUserTexts();
      }
      else {
        errorMessage("error logging in");
        emailText = "";
        passwordText = "";
        loggedIn = false;
      }
    });
  }

  void userList() {
    userAccountService.userList().then((users) {
      userListText = users;
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
        infoMessage("Added text.");
        queryUserTexts();
      }
    });
  }

  void logout() {
    userAccountService.logout();
    infoMessage("Succesfully logged out.");
    this.loggedIn = false;
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