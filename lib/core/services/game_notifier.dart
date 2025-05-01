import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/repositories/game_database.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../models/point.dart';
import '../../models/square.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState.initial());
  Future<void> loadGame(Database db) async {
    final savedState = await GameDatabase.loadLastGameState(db);
    if (savedState != null) {
      state = savedState;
    }
  }

  void initializeGame(int gridSize, Color player1Color, Color player2Color) {
    state = GameState(
      points: generateEmptyGrid(gridSize),
      squares: [],
      player1: Player(id: 1, color: player1Color),
      player2: Player(id: 2, color: player2Color),
      currentPlayerId: 1,
      gridSize: gridSize,
      isGameOver: false,
    );
  }

  void restoreGameState(GameState savedState) {
    state = savedState;
  }

  Future<void> saveGame(Database db) async {
    await GameDatabase.saveGameState(db, state);
  }

  Map<String, Color> generateEmptyGrid(int size) {
    final grid = <String, Color>{};
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        grid['$i,$j'] = Colors.transparent;
      }
    }
    return grid;
  }

  List<Square> checkNewSquares(
      Map<String, Color> points, Point newPoint, Player player) {
    final squares = <Square>[];
    for (int dRow = -1; dRow <= 0; dRow++) {
      for (int dCol = -1; dCol <= 0; dCol++) {
        final potentialSquarePoints = [
          Point(newPoint.row + dRow, newPoint.col + dCol),
          Point(newPoint.row + dRow, newPoint.col + dCol + 1),
          Point(newPoint.row + dRow + 1, newPoint.col + dCol),
          Point(newPoint.row + dRow + 1, newPoint.col + dCol + 1),
        ];
        if (potentialSquarePoints
            .every((p) => isValidPoint(p) && points[p.key] == player.color)) {
          final existingSquare = state.squares.any((square) =>
              square.points.length == potentialSquarePoints.length &&
              square.points.every((p) => potentialSquarePoints
                  .any((pp) => p.row == pp.row && p.col == pp.col)));
          if (!existingSquare) {
            squares.add(Square(
              points: potentialSquarePoints,
              color: player.color,
              playerId: player.id,
            ));
          }
        }
      }
    }
    return squares;
  }

  bool isValidPoint(Point point) {
    return point.row >= 0 &&
        point.row < state.gridSize &&
        point.col >= 0 &&
        point.col < state.gridSize;
  }

  bool checkGameOver(Map<String, Color> points) {
    for (int row = 0; row < state.gridSize - 1; row++) {
      for (int col = 0; col < state.gridSize - 1; col++) {
        final potentialPoints = [
          Point(row, col),
          Point(row, col + 1),
          Point(row + 1, col),
          Point(row + 1, col + 1)
        ];
        Map<Color, int> colorCount = {};
        int emptyPoints = 0;
        for (var point in potentialPoints) {
          final color = points[point.key] ?? Colors.transparent;
          if (color == Colors.transparent) {
            emptyPoints++;
          } else {
            colorCount[color] = (colorCount[color] ?? 0) + 1;
          }
        }
        if (emptyPoints > 0 && (colorCount.length <= 1)) {
          return false;
        }
      }
    }
    return true;
  }

  void selectPoint(Point point) {
    if (state.points[point.key] != Colors.transparent || state.isGameOver) {
      return;
    }
    final currentPlayer =
        state.currentPlayerId == 1 ? state.player1 : state.player2;
    final newPoints = Map<String, Color>.from(state.points);
    newPoints[point.key] = currentPlayer.color;
    final newSquares = checkNewSquares(newPoints, point, currentPlayer);
    final bool squareFormed = newSquares.isNotEmpty;
    final updatedPlayer1 = state.player1.copyWith(
        score: squareFormed && currentPlayer.id == 1
            ? state.player1.score + newSquares.length
            : state.player1.score);
    final updatedPlayer2 = state.player2.copyWith(
        score: squareFormed && currentPlayer.id == 2
            ? state.player2.score + newSquares.length
            : state.player2.score);
    final isGameOver = checkGameOver(newPoints);
    state = state.copyWith(
      points: newPoints,
      squares: [...state.squares, ...newSquares],
      player1: updatedPlayer1,
      player2: updatedPlayer2,
      currentPlayerId: squareFormed
          ? state.currentPlayerId
          : (state.currentPlayerId == 1 ? 2 : 1),
      isGameOver: isGameOver,
    );
    if (isGameOver) {
      log('Game Over! Player 1: ${updatedPlayer1.score}, Player 2: ${updatedPlayer2.score}');
    }
  }
}
