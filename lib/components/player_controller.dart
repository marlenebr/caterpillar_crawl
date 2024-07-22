import 'dart:async';

import 'package:caterpillar_crawl/components/tutorial_builder.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/ui/caterpillar_joystick.dart';
import 'package:flame/components.dart';
import 'package:flame/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerController extends PositionComponent {
  Vector2 currentDelta = Vector2.zero();
  Vector2 currentDeltaLastFrame = Vector2.zero();

  CaterpillarCrawlMain mainGame;

  PlayerController({required this.mainGame});

  @override
  void update(double dt) {
    super.update(dt);
    if (currentDelta != currentDeltaLastFrame) {
      mainGame.tutorialBuilder
          .onConditionReached(TutorialConditions.moveJoystick, null);
      currentDeltaLastFrame = currentDelta;
    }
  }
}

class MobilePlayerController extends PlayerController {
  late CaterpillarJoystick joystick;
  String innerJoystickSpritePath = "joystick_inner_128.png";
  String outerJoystickSpritePath = "joystick_outer_128.png";

  MobilePlayerController({required super.mainGame});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2.all(mainGame.joystickBackgroundRadius * 2);
    super.priority = double.maxFinite.toInt();

    Sprite knobSprite = await Sprite.load(innerJoystickSpritePath);
    SpriteComponent knobSpriteComponent = SpriteComponent(
        size: Vector2.all(mainGame.joystickKnobRadius * 2), sprite: knobSprite);
    Sprite joystickOuterSprite = await Sprite.load(outerJoystickSpritePath);
    //POSITION HERE
    SpriteComponent joystickOuterSpriteComponent = SpriteComponent(
        size: Vector2.all(mainGame.joystickBackgroundRadius * 2),
        sprite: joystickOuterSprite);
    joystick = CaterpillarJoystick(
      position: Vector2(0, 0),
      background: joystickOuterSpriteComponent,
      size: mainGame.joystickBackgroundRadius * 2,
      knob: knobSpriteComponent,
      knobRadius: mainGame.joystickKnobRadius * 2,
      margin: const EdgeInsets.all(10),
    );

    position = Vector2(
        0,
        mainGame.camera.viewport.size.y -
            (mainGame.joystickBackgroundRadius * 2 + 10));

    await add(joystick);

    currentDelta = joystick.currentDelta;
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentDelta = joystick.currentDelta;
  }
}

class WebPlayerController extends PlayerController with KeyboardHandler {
  Vector2 direction = Vector2.zero();
  WebPlayerController({required super.mainGame});

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event.data.keyLabel == "w") {
      currentDelta = Vector2(0, 1);
    } else if (event.data.keyLabel == "a") {
      currentDelta = Vector2(1, 0);
    } else if (event.data.keyLabel == "s") {
      currentDelta = Vector2(0, -1);
    } else if (event.data.keyLabel == "d") {
      currentDelta = Vector2(-1, 0);
    }

    return true;
  }
}
