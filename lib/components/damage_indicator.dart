import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageIndicator extends PositionComponent with HasVisibility {
  PositionComponent? _healthBar;
  PositionComponent? _healthBarContent;
  double padding = 2;

  PositionComponent parentToTakeDamage;

  final double _barHeight = 4;
  final double _barWidth = 32;

  final int maxHealthValue;

  DamageIndicator(
      {required this.maxHealthValue, required this.parentToTakeDamage});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _healthBar = RectangleComponent(
        size: Vector2(_barWidth + padding, _barHeight + padding),
        paint: Paint()..color = Colors.black);
    _healthBarContent = RectangleComponent(
        size: Vector2(_barWidth, _barHeight),
        position: Vector2.all(padding / 2),
        paint: Paint()..color = Colors.red);
    _healthBar!.add(_healthBarContent!);
    add(_healthBar!);
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
    angle = -parentToTakeDamage.angle;
  }

  void setHealth(int newHealthValue) {
    _healthBarContent!.size =
        Vector2((_barWidth / 5) * newHealthValue, _healthBarContent!.size.y);
  }

  void show() {
    if (!isVisible) {
      isVisible = true;
    }
  }

  void hide() {
    if (isVisible) {
      isVisible = false;
    }
  }
}
