import 'package:caterpillar_crawl/main.dart';
import 'package:flutter/material.dart';

Widget gameOverBuilder(BuildContext buildContext, CaterpillarCrawlMain game) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 500,
          height: 100,
          //color: Colors.orange,
          child: const Center(
            child: Text(
              'Game Over',
              style: TextStyle(
                fontSize: 42,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 500,
            height: 100,
            color: Colors.lightGreen,
            child: TextButton(
              child: const Text('RESET'),
              onPressed: () => game.onGameRestart(),
            ),
          ),
        )
      ],
    ),
  );
}
