// Copyright (c) 2017, oliver. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:WebAnnotation/components/text_analysis/text_analysis_component.dart';
import 'package:WebAnnotation/services/text_analysis_service.dart';
import 'package:WebAnnotation/components/user_account/user_account_component.dart';
import 'package:WebAnnotation/services/user_account_service.dart';
import 'package:WebAnnotation/components/word_review/word_review_component.dart';
import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/segmentation_proposal_service.dart';
import 'package:WebAnnotation/components/word_verification/word_verification_component.dart';
import 'package:WebAnnotation/components/home/home_component.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [CORE_DIRECTIVES, ROUTER_DIRECTIVES, materialDirectives,
  formDirectives, TextAnalysisComponent, UserAccountComponent,
  WordReviewComponent, WordVerificationComponent, HomeComponent],
  providers: const [ROUTER_PROVIDERS, materialProviders, TextAnalysisService,
  UserAccountService, AppService, SegmentationProposalService],
)
@RouteConfig(const [
  const Route(
      path: '/home',
      name: 'Home',
      component: HomeComponent,
      useAsDefault: true),
  const Route(
      path: '/text_analysis',
      name: 'TextAnalysis',
      component: TextAnalysisComponent),
  const Route(
      path: '/text_analysis/:text',
      name: 'TextAnalysisParam',
      component: TextAnalysisComponent),
  const Route(
      path: '/word_review/:word',
      name: 'WordReview',
      component: WordReviewComponent),
  const Route(
      path: '/word_verification/',
      name: 'WordVerification',
      component: WordVerificationComponent),
  const Route(
      path: '/user_account',
      name: 'UserAccount',
      component: UserAccountComponent),
  const Route(
      path: '/**',
      name: 'NotFound',
      component: HomeComponent)
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
