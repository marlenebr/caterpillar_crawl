import 'package:flutter/foundation.dart';

class GameStateViewModel extends ChangeNotifier {
  bool _isPaused = false;
  bool get isPaused => _isPaused;

  // double _aTestValue = 30;
  // double get aTestValue => _aTestValue;

  void setGamePause(bool isPaused) {
    _isPaused = isPaused;
    notifyListeners();
  }

  // void setaTestValue(double aTestValue) {
  //   _aTestValue = aTestValue;
  //   print("SLIDER TEST: $aTestValue");
  //   notifyListeners();
  // }
}
