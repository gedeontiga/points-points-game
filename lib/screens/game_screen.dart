import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game_state.dart';
import '../models/repositories/game_database.dart';
import '../core/services/game_notifier.dart';
import '../core/widgets/game_grid.dart';
import 'game_setting_dialog.dart';
import '../core/widgets/player_score_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  final Database database;
  const GameScreen({required this.database, super.key});
  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    final lastState = await GameDatabase.loadLastGameState(widget.database);
    if (lastState != null && !lastState.isGameOver && mounted) {
      ref.read(gameProvider.notifier).restoreGameState(lastState);
    }
  }

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
            Image.asset(
              isTie ? 'assets/images/tie.png' : 'assets/images/trophy.png',
              height: 80,
              width: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                );
              },
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GameSettingsDialog(database: widget.database),
                ),
              );
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
            tooltip: 'New Game',
            onPressed: () => showGameSettingsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Game',
            onPressed: () async {
              await ref.read(gameProvider.notifier).saveGame(widget.database);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Game saved!'),
                    duration: Duration(seconds: 1),
                  ),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameSettingsDialog(database: widget.database),
    );
  }
}
