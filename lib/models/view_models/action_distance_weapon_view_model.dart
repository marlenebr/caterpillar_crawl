import 'package:flutter/material.dart';

class ActionDistanceWeaponViewModel extends ChangeNotifier {
  String _imagePath = "";
  String get imagePath => _imagePath;

  Function _onTab = () => ();
  Function get onTab => _onTab;

  GlobalKey globalKey;
  ActionDistanceWeaponViewModel() : globalKey = GlobalKey();

  void onChangeType(String imagePath, Function callBack) {
    _onTab = callBack;
    _imagePath = imagePath;
    notifyListeners();
  }
}


// class ActionMeleeWeaponButtonViewModel extends ChangeNotifier {
//   String _imagePath = "";
//   String get imagePath => _imagePath;

//   Function _onTab = () => ();
//   Function get onTab => _onTab;

//   GlobalKey globalKey;
//   ActionMeleeWeaponButtonViewModel() : globalKey = GlobalKey();

//   void onChangeType(String imagePath, Function callBack) {
//     _onTab = callBack;
//     _imagePath = imagePath;
//     notifyListeners();
//   }
// }
