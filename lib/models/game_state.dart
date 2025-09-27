import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'player.dart';
import 'square.dart';

part 'game_state.g.dart';

@HiveType(typeId: 0)
class GameState extends HiveObject {
  @HiveField(0)
  final Map<String, Color> points;

  @HiveField(1)
  final Player player1;

  @HiveField(2)
  final Player player2;

  @HiveField(3)
  final int currentPlayerId;

  @HiveField(4)
  final int gridSize;

  @HiveField(5)
  final bool isGameOver;
  List<Square> squares = [];

  GameState({
    required this.points,
    required this.player1,
    required this.player2,
    required this.currentPlayerId,
    required this.gridSize,
    required this.isGameOver,
  });

  factory GameState.initial() {
    return GameState(
      points: {},
      player1: Player(id: 1, color: Colors.blue, score: 0),
      player2: Player(id: 2, color: Colors.red, score: 0),
      currentPlayerId: 1,
      gridSize: 10,
      isGameOver: false,
    );
  }

  GameState copyWith({
    Map<String, Color>? points,
    List<Square>? squares,
    Player? player1,
    Player? player2,
    int? currentPlayerId,
    int? gridSize,
    bool? isGameOver,
  }) {
    // 1. Create the new instance using the constructor
    final newGameState = GameState(
      points: points ?? this.points,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      gridSize: gridSize ?? this.gridSize,
      isGameOver: isGameOver ?? this.isGameOver,
    );

    // 2. Assign the squares list to the new instance's public field
    newGameState.squares = squares ?? this.squares;

    // 3. Return the fully configured new instance
    return newGameState;
  }
}
