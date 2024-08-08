import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/tutorial_data.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class TutorialBuilder {
  CaterpillarCrawlMain mainGame;

  TutorialConditions tutorialCondition = TutorialConditions.end;

  TutorialBuilder({required this.mainGame})
      : tempMapSize = mainGame.mapSizeValue.value,
        tempEnemyCount = mainGame.enemyCountViewModel.value,
        tempSnackCountValue = mainGame.snackCountSettingsViewModel.value,
        // tempSegmentsToUlti = mainGame.segmentsToUlti,
        // tempEnemiesToUlti = mainGame.enemyKillsToUlti,
        tutorialStepData = {};

  int tempMapSize;
  int tempEnemyCount;
  int tempSnackCountValue;
  // int tempSegmentsToUlti;
  // int tempEnemiesToUlti;

  Future<void> startTutotial() async {
    tutorialStepData = TutorialData.createTutorialData();
    _currentTutorialStep = 0;
    tempMapSize = mainGame.mapSizeValue.value;
    tempEnemyCount = mainGame.enemyCountViewModel.value;
    tempSnackCountValue = mainGame.snackCountSettingsViewModel.value;
    // tempSegmentsToUlti = mainGame.segmentsToUlti;
    // tempEnemiesToUlti = mainGame.enemyKillsToUlti;
    mainGame.tutorialModeViewModel.setValue(true);
    // mainGame.segmentsToUlti = 4;
    // mainGame.enemyKillsToUlti = 4;
    await setTutorialSteps();
  }

  Future<void> resetOnNextStep(int enemyCount, int snackCount) async {
    mainGame.mapSizeValue.setValue(600);
    mainGame.snackCountSettingsViewModel.setValue(snackCount);
    mainGame.enemyCountViewModel.setValue(enemyCount);
  }

  Future<void> stopTutorial() async {
    mainGame.mapSizeValue.setValue(tempMapSize);
    mainGame.groundMap.player.startCrawling();
    mainGame.enemyCountViewModel.setValue(tempEnemyCount);
    mainGame.snackCountSettingsViewModel.setValue(tempSnackCountValue);
    // mainGame.segmentsToUlti = tempSegmentsToUlti;
    // mainGame.enemyKillsToUlti = tempEnemiesToUlti;
    mainGame.tutorialModeViewModel.setValue(false);
    await mainGame.onGameRestart();
  }

  int _currentTutorialStep = 0;
  Set<TutorialData> tutorialStepData;

  void setTutorialVieModel(
      {Function? callback, Vector2? positionForAttention}) {
    mainGame.tutorialItemViewModel.setTutorialItemViewModel(() async {
      await setTutorialSteps();
      if (callback != null) callback();
    }, positionForAttention);
  }

  Future<void> setTutorialSteps() async {
    if (_currentTutorialStep >= tutorialStepData.length) return;
    TutorialData currentTutorialStepData =
        tutorialStepData.elementAt(_currentTutorialStep);
    tutorialCondition = currentTutorialStepData.tutorialType;

    mainGame.tutorialItemViewModel
        .setInitDataWithoutNotify(currentTutorialStepData);
    _currentTutorialStep++;

    switch (currentTutorialStepData.tutorialType) {
      case TutorialConditions.init:
        resetOnNextStep(1, 1);
        setTutorialVieModel(
            callback: mainGame.groundMap.player
                .setCaterpillarState(CaterpillarState.onHoldForEgg));

      case TutorialConditions.moveJoystick:
        resetOnNextStep(1, 1);
        setTutorialVieModel(
            callback: mainGame.groundMap.player
                .setCaterpillarState(CaterpillarState.crawling),
            positionForAttention: Vector2(
                0,
                mainGame.camera.viewport.size.y -
                    (mainGame.joystickBackgroundRadius * 2 + 10)));
      case TutorialConditions.getLong:
        resetOnNextStep(1, 20);
        setTutorialVieModel(
          callback: mainGame.groundMap.player
              .setCaterpillarState(CaterpillarState.crawling),
        );
      case TutorialConditions.activateBomb:
        resetOnNextStep(1, 20);
        setTutorialVieModel(
            positionForAttention: _getPositionOfWidget(
                mainGame.distanceActionButtonViewModel.globalKey));
      case TutorialConditions.useBomb:
        resetOnNextStep(1, 20);
        setTutorialVieModel(
            callback: mainGame.groundMap.player
                .setCaterpillarState(CaterpillarState.crawling),
            positionForAttention: _getPositionOfWidget(
                mainGame.distanceActionButtonViewModel.globalKey));
      case TutorialConditions.useMelee:
        resetOnNextStep(1, 20);

        setTutorialVieModel(
            callback: mainGame.groundMap.player
                .setCaterpillarState(CaterpillarState.crawling),
            positionForAttention:
                _getPositionOfWidget(mainGame.meleeButtonViewModel.globalKey));
      case TutorialConditions.killEnemy:
        resetOnNextStep(1, 40);
        setTutorialVieModel(
          callback: mainGame.groundMap.player
              .setCaterpillarState(CaterpillarState.crawling),
        );
      case TutorialConditions.fillUlti:
        resetOnNextStep(6, 40);
        setTutorialVieModel(
            callback: mainGame.groundMap.player
                .setCaterpillarState(CaterpillarState.crawling),
            positionForAttention: _getPositionOfWidget(
                mainGame.distanceActionButtonViewModel.globalKey));
      case TutorialConditions.makeUlti:
        resetOnNextStep(6, 40);
        setTutorialVieModel(
            callback: mainGame.groundMap.player
                .setCaterpillarState(CaterpillarState.crawling),
            positionForAttention: _getPositionOfWidget(
                mainGame.distanceActionButtonViewModel.globalKey));
      case TutorialConditions.end:
        setTutorialVieModel(
            callback: () async => await stopTutorial(),
            positionForAttention: _getPositionOfWidgetEnd(
                mainGame.healthStatusViewModel.globalKey));
        return;
    }
    if (currentTutorialStepData.tutorialType == TutorialConditions.useBomb ||
        currentTutorialStepData.tutorialType == TutorialConditions.makeUlti) {
      return;
    }
    await mainGame.onGameRestart();
  }

  void onConditionReached(TutorialConditions condition, int? optionalValue) {
    if (!mainGame.tutorialModeViewModel.isInTutorialMode &&
        mainGame.tutorialItemViewModel.conditionReached) {
      return;
    }
    if (condition == tutorialCondition) {
      if (condition == TutorialConditions.getLong && optionalValue! < 10) {
        return;
      }
      mainGame.tutorialItemViewModel.setConditionReached(true);
    }
  }

  Vector2 _getPositionOfWidget(GlobalKey key) {
    if (key.currentContext == null) {
      return Vector2(100, 100);
    }
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    return Vector2(position.dx, position.dy);
  }

  Vector2 _getPositionOfWidgetEnd(GlobalKey key) {
    if (key.currentContext == null) {
      return Vector2(100, 100);
    }
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    Rect size = box.paintBounds;
    return Vector2(position.dx, position.dy) + size.toVector2();
  }
}

enum TutorialConditions {
  init,
  moveJoystick,
  useMelee,
  activateBomb,
  useBomb,
  getLong,
  killEnemy,
  fillUlti,
  makeUlti,
  end
}
