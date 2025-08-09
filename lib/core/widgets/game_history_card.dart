// lib/widgets/game_history_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/game_history.dart';

class GameHistoryCard extends StatelessWidget {
  final GameHistoryEntry entry;
  const GameHistoryCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTie = entry.winnerId == 0;
    final winnerColor = isTie
        ? Colors.grey.shade700
        : (entry.winnerId == 1 ? entry.player1Color : entry.player2Color);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: winnerColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Row: Winner Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTie ? Icons.handshake : Icons.emoji_events,
                  color: winnerColor,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  isTie ? "It's a Tie!" : "Player ${entry.winnerId} Wins!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: winnerColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Middle Row: Player Scores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PlayerScore(
                    color: entry.player1Color, score: entry.player1Score),
                Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                _PlayerScore(
                    color: entry.player2Color, score: entry.player2Score),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom Row: Game Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grid: ${entry.gridSize}×${entry.gridSize}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                Text(
                  DateFormat.yMMMd().format(entry.finishedAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final Color color;
  final int score;
  const _PlayerScore({required this.color, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
