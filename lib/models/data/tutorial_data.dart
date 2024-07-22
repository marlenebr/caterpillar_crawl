import 'package:caterpillar_crawl/components/tutorial_builder.dart';

class TutorialData {
  final TutorialConditions tutorialType;
  final String text;
  final bool isConditional; //null if this has no condition to furfill this step

  TutorialData(
      {required this.text,
      required this.isConditional,
      required this.tutorialType});
  static Set<TutorialData> createTutorialData() {
    Set<TutorialData> tutorialData = {};
    tutorialData.add(TutorialData(
        text: "Ready to Check this game out?",
        isConditional: false,
        tutorialType: TutorialConditions.init));

    tutorialData.add(TutorialData(
        text: "Touch the Joystick",
        isConditional: true,
        tutorialType: TutorialConditions.moveJoystick));

    tutorialData.add(TutorialData(
        text: "Eat 10 Snacks and look how you grow",
        isConditional: true,
        tutorialType: TutorialConditions.getLong));

    tutorialData.add(TutorialData(
        text: "Push the Bomb button to load up for bombing",
        isConditional: true,
        tutorialType: TutorialConditions.activateBomb));

    tutorialData.add(TutorialData(
        text: "Perfect - Now Push again to Fire the Bomb",
        isConditional: true,
        tutorialType: TutorialConditions.useBomb));
    tutorialData.add(TutorialData(
        text: "Push the Melee to smash in low distance",
        isConditional: true,
        tutorialType: TutorialConditions.useMelee));

    tutorialData.add(TutorialData(
        text: "Now Kill an enemy",
        isConditional: true,
        tutorialType: TutorialConditions.killEnemy));

    tutorialData.add(TutorialData(
        text:
            "See the Bomb Icon? When you eat snacks and kill enemies it seems to load up... Make this round bars full",
        isConditional: true,
        tutorialType: TutorialConditions.fillUlti));

    tutorialData.add(TutorialData(
        text: "Make your Bomb Button bars full and fire Ulti",
        isConditional: false,
        tutorialType: TutorialConditions.makeUlti));

    tutorialData.add(TutorialData(
        text:
            "This was it - you are ready now. Remember, now can enemies Hurt you",
        isConditional: false,
        tutorialType: TutorialConditions.end));
    return tutorialData;
  }
}
