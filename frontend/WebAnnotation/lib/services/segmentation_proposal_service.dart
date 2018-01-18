import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:WebAnnotation/model/common/Segmentation.dart';
import 'package:angular/core.dart';

import 'package:WebAnnotation/app_service.dart';
import 'package:WebAnnotation/services/segmentation_service.dart';

import 'package:WebAnnotation/model/text_annotation/Word.dart';

/// service description
@Injectable()
class SegmentationProposalService extends SegmentationService {

  SegmentationProposalService(): super();

  /**
   * queries segmentation proposals for a given word (String)
   *
   * segmentations can be retrieved using segmentationProposals()
   */
  @override
  Future<bool> query() async {
    if(wordText == null) {
      print('ERROR: set wordText first');
      return false;
    }

    this.segmentations = [];

    String url = AppService.SERVER_URL + "/query/segmentation/" + wordText;

    return HttpRequest.getString(url).then((String response) {
      var backendProposals = JSON.decode(response);

      for(var s in backendProposals) {
        Segmentation seg = new Segmentation(s['text'], s['origin'], s['source'], s['hyphenation'], s['stress_pattern']);
        this.segmentations.add(seg);
      }

      return true;
    }).catchError((error) {
      print('error querying segmentation proposals: ' + error.toString());
      return false;
    });
  }
}