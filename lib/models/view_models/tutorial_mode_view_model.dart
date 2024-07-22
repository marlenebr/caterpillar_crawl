import 'package:flutter/material.dart';

class TutorialModeViewModel extends ChangeNotifier {
  bool _isInTutorialMode = false;
  bool get isInTutorialMode => _isInTutorialMode;

  void setValue(bool newValue) {
    _isInTutorialMode = newValue;
    notifyListeners();
  }
}
