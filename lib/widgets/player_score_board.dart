import 'package:flutter/material.dart';

import '../models/player.dart';

class PlayerScoreCard extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;

  const PlayerScoreCard({
    required this.player,
    required this.isCurrentPlayer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: player.color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentPlayer ? player.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Player ${player.id}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: player.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: ${player.score}',
            style: TextStyle(
              fontSize: 16,
              color: player.color,
            ),
          ),
        ],
      ),
    );
  }
}
