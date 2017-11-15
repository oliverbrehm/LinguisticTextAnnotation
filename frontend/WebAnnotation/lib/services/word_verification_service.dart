import 'package:angular/core.dart';

import 'dart:async';
import 'dart:html';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/model/TextConfiguration.dart';
import 'package:WebAnnotation/services/model/UserText.dart';
import 'package:WebAnnotation/services/model/UserWord.dart';

/// service description
@Injectable()
class WordVerificationService {

  WordVerificationService();

  Future<int> getNumberOfWordsRemaining() async {
    return new Future.delayed(const Duration(seconds: 1), () => 0);
  }

  Future<String> getNextWord() async {
    return new Future.delayed(const Duration(seconds: 1), () => "Kreidefelsen");
  }

  Future<bool> submitSegmentation() async {
    return new Future.delayed(const Duration(seconds: 1), () => false);
  }
}