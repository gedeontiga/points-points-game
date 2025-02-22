import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game_state.dart';
import '../services/game_notifier.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_setting_dialog.dart';
import '../widgets/player_score_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  final Database database;

  const GameScreen({required this.database, super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends ConsumerState<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    if (gameState.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameOverDialog(context, gameState);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maths Points Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => showGameSettingsDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PlayerScoreCard(
                  player: gameState.player1,
                  isCurrentPlayer: gameState.currentPlayerId == 1,
                ),
                PlayerScoreCard(
                  player: gameState.player2,
                  isCurrentPlayer: gameState.currentPlayerId == 2,
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: GameGrid(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showGameOverDialog(BuildContext context, GameState gameState) {
    final winner = gameState.player1.score > gameState.player2.score
        ? gameState.player1
        : gameState.player2;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'End of game',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica',
              color: winner.color),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Player ${winner.id} Wins!',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica'),
            ),
            Text(
              'Score: ${winner.score}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
                color: winner.color,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GameSettingsDialog(database: widget.database),
                ),
              );
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  void showGameSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameSettingsDialog(database: widget.database),
    );
  }
}
