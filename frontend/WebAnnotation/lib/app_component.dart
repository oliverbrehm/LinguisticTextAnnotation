// Copyright (c) 2017, oliver. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';

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

  //static final SERVER_URL = "http://ec2-18-221-249-140.us-east-2.compute.amazonaws.com:8000";
  static final SERVER_URL = "http://localhost:8000";

  final UserAccountService userAccountService;

  AppComponent(this.userAccountService);

  @override
  ngOnInit() async {

  }
}
