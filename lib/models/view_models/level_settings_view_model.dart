import 'package:flutter/material.dart';

class ChangableIntValue extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void setValue(int newValue) {
    _value = newValue;
    notifyListeners();
  }
}

class ChangableDoubleValue extends ChangeNotifier {
  double _value = 0;
  double get value => _value;

  void setValue(double newValue) {
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

class MapSizeValue extends ChangableIntValue {
  MapSizeValue(int initValue) {
    setValue(initValue);
  }
}

class MaxCaterpillarLength extends ChangableIntValue {
  MaxCaterpillarLength(int initValue) {
    setValue(initValue);
  }
}

class MovingSpeedMultiplierValue extends ChangableDoubleValue {
  final double _initValue;
  MovingSpeedMultiplierValue(double initValue) : _initValue = initValue {
    setValue(initValue);
  }

  void goUp() {
    setValue(value + 0.2);
  }

  void goDown() {
    setValue(value - 0.2);
  }

  void reset() {
    setValue(_initValue);
  }
}
