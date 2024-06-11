import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class SplashOutParticles extends ParticleSystemComponent {
  SplashOutParticles();

  @override
  void onLoad() {
    Random rnd = Random();

    Vector2 randomVector2() =>
        (Vector2.random(rnd) - Vector2.random(rnd)) * 400;

    Vector2 acc = Vector2(1, 1);
    particle = Particle.generate(
      count: 10,
      lifespan: 0.4,
      generator: (i) => AcceleratedParticle(
        acceleration: randomVector2(),
        speed: Vector2.all(60),
        child: CircleParticle(paint: Paint()..color = Colors.red, radius: 4),
      ),
    );
    priority = 1001;
  }
}
