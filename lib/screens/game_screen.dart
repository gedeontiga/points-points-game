import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../core/services/game_database.dart';
import '../models/game_state.dart';
import '../core/services/game_notifier.dart';
import '../core/widgets/game_grid.dart';
import 'game_history_screen.dart';
import 'game_settings_dialog.dart';
import '../core/widgets/player_score_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  final Database database;
  const GameScreen({required this.database, super.key});
  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends ConsumerState<GameScreen> {
  void showGameOverDialog(BuildContext context, GameState gameState) {
    final player1Score = gameState.player1.score;
    final player2Score = gameState.player2.score;
    final isTie = player1Score == player2Score;

    final dialogTitleColor = isTie
        ? Colors.purple
        : player1Score > player2Score
            ? gameState.player1.color
            : gameState.player2.color;

    final winner =
        player1Score > player2Score ? gameState.player1 : gameState.player2;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Game Over',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Helvetica',
            color: dialogTitleColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTie) ...[
              const Text(
                'It\'s a Tie!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica',
                ),
              ),
              Text(
                'Both players scored $player1Score points',
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Helvetica',
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'Player ${winner.id} Wins!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica',
                ),
              ),
              Text(
                'Score: ${winner.score} vs ${winner.id == 1 ? player2Score : player1Score}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica',
                  color: winner.color,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Icon(
              isTie ? Icons.handshake : Icons.emoji_events,
              size: 80,
              color: Colors.amber,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogTitleColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog first
              showGameSettingsDialog(context); // Then show settings dialog
            },
            child: const Text(
              'New Game',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    ref.listen<bool>(gameProvider.select((s) => s.isGameOver),
        (wasGameOver, isGameOver) {
      if (isGameOver && !(wasGameOver ?? false)) {
        final finalState = ref.read(gameProvider);

        // --- THIS IS THE KEY CHANGE ---
        // Call the notifier to save the game and update the history state.
        ref.read(gameHistoryProvider.notifier).addCompletedGame(finalState);

        // Show the Game Over dialog
        showGameOverDialog(context, finalState);
      }
    });

    // A better place for autosave is to listen to changes.
    ref.listen(gameProvider, (previous, next) {
      // When the state changes, trigger an autosave.
      ref.read(gameProvider.notifier).autoSave(widget.database);
    });

    ref.listen(gameProvider.select((s) => s.isGameOver),
        (wasGameOver, isGameOver) {
      // When the game state changes from "not over" to "over"
      if (isGameOver && !(wasGameOver ?? false)) {
        // Get the final state from the provider
        final finalState = ref.read(gameProvider);
        GameDatabase.saveCompletedGame(widget.database, finalState);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Squares Conquest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Game History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GameHistoryScreen()),
              );
            },
          ),

          // *** THIS IS THE BUTTON WE ARE CHANGING BACK ***
          IconButton(
            icon: const Icon(Icons.restart_alt_sharp),
            tooltip: 'New Game',
            // We replace the showDialog logic with a direct call
            // to your helper method.
            onPressed: () => showGameSettingsDialog(context),
          ),

          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Game',
            onPressed: () async {
              await ref.read(gameProvider.notifier).saveGame(widget.database);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game saved!')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: PlayerScoreCard(
                    player: gameState.player1,
                    isCurrentPlayer: gameState.currentPlayerId == 1,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8.0 : 16.0),
                Expanded(
                  child: PlayerScoreCard(
                    player: gameState.player2,
                    isCurrentPlayer: gameState.currentPlayerId == 2,
                  ),
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

  void showGameSettingsDialog(BuildContext context) {
    ref.read(gameProvider.notifier).resetGameState();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameSettingsDialog(database: widget.database),
    );
  }
}
