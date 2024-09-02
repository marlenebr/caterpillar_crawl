import 'package:flutter/material.dart';

class ActionMeleeButtonViewModel extends ChangeNotifier {
  String? _imagePath;
  String? get imagePath => _imagePath;

  Function? _onTab = () => ();
  Function? get onTab => _onTab;

  int _weaponDuration = 0;
  int get weaponDuration => _weaponDuration;

  int _maxWeaponDuration = 0;
  int get maxWeaponDuration => _maxWeaponDuration;

  GlobalKey globalKey;
  ActionMeleeButtonViewModel()
      : globalKey = GlobalKey(),
        _maxWeaponDuration = 1,
        _weaponDuration = 0;

  void setWeaponDurationDown() {
    _weaponDuration--;
    if (_weaponDuration <= 0) {
      _weaponDuration = 0;
      //RESET TO EMPTY WEAPON
      onSetEmpty();
    }
    notifyListeners();
  }

  void onChangeType(String imagePath, Function callBack) {
    _onTab = callBack;
    _imagePath = imagePath;
    notifyListeners();
  }

  void onSetEmpty() {
    _onTab = null;
    _imagePath = null;
    notifyListeners();
  }

  void resetDuration(int value) {
    _maxWeaponDuration = value;
    _weaponDuration = value;
    notifyListeners();
  }
}
