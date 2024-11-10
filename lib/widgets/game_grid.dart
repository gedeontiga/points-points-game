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

    return Column(
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
                    padding: const EdgeInsets.all(16.0),
                    child: // Dans GameGrid, remplacer la partie existante qui gère les CustomPainter par :
                        Stack(
                      children: [
                        CustomPaint(
                          painter: PointPainter(
                            point: Point(row, col),
                            gameState: gameState,
                          ),
                        ),
                        if (row ==
                                gameState
                                    .squares.firstOrNull?.points.first.row &&
                            col ==
                                gameState.squares.firstOrNull?.points.first.col)
                          ...gameState.squares.map((square) => CustomPaint(
                                painter: SquarePainter(
                                  square: square,
                                  gameState: gameState,
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
