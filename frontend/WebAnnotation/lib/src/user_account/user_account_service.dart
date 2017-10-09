import 'package:angular/core.dart';

import 'dart:async';

import 'dart:html';
import 'dart:convert';

/// service description
@Injectable()
class UserAccountService {

  Future<Null> login(String email, String password) async {
    String url = "http://localhost:8000/user/login";

    var data = {'email': email, 'password': password};

    return HttpRequest.postFormData(url, data).then((request) {
      return;
    });
  }

}