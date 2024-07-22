import 'package:flutter/material.dart';

class HealthStatusViewModel extends ChangeNotifier {
  int _lifeCount = 0;
  int get lifeCount => _lifeCount;

  GlobalKey globalKey;
  HealthStatusViewModel() : globalKey = GlobalKey();

  void setHealthStatus(int lifeCount) {
    _lifeCount = lifeCount;
    notifyListeners();
  }
}
