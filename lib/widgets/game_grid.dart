import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/point.dart';
import '../services/game_notifier.dart';
import '../services/point_painter.dart';
import '../services/square_painter.dart';

class GameGrid extends ConsumerWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return SizedBox(
      width: gameState.gridSize * 32.0,
      height: gameState.gridSize * 32.0,
      child: Stack(
        children: [
          // Carrés
          ...gameState.squares.map((square) => CustomPaint(
                size: Size(
                  gameState.gridSize * 32.0,
                  gameState.gridSize * 32.0,
                ),
                painter: SquarePainter(
                  square: square,
                  gameState: gameState,
                ),
              )),
          // Grille de points
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var row = 0; row < gameState.gridSize; row++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var col = 0; col < gameState.gridSize; col++)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          ref
                              .read(gameProvider.notifier)
                              .selectPoint(Point(row, col));
                        },
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          padding: const EdgeInsets.all(8.0),
                          child: CustomPaint(
                            painter: PointPainter(
                              point: Point(row, col),
                              gameState: gameState,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
