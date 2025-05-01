import 'package:flutter/material.dart';

import 'player.dart';
import 'square.dart';

class GameState {
  final Map<String, Color> points;
  final List<Square> squares;
  final Player player1;
  final Player player2;
  final int currentPlayerId;
  final int gridSize;
  final bool isGameOver;

  GameState({
    required this.points,
    required this.squares,
    required this.player1,
    required this.player2,
    required this.currentPlayerId,
    required this.gridSize,
    this.isGameOver = false,
  });

  factory GameState.initial() {
    return GameState(
      points: {},
      squares: [],
      player1: Player(id: 1, color: Colors.blue),
      player2: Player(id: 2, color: Colors.red),
      currentPlayerId: 1,
      gridSize: 8,
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
    return GameState(
      points: points ?? this.points,
      squares: squares ?? this.squares,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      gridSize: gridSize ?? this.gridSize,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
