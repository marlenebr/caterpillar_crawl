// import 'dart:math';

// import 'package:caterpillar_crawl/components/enemy/enemy.dart';
// import 'package:caterpillar_crawl/components/map/obstacle_snapshot.dart';
// import 'package:caterpillar_crawl/components/obstacle.dart';
// import 'package:caterpillar_crawl/main.dart';
// import 'package:caterpillar_crawl/models/data/egg_data.dart';
// import 'package:caterpillar_crawl/utils/utils.dart';
// import 'package:flame/components.dart';

// class Egg extends PositionComponent {
//   CaterpillarCrawlMain gameWorld;
//   EggData eggData;
//   double shootingSpeed;
//   late SpriteAnimation _eggAnimation;
//   late SpriteAnimation _eggExplodingAnimation;

//   late SpriteAnimationGroupComponent eggAnimations;
//   // late SpriteAnimation eggAfterExplodingAnimation;

//   EggState currentState = EggState.inShoot;

//   bool istShooting = false;
//   double shootTime = 1.2;
//   double currentShootTime = 0.0;
//   Vector2 orientation = Vector2.zero();

//   double explosionTimer = 2;

//   Egg(
//       {required this.eggData,
//       required this.gameWorld,
//       required this.shootingSpeed});

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();
//     // size = eggData.explodingEgg.spriteSize;
//     // finalSize = eggData.explodingEgg.finalSize;
//     _eggAnimation = await CaterpillarCrawlUtils.createAnimation(
//         animationData: eggData.idleEgg);
//     _eggExplodingAnimation = await CaterpillarCrawlUtils.createAnimation(
//         animationData: eggData.explodingEgg, loopAnimation: false);
//     anchor = Anchor.center;
//     // add(SpriteAnimationComponent(animation: eggAnimation));
//     eggAnimations = SpriteAnimationGroupComponent<EggState>(animations: {
//       EggState.inShoot: _eggAnimation,
//       EggState.exploding: _eggExplodingAnimation,
//     }, anchor: Anchor.center, current: currentState);
//     add(eggAnimations);
//     priority = 100;
//     // scale = Vector2(finalSize.x / eggData.explodingEgg.spriteSize.x,
//     //     finalSize.y / eggData.explodingEgg.spriteSize.y);
//   }

//   @override
//   void update(double dt) {
//     _updateShoot(dt);
//     _updateExplosion(dt);
//   }

//   void shoot() {
//     istShooting = true;
//     currentShootTime = shootTime;
//   }

//   void _updateShoot(double dt) {
//     if (istShooting) {
//       orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
//       position +=
//           orientation * (1 / 2) * pow(currentShootTime, 2).toDouble() * 13;
//       currentShootTime -= dt;
//       if (currentShootTime <= 0) {
//         istShooting = false;
//         explode();
//       }
//     }
//   }

//   void explode() {
//     setCurrentEggState(EggState.exploding);
//     for (Enemy enemy in gameWorld.groundMap.enemies.values) {
//       if (enemy.position.distanceTo(position) < 140) {
//         enemy.onEnemyHit(5, false); //FALSE
//       }
//     }
//   }

//   void _updateExplosion(double dt) {
//     if (currentState == EggState.exploding) {
//       explosionTimer -= dt;
//       if (explosionTimer < 0) {
//         gameWorld.groundMap.obstacleSnapshot
//             .addObstacleAndRenderSnapshot<BombObstacle>(
//                 position,
//                 eggData.explodingEgg.spriteSize,
//                 angle,
//                 true,
//                 ObstacleType.bomb);
//         removeFromParent();
//       }
//     }
//   }

//   void setCurrentEggState(EggState eggState) {
//     currentState = eggState;
//     eggAnimations.current = currentState;
//   }
// }

// // enum EggState {
// //   inShoot,
// //   exploding,
// // }
