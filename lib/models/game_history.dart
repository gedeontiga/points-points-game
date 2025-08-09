import 'dart:ui';

class GameHistoryEntry {
  final int winnerId; // 1 for Player 1, 2 for Player 2, 0 for a tie
  final Color player1Color;
  final Color player2Color;
  final int player1Score;
  final int player2Score;
  final int gridSize;
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
