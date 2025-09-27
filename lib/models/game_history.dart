import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'game_history.g.dart';

@HiveType(typeId: 2)
class GameHistoryEntry extends HiveObject {
  @HiveField(0)
  final int winnerId;

  @HiveField(1)
  final Color player1Color;

  @HiveField(2)
  final Color player2Color;

  @HiveField(3)
  final int player1Score;

  @HiveField(4)
  final int player2Score;

  @HiveField(5)
  final int gridSize;

  @HiveField(6)
  final DateTime finishedAt;

  GameHistoryEntry({
    required this.winnerId,
    required this.player1Color,
    required this.player2Color,
    required this.player1Score,
    required this.player2Score,
    required this.gridSize,
    required this.finishedAt,
  });
}
