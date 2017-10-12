// Copyright (c) 2017, oliver. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:firebase/firebase.dart' as firebase;
import 'dart:async';

import 'package:WebAnnotation/src/text_analysis/text_analysis_component.dart';
import 'package:WebAnnotation/src/text_analysis/text_analysis_service.dart';
import 'package:WebAnnotation/src/user_account/user_account_component.dart';
import 'package:WebAnnotation/src/user_account/user_account_service.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [ROUTER_DIRECTIVES, materialDirectives, formDirectives, TextAnalysisComponent, UserAccountComponent],
  providers: const [ROUTER_PROVIDERS, materialProviders, TextAnalysisService, UserAccountService],
)
@RouteConfig(const [
  const Route(
      path: '/text_analysis',
      name: 'TextAnalysis',
      component: TextAnalysisComponent,
      useAsDefault: true),
  const Route(
      path: '/user_account',
      name: 'UserAccount',
      component: UserAccountComponent)
])
class AppComponent implements OnInit {

  int count = 0;
  firebase.DatabaseReference ref;

  firebase.Database database;

  @override
  ngOnInit() async {
    firebase.initializeApp(
        apiKey: "AIzaSyAKA7wUv2EifaWibh_8iUAf-Ihis-czz1k",
        authDomain: "linguistictextannotation.firebaseapp.com",
        databaseURL: "https://linguistictextannotation.firebaseio.com",
        storageBucket: "",
    );

    database = firebase.database();
    count = await database.ref('count').once('value').then((event) {
      return event.snapshot.val();
    });
  }

  like() async {
    count++;
    await database.ref('count').set(this.count);
  }

  dislike() async {
    count--;
    await database.ref('count').set(this.count);
  }

  String testWord = "";
  addTest() async {
    if(testWord.isNotEmpty) {
      firebase.DatabaseReference ref = database.ref('words');
      firebase.DatabaseReference itemRef = ref.push();
      itemRef.set({
        'text': testWord
      });
    }
  }
}
