import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:flutter/foundation.dart';

class CaterpillarStateViewModel extends ChangeNotifier {
  bool _isRemovingSegments = false;
  bool get isRemovingSegments => _isRemovingSegments;

  void setIsRemovingSegment(bool isRemovingSegments) {
    _isRemovingSegments = isRemovingSegments;
  }
}

class CaterpillarStatsViewModel extends ChangeNotifier {
  bool _isHurt = false;
  bool get isHurt => _isHurt;

  bool _isReadyToEgg = false;
  bool get isReadyToEgg => _isReadyToEgg;

  CaterpillarState _currentState = CaterpillarState.crawling;
  CaterpillarState get currentState => _currentState;

  //Points and stuff
  int _snacksEaten = 0;
  int get snackEaten => _snacksEaten;

  int _segmentCount = 0;
  int get segmentCount => _segmentCount;

  int _enemyKilled = 0;
  int get enemyKilled => _enemyKilled;

  int _enemiesInGame = 0;
  int get enemiesInGame => _enemiesInGame;

  int _enemyKilledSinceUlti = 0;
  int get enemyKilledSinceUlti => _enemyKilledSinceUlti;

  int _level = 0;
  int get level => _level;

  void setSnacksEaten(int snacksEaten) {
    _snacksEaten = snacksEaten;
    notifyListeners();
  }

  void setSegmentCount(int segmentCount) {
    _segmentCount = segmentCount;
    notifyListeners();
  }

  void onRemoveSegment() {
    _segmentCount--;
    notifyListeners();
  }

  void onAddSegment() {
    _segmentCount++;
    notifyListeners();
  }

  // void setEnemyKilled(int enemyKilled) {
  //   _enemyKilled = enemyKilled;
  //   notifyListeners();
  // }

  void setEnemiesInGame(int enemiesInGame) {
    _enemiesInGame = enemiesInGame;
    notifyListeners();
  }

  void onEnemyKilled() {
    _enemyKilled++;
    _enemyKilledSinceUlti++;
    notifyListeners();
  }

  void setLevelUp() {
    _level++;
    notifyListeners();
  }

  void onUlti() {
    _enemyKilledSinceUlti = 0;
    notifyListeners();
  }

  void setIsHurt(bool isHurt) {
    _isHurt = isHurt;
    //notifyListeners();
  }

  void setIsReadyToEgg(bool isReadyToEgg) {
    _isReadyToEgg = isReadyToEgg;
  }

  void setCaterpillarstate(CaterpillarState state) {
    _currentState = state;
    notifyListeners();
  }

  void reset() {
    _snacksEaten = 0;
    _segmentCount = 0;
    _enemyKilled = 0;
    _enemyKilledSinceUlti = 0;
    _level = 0;
    notifyListeners();
  }
}
