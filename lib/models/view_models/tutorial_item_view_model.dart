import 'package:caterpillar_crawl/models/data/tutorial_data.dart';
import 'package:caterpillar_crawl/ui/elements/hud_overlay_attention_marker.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TutorialItemViewModel extends ChangeNotifier {
  Function? _callbackToConfirm;
  Function? get callbackToConfirm => _callbackToConfirm;

  String _annotationText = "-";
  String get annotationText => _annotationText;

  bool _conditionReached = false;
  bool get conditionReached => _conditionReached;

  Vector2? _absolutePositionOfAttentionWidget;
  Vector2? get absolutePositionOfAttentionWidget =>
      _absolutePositionOfAttentionWidget;

  final GlobalKey<ShakeWidgetState> shakeKey;

  TutorialItemViewModel() : shakeKey = GlobalKey<ShakeWidgetState>();

  void setTutorialItemViewModel(
      Function? callbackToConfirm, Vector2? attentionItemPos) {
    _absolutePositionOfAttentionWidget = attentionItemPos;
    _callbackToConfirm = callbackToConfirm;
    notifyListeners();
  }

  void setConditionReached(bool value) {
    _conditionReached = value;
    notifyListeners();
  }

  void setInitDataWithoutNotify(TutorialData tutorialData) {
    _conditionReached = !tutorialData.isConditional;
    _annotationText = tutorialData.text;
  }
}
