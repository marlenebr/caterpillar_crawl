# Caterpillar Crawl

Very first version of a Snake like caterpillar Game made with Flutter and Flame

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)

<img src="https://raw.githubusercontent.com/marlenebr/caterpillar_crawl/main/caterpillar_crawl_screenshot02.png" width="200">   <img src="https://raw.githubusercontent.com/marlenebr/caterpillar_crawl/main/caterpillar_crawl_screenshot03.png" width="200"> <img src="https://raw.githubusercontent.com/marlenebr/caterpillar_crawl/main/caterpillar_crawl_screenshot04.png" width="200"> 

## Description

Caterpillar Crawl is a small game developed using Flutter and the Flame engine. Its Snake-like but instead of a snake, players control a caterpillar that grows longer by collecting snacks. The goal is to navigate the game space and eat as much snacks as possible... so far this is all

## Features

- Flutter and Flame engine powered.
- Caterpillar moves with creating new segments when eating a snack
- Parralax Background
- Extremly fresh illustrations and sprite animation by: https://www.instagram.com/mlen_draws/


## Getting Started

First rough implementation: a simple Bug navigated over Tap-input on a small environment. The Bug respawns to the middle when touching the sides.

## Some notes about Performance
results of first Performance Test - much better than before. Instead of Collision detection the distance from caterpillar head to snack will be calculated in snacks update:
    - Caterpillar with 600 segments and 200 Snacks in the Scene: 48 FPS



