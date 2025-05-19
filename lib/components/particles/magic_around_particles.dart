import 'dart:math';

import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class MagicAroundParticles extends PositionComponent {
  PositionComponent parentPosComp;
  int particlePerTick;
  double timeForTick;
  CaterpillarCrawlMain world;

  bool _isSparkling = false;

  double timeElapsedSinceLastTick = 0;

  MagicAroundParticles(
      {required this.parentPosComp,
      required this.particlePerTick,
      required this.timeForTick,
      required this.world});

  @override
  Future<void> onLoad() async {}

  @override
  void update(double dt) {
    if (!_isSparkling) return;
    super.update(dt);
    timeElapsedSinceLastTick += dt;
    if (timeElapsedSinceLastTick > timeForTick) {
      timeElapsedSinceLastTick = 0;
      CreateParticleCluster();
    }
  }

  Future<void> CreateParticleCluster() async {
    Random rnd = Random();

    Vector2 randomVector2() => ((Vector2.random(rnd) - Vector2.all(0.5)) * 2);
    ParticleSystemComponent system = ParticleSystemComponent();
    system.particle = Particle.generate(
      count: particlePerTick,
      lifespan: timeForTick * 3,
      generator: (i) => AcceleratedParticle(
        // speed: orientation * 40,
        acceleration: randomVector2() * 80,
        // Will move from corner to corner of the game canvas.
        child: CircleParticle(
          radius: 3.0,
          paint: Paint()..color = const Color.fromARGB(255, 175, 245, 70),
        ),
      ),
    );
    system.position = parentPosComp.position + randomVector2() * 20;
    await add(system);
  }

  void startSparkling() {
    _isSparkling = true;
  }

  void stopSparkling() {
    _isSparkling = false;
  }
}
