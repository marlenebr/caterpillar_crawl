import 'package:flutter/foundation.dart';

class GameStateViewModel extends ChangeNotifier {
  PauseType _pauseType = PauseType.none;
  PauseType get pauseType => _pauseType;

  void setGamePause(PauseType pauseType) {
    _pauseType = pauseType;
    notifyListeners();
  }
}

enum PauseType { debug, settings, none }
