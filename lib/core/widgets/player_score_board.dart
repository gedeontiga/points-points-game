import 'package:flutter/material.dart';

import '../../models/player.dart';

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
        color: player.color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? player.color : Colors.transparent,
          width: 3,
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: player.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCurrentPlayer)
                Icon(
                  Icons.arrow_right_alt,
                  color: player.color,
                  size: 20,
                ),
              Text(
                'Player ${player.id}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: player.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: player.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${player.score}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: player.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
