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

  String userEmail = "";

  bool loggedIn = false;

  UserAccountComponent(this.userAccountService);

  @override
  Future<Null> ngOnInit() async {

  }

  void login() {
    if(emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    userAccountService.login(emailText, passwordText).then((response) {
      userEmail = emailText;
      loggedIn = true;
    }, onError: (error) {
      print("error logging in");
      emailText = "";
      passwordText = "";
    });
  }


}