import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../core/utils/grid_preview_painter.dart';
import '../models/repositories/game_database.dart';
import 'game_screen.dart';
import '../core/services/game_notifier.dart';

class GameSettingsDialog extends ConsumerStatefulWidget {
  final Database database;

  const GameSettingsDialog({required this.database, super.key});

  @override
  GameSettingsDialogState createState() => GameSettingsDialogState();
}

class GameSettingsDialogState extends ConsumerState<GameSettingsDialog>
    with SingleTickerProviderStateMixin {
  Color? player1Color;
  Color? player2Color;
  int gridSize = 8;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _checkGameState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkGameState() async {
    final lastState = await GameDatabase.loadLastGameState(widget.database);
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (lastState != null && !lastState.isGameOver && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              GameScreen(database: widget.database),
        ),
      );
    } else if (lastState != null && lastState.isGameOver && mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Resume previous game?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Would you like to continue from your previous game or start a new one?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('New Game'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                ref.read(gameProvider.notifier).restoreGameState(lastState);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        GameScreen(database: widget.database),
                  ),
                );
              },
              child: const Text('Resume'),
            ),
          ],
        ),
      );
    } else {
      // Set default colors for new game
      setState(() {
        player1Color = availableColors[0];
        player2Color = availableColors[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final colorSize = isSmallScreen ? 36.0 : 48.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings,
                            size: 28,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Game Settings',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Player 1 Color'),
                      const SizedBox(height: 12),
                      _buildColorGrid(
                        colors: availableColors
                            .where((color) => color != player2Color)
                            .toList(),
                        selectedColor: player1Color,
                        onColorSelected: (color) =>
                            setState(() => player1Color = color),
                        colorSize: colorSize,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Player 2 Color'),
                      const SizedBox(height: 12),
                      _buildColorGrid(
                        colors: availableColors
                            .where((color) => color != player1Color)
                            .toList(),
                        selectedColor: player2Color,
                        onColorSelected: (color) =>
                            setState(() => player2Color = color),
                        colorSize: colorSize,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Grid Size'),
                      const SizedBox(height: 16),
                      _buildGridSizeSelector(),
                      const SizedBox(height: 16),
                      _buildGridPreview(),
                      const SizedBox(height: 30),
                      _buildStartButton(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildColorGrid({
    required List<Color> colors,
    required Color? selectedColor,
    required Function(Color) onColorSelected,
    required double colorSize,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: colors.map((color) {
        final isSelected = selectedColor == color;

        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: colorSize,
            height: colorSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridSizeSelector() {
    return LayoutBuilder(builder: (context, constraints) {
      // Adapt to different screen sizes
      final isSmallScreen = constraints.maxWidth < 400;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: SegmentedButton<int>(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(
                    vertical: 12, horizontal: isSmallScreen ? 4 : 8),
              ),
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.primary;
                  }
                  return null;
                },
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.onPrimary;
                  }
                  return Theme.of(context).colorScheme.primary;
                },
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1);
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2);
                  }
                  return null;
                },
              ),
            ),
            segments: [
              ButtonSegment<int>(
                value: 6,
                label: _buildSegmentLabel('6×6', 'Easy'),
              ),
              ButtonSegment<int>(
                value: 8,
                label: _buildSegmentLabel('8×8', 'Medium'),
              ),
              ButtonSegment<int>(
                value: 10,
                label: _buildSegmentLabel('10×10', 'Hard'),
              ),
              ButtonSegment<int>(
                value: 12,
                label: _buildSegmentLabel('12×12', 'Expert'),
              ),
            ],
            selected: {gridSize},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                gridSize = newSelection.first;
              });
              // Optional: Add haptic feedback
              HapticFeedback.lightImpact();

              // Optional: Show a brief confirmation
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Grid size set to ${newSelection.first}×${newSelection.first}'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            showSelectedIcon: false,
          ),
        ),
      );
    });
  }

// Helper method to create a more informative segment label
  Widget _buildSegmentLabel(String size, String difficulty) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                size,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                difficulty,
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Text(
            '$gridSize × $gridSize Grid',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            width: 80,
            child: CustomPaint(
              painter: GridPreviewPainter(
                gridSize: gridSize,
                player1Color: player1Color ?? Colors.blue,
                player2Color: player2Color ?? Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${gridSize * gridSize} points',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final bool canStart = player1Color != null && player2Color != null;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canStart ? Theme.of(context).primaryColor : Colors.grey[300],
          foregroundColor: canStart ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: canStart ? 4 : 0,
        ),
        onPressed: canStart
            ? () {
                ref.read(gameProvider.notifier).initializeGame(
                      gridSize,
                      player1Color!,
                      player2Color!,
                    );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(database: widget.database),
                  ),
                );
              }
            : null,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow),
            SizedBox(width: 8),
            Text(
              'Start Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
