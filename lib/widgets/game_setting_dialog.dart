import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../database/game_database.dart';
import '../screens/game_screen.dart';
import '../services/game_notifier.dart';

class GameSettingsDialog extends ConsumerStatefulWidget {
  final Database database;

  const GameSettingsDialog({required this.database, super.key});

  @override
  GameSettingsDialogState createState() => GameSettingsDialogState();
}

class GameSettingsDialogState extends ConsumerState<GameSettingsDialog> {
  Color? player1Color;
  Color? player2Color;
  int gridSize = 8;

  final List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadLastGameState();
  }

  Future<void> _loadLastGameState() async {
    final lastState = await GameDatabase.loadLastGameState(widget.database);
    if (lastState != null && mounted) {
      showDialog(
        context: context, // Assurez-vous d'utiliser BuildContext ici
        builder: (BuildContext context) => AlertDialog(
          // Spécifiez explicitement BuildContext
          title: const Text('Resume previous game?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('New Game'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(gameProvider.notifier).restoreGameState(lastState);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => GameScreen(
                        database: widget
                            .database), // Spécifiez explicitement BuildContext
                  ),
                );
              },
              child: const Text('Resume'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Player 1 Color'),
            Wrap(
              spacing: 8,
              children: availableColors
                  .where((color) => color != player2Color)
                  .map((color) => GestureDetector(
                        onTap: () => setState(() => player1Color = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: player1Color == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Player 2 Color'),
            Wrap(
              spacing: 8,
              children: availableColors
                  .where((color) => color != player1Color)
                  .map((color) => GestureDetector(
                        onTap: () => setState(() => player2Color = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: player2Color == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Grid Size'),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 8, label: Text('8x8')),
                ButtonSegment(value: 12, label: Text('12x12')),
              ],
              selected: {gridSize},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => gridSize = newSelection.first);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: player1Color != null && player2Color != null
                  ? () {
                      ref.read(gameProvider.notifier).initializeGame(
                            gridSize,
                            player1Color!,
                            player2Color!,
                          );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameScreen(database: widget.database),
                        ),
                      );
                    }
                  : null,
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
