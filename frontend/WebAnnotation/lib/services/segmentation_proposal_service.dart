import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/core.dart';

import 'package:WebAnnotation/app_service.dart';

class Syllable {
  String text;
  bool selected;

  Syllable(this.text, this.selected);
}

class Segmentation {
  List<Syllable> syllables;
  Segmentation(this.syllables);
}

class SegmentationProposal {
  String origin;
  String source;
  String hyphenation;
  String stressPattern;

  Segmentation segmentation;

  SegmentationProposal(this.origin, this.source, this.hyphenation, this.stressPattern) {
    var syllables = [];
    var wordSegmentation = hyphenation.split("-");
    int i = 0;
    for(var s in wordSegmentation) {
      if(s.isEmpty) {
        continue;
      }

      print("segments: " + wordSegmentation.length.toString() + ", stresspattern: " + this.stressPattern + ",len:" + this.stressPattern.length.toString());

      bool stressed = false;
      if(i < stressPattern.length) {
        stressed = (this.stressPattern[i] == "1");
      }

      syllables.add(new Syllable(s, stressed));

      i++;
    }

    this.segmentation = new Segmentation(syllables);
  }
}

/// service description
@Injectable()
class SegmentationProposalService {
  List<SegmentationProposal> segmentationProposals = [];

  Future<bool> querySegmentationProposals(String word) async {
    this.segmentationProposals = [];

    String url = AppService.SERVER_URL + "/query/segmentation/" + word;

    return HttpRequest.getString(url).then((String response) {
      var backendProposals = JSON.decode(response);

      for(var s in backendProposals) {
        SegmentationProposal seg = new SegmentationProposal(s['origin'], s['source'], s['hyphenation'], s['stress_pattern']);
        this.segmentationProposals.add(seg);
      }

      return true;
    }).catchError((error) {
      print('error querying segmentation proposals: ' + error.toString());
      return false;
    });
  }
}