// Copyright (c) 2017, oliver. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:WebAnnotation/app_component.dart';

void main() {
  bootstrap(AppComponent,[
      ROUTER_PROVIDERS,
      provide(LocationStrategy, useClass: HashLocationStrategy)]
  );
}
