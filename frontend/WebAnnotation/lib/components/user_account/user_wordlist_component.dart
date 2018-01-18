import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/model/user/UserEntry.dart';

@Component(
    selector: 'user-wordlist',
    styleUrls: const ['user.css'],
    templateUrl: 'user_wordlist_component.html',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives
    ]
)
class UserWordlistComponent implements OnInit {

  final AppService appService;
  final UserAccountService userAccountService;

  UserWordlistComponent(this.appService, this.userAccountService);

  @override
  Future<Null> ngOnInit() async {
    if(userAccountService.loggedIn) {
      userAccountService.queryWords().then((success) {
        if(!success) {
          appService.errorMessage("Abrufen der User Wörter fehlgeschlagen.");
        }
      });
    }
  }

  List<UserEntry> userWords() {
    return userAccountService.userWords;
  }

  void deleteUserWord(UserEntry userWord) {
    userAccountService.deleteWord(userWord).then((success) {
      if(!success) {
        appService.errorMessage("Löschen des Wortes " + userWord.text +" fehlgeschlagen.");
      }
    });
  }
}