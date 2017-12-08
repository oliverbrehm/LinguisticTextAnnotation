import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:angular_router/angular_router.dart';

@Component(
    selector: 'user-register',
    styleUrls: const ['user.css'],
    templateUrl: 'user_register_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives
    ]
)
class UserRegisterComponent implements OnInit {

  final AppService appService;
  final UserAccountService userAccountService;
  final Router router;

  String emailText = "";
  String passwordText = "";

  String firstNameText = "";
  String lastNameText = "";

  bool expertChecked = false;

  UserRegisterComponent(this.appService, this.userAccountService, this.router);

  @ViewChild('emailInput')
  MaterialInputComponent emailInput;

  @ViewChild('passwordInput')
  MaterialInputComponent passwordInput;

  @ViewChild('firstNameInput')
  MaterialInputComponent firstNameInput;

  @ViewChild('lastNameInput')
  MaterialInputComponent lastNameInput;

  @override
  Future<Null> ngOnInit() async {

  }

  bool validateEmail() {
    if(emailText.isEmpty) {
      return false;
    }

    if(emailInput.error != null && !emailInput.error.isEmpty) {
      return false;
    }

    return true;
  }

  bool validatePassword() {
    if(passwordText.isEmpty) {
      passwordInput.error = "Bitte Passwort eingeben";
      return false;
    }

    if(passwordText.length < 8) {
      passwordInput.error = "Passwort zu kurz (min. 8 Zeichen)";
      return false;
    }

    passwordInput.error = "";
    return true;
  }

  bool validateFirstName() {
    if(firstNameText.isEmpty) {
      firstNameInput.error = "Bitte Vornamen eingeben";
      return false;
    }

    firstNameInput.error = "";
    return true;
  }

  bool validateLastName() {
    if(lastNameText.isEmpty) {
      lastNameInput.error = "Bitte Nachnamen eingeben";
      return false;
    }

    lastNameInput.error = "";
    return true;
  }

  bool validate() {
    emailInput.focused = false;
    passwordInput.focused = false;
    firstNameInput.focused = false;
    lastNameInput.focused = false;

    return validateEmail()
        && validatePassword()
        && validateFirstName()
        && validateLastName();
  }

  void register() {
    appService.clearMessage();

    if(!validate()) {
      appService.errorMessage("Bitte machen ergängzen Sie fehlende Angaben.");
      return;
    }

    userAccountService.register(emailText, passwordText, firstNameText
        , lastNameText, expertChecked).then((success) {
      if(success) {
        appService.infoMessage("Registrierung erfolgreich als " + emailText + ".");
        router.navigate(["UserAccount"]);
      } else {
        appService.errorMessage("Registrierung nicht erfolgreich.");
      }
    });
  }
}











