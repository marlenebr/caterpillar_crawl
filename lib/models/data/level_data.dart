import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/components/weapons/melee/base_melee_weapon.dart';

class LevelManager {
  static LevelData? getLevelData(int level) {
    if (level == 0) {
      return LevelData(
        enemyWave: 6,
        pointsToLevelUp: 200,
        possibleSnackTypes: [SnackType.green],
        hiddenMelee: MeleeWeaponType.miniSword,
      );
    } else if (level == 1) {
      return LevelData(
        enemyWave: 8,
        pointsToLevelUp: 1000,
        possibleSnackTypes: [SnackType.green, SnackType.red],
      );
    } else if (level == 2) {
      return LevelData(
        enemyWave: 8,
        pointsToLevelUp: 2000,
        possibleSnackTypes: [SnackType.green, SnackType.red],
        hiddenMelee: MeleeWeaponType.miniSword,
      );
    }
    return null;
  }
}

class LevelData {
  final int enemyWave;
  final int pointsToLevelUp;
  final List<SnackType> possibleSnackTypes;
  final MeleeWeaponType? hiddenMelee;

  LevelData(
      {required this.enemyWave,
      required this.pointsToLevelUp,
      required this.possibleSnackTypes,
      this.hiddenMelee});
}
