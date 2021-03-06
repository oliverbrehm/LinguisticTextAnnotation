import 'dart:async';

import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/components/user_account/user_login_component.dart';
import 'package:WebAnnotation/components/user_account/user_textlist_component.dart';
import 'package:WebAnnotation/components/user_account/user_wordlist_component.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'user-account',
  styleUrls: const ['user.css'],
  templateUrl: 'user_account_component.html',
  directives: const [
    CORE_DIRECTIVES,
    ROUTER_DIRECTIVES,
    materialDirectives,
    formDirectives,
    UserLoginComponent,
    UserTextlistComponent,
    UserWordlistComponent
  ],
  providers: const []
)
class UserAccountComponent implements OnInit {

  final AppService appService;
  final UserAccountService userAccountService;
  final TextAnalysisService textAnalysisService;
  final Router router;

  UserAccountComponent(this.appService, this.userAccountService, this.textAnalysisService, this.router);

  @override
  Future<Null> ngOnInit() async {

  }

  String userEmail() {
    return userAccountService.email;
  }

  String userFullName() {
    return userAccountService.firstName + " " + userAccountService.lastName;
  }

  void logout() {
    appService.clearMessage();
    userAccountService.logout();
    textAnalysisService.clearText();
    appService.infoMessage("Logout erfolgreich.");
  }

  void deleteAccount() {
    // TODO deleteAccount
    appService.errorMessage("deleteAccount: TODO");
  }
}