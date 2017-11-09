import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/services/model/UserText.dart';

@Component(
    selector: 'user-textlist',
    styleUrls: const ['user.css'],
    templateUrl: 'user_textlist_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives
    ]
)
class UserTextlistComponent implements OnInit {

  final AppService appService;
  final UserAccountService userAccountService;

  final Router router;

  String emailText = "";
  String passwordText = "";

  UserTextlistComponent(this.appService, this.userAccountService, this.router);

  @override
  Future<Null> ngOnInit() async {
    if(userAccountService.loggedIn) {
      userAccountService.queryTexts().then((success) {
        if(!success) {
          appService.errorMessage("Abrufen der User Texte fehlgeschlagen.");
        }
      });
    }
  }

  List<UserText> userTexts() {
    return userAccountService.userTexts;
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
}