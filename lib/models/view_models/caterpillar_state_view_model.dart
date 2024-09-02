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

  int _points = 0;
  int get points => _points;

  int _level = 0;
  int get level => _level;

  // void setSnacksEaten(int snacksEaten) {
  //   _snacksEaten = snacksEaten;
  //   _points += 1;
  //   notifyListeners();
  // }

  void setSegmentCount(int segmentCount) {
    _segmentCount = segmentCount;
    _points += 1;

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

  void onEnemyKilled(int killBonus) {
    _enemyKilled++;
    _enemyKilledSinceUlti++;
    _points += 10 * (level + 1) * killBonus;
    notifyListeners();
  }

  void setLevelUp() {
    _level++;
    _points += 1000; //USE TIME BONUS HERE
    notifyListeners();
  }

  void onUlti() {
    _enemyKilledSinceUlti = 0;
    notifyListeners();
  }

  void setIsHurt(bool isHurt) {
    _isHurt = isHurt;
    int penalty = 20;
    if (points - penalty <= 0) {
      _points = 0;
    } else {
      _points -= penalty;
    }
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
    _points = 0;
    notifyListeners();
  }
}
