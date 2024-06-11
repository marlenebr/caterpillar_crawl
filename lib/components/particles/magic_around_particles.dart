import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class MagicAroundParticles extends ParticleSystemComponent {
  MagicAroundParticles();

  @override
  void onLoad() {
    Random rnd = Random();

    Vector2 randomVector2() => (Vector2.random(rnd) * 80);

    particle = Particle.generate(
      count: 10,
      generator: (i) => MovingParticle(
        curve: Curves.linear,
        // Will move from corner to corner of the game canvas.
        from: Vector2.zero(),
        to: randomVector2(),
        lifespan: 10,
        child: CircleParticle(
          radius: 10.0,
          paint: Paint()..color = Color.fromARGB(255, 1, 147, 98),
        ),
      ),
    );
    priority = 2001;
  }
}
