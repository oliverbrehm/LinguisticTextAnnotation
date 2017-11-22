import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';

@Component(
    selector: 'user-login',
    styleUrls: const ['user.css'],
    templateUrl: 'user_login_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives
    ]
)
class UserLoginComponent implements OnInit {

  final AppService appService;
  final UserAccountService userAccountService;

  String emailText = "";
  String passwordText = "";

  UserLoginComponent(this.appService, this.userAccountService);

  @override
  Future<Null> ngOnInit() async {

  }

  void login() {
    appService.clearMessage();
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.login(emailText, passwordText).then((success) {
      if(success) {
        userAccountService.queryTexts().then((success) {
          if(!success) {
            appService.errorMessage("Abrufen der User Texte fehlgeschlagen.");
          }
        });

        userAccountService.queryWords().then((success) {
          if(!success) {
            appService.errorMessage("Abrufen der User Wörter fehlgeschlagen.");
          }
        });
      }
      else {
        appService.errorMessage("Login fehlgeschlagen");
        passwordText = "";
      }
    });
  }
}