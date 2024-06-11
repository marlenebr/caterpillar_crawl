import 'package:flutter/material.dart';

class ChangableIntValue extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void setValue(int newValue) {
    _value = newValue;
    notifyListeners();
  }
}

class SnackCountValue extends ChangableIntValue {
  SnackCountValue(int initValue) {
    setValue(initValue);
  }
}

class EnemyCountValue extends ChangableIntValue {
  EnemyCountValue(int initValue) {
    setValue(initValue);
  }
}

class MaxLevelCountValue extends ChangableIntValue {
  MaxLevelCountValue(int initValue) {
    setValue(initValue);
  }
}
