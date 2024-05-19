import 'package:flutter/foundation.dart';

class MeleeWeaponViewModel extends ChangeNotifier {
  double _meleeTimerCountDown = 0;
  double get meleeTimerCountDown => _meleeTimerCountDown;

  void setTimerCountDown(double time) {
    _meleeTimerCountDown = time;
    notifyListeners();
  }
}
