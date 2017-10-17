// Copyright (c) 2017, oliver. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/src/text_analysis/text_analysis_component.dart';
import 'package:WebAnnotation/src/text_analysis/text_analysis_service.dart';
import 'package:WebAnnotation/src/user_account/user_account_component.dart';
import 'package:WebAnnotation/src/user_account/user_account_service.dart';
import 'package:WebAnnotation/app_service.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [CORE_DIRECTIVES, ROUTER_DIRECTIVES, materialDirectives, formDirectives, TextAnalysisComponent, UserAccountComponent],
  providers: const [ROUTER_PROVIDERS, materialProviders, TextAnalysisService, UserAccountService, AppService],
)
@RouteConfig(const [
  const Route(
      path: '/text_analysis',
      name: 'TextAnalysis',
      component: TextAnalysisComponent,
      useAsDefault: true),
  const Route(
      path: '/text_analysis/:text',
      name: 'TextAnalysisParam',
      component: TextAnalysisComponent),
  const Route(
      path: '/user_account',
      name: 'UserAccount',
      component: UserAccountComponent),
  const Route(
      path: '/**',
      name: 'NotFound',
      component: TextAnalysisComponent)
])
class AppComponent implements OnInit {

  final AppService appService;
  final TextAnalysisService textAnalysisService;
  final UserAccountService userAccountService;

  AppComponent(this.appService, this.textAnalysisService, this.userAccountService);

  @override
  ngOnInit() async {

  }

  String userText() {
    if(userAccountService.loggedIn) {
      return userAccountService.email;
    }

    return "Login";
  }

  String info() {
    return appService.infoMessageText;
  }

  String error() {
    return appService.errorMessageText;
  }
}
