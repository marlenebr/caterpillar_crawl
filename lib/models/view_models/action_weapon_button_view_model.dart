import 'package:flutter/material.dart';

class ActionUltiAndDistanceButtonViewModel extends ChangeNotifier {
  String _imagePath = "";
  String get imagePath => _imagePath;

  Function _onTab = () => ();
  Function get onTab => _onTab;

  int _segmentCount = 0;
  int get segmentCount => _segmentCount;

  int _enemyKilledSinceUlti = 0;
  int get enemyKilledSinceUlti => _enemyKilledSinceUlti;

  GlobalKey globalKey;
  ActionUltiAndDistanceButtonViewModel() : globalKey = GlobalKey();

  void setSegmentCount(int segmentCount) {
    _segmentCount = segmentCount;
    notifyListeners();
  }

  void onEnemyKilled() {
    _enemyKilledSinceUlti++;
    notifyListeners();
  }

  void onChangeType(String imagePath, Function callBack) {
    _onTab = callBack;
    _imagePath = imagePath;
    notifyListeners();
  }

  void reset() {
    _segmentCount = 0;
    _enemyKilledSinceUlti = 0;
    notifyListeners();
  }
}

class ActionMeleeWeaponButtonViewModel extends ChangeNotifier {
  String _imagePath = "";
  String get imagePath => _imagePath;

  Function _onTab = () => ();
  Function get onTab => _onTab;

  GlobalKey globalKey;
  ActionMeleeWeaponButtonViewModel() : globalKey = GlobalKey();

  void onChangeType(String imagePath, Function callBack) {
    _onTab = callBack;
    _imagePath = imagePath;
    notifyListeners();
  }
}
