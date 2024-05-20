import 'dart:math';

import 'package:caterpillar_crawl/components/weapons/melee/base_melee.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DungBall extends BaseMeleeWeapon {
  DungBall({required super.weaponData, required super.map})
      : timeForOneWave = weaponData.movementSpeed!,
        distanceMultiplier = map.level;

  //Sinus movement
  double startPosY = 0;
  double timeForOneWave;

  double _timerUpwards = 0;
  int distanceMultiplier;

  Vector2 startPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.bottomCenter;
    startPosition = Vector2(position.x, position.y);
    createBlade();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateAttacking(dt);
  }

  void updateAttacking(double dt) {
    if (!isAttacking) {
      return;
    }
    _timerUpwards += dt;
    double oneTime = _timerUpwards / timeForOneWave;
    //von null bis pi
    position += Vector2(0, -sin(((oneTime * 2 * pi))) * distanceMultiplier);
    if (_timerUpwards > timeForOneWave) {
      _timerUpwards = 0;
      isAttacking = false;
      position = startPosition;
      scale = idlescale;
    }
  }

  @override
  void startAttacking() {
    if (isAttacking) {
      return;
    }
    startPosition = Vector2(position.x, position.y);
    super.startAttacking();
  }

  void createBlade() {
    PositionComponent hitPoint =
        PositionComponent(); // hitPoint.add(CircleComponent(

    // hitPoint.add(CircleComponent(
    //   radius: weaponData.hitRadius,
    //   // paint: Paint()..color = Color.fromARGB(255, 226, 0, 30),
    // ));
    add(hitPoint);
    hitPoints.add(hitPoint);
  }
}
