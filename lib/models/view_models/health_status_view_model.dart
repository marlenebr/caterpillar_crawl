import 'package:flutter/foundation.dart';

class HealthStatusViewModel extends ChangeNotifier {
  int _lifeCount = 0;
  int get lifeCount => _lifeCount;

  void setHealthStatus(int lifeCount) {
    _lifeCount = lifeCount;
    notifyListeners();
  }
}
