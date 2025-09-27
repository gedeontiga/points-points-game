import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/game_history.dart';
import '../../models/game_state.dart';

final gameDatabaseProvider = Provider<GameDatabase>((ref) {
  return GameDatabase();
});

class GameDatabase {
  // Get the boxes we opened in main()
  final Box<GameState> _gameStateBox = Hive.box<GameState>('game_states');
  final Box<GameHistoryEntry> _completedGamesBox =
      Hive.box<GameHistoryEntry>('completed_games');

  // Replaces saveCompletedGame
  Future<GameHistoryEntry> saveCompletedGame(GameState state) async {
    final player1Score = state.player1.score;
    final player2Score = state.player2.score;
    int winnerId = 0;
    if (player1Score > player2Score) {
      winnerId = 1;
    } else if (player2Score > player1Score) {
      winnerId = 2;
    }

    final entry = GameHistoryEntry(
      winnerId: winnerId,
      player1Color: state.player1.color,
      player2Color: state.player2.color,
      player1Score: player1Score,
      player2Score: player2Score,
      gridSize: state.gridSize,
      finishedAt: DateTime.now(),
    );

    // add() returns the auto-incremented key
    await _completedGamesBox.add(entry);
    return entry;
  }

  // Replaces loadCompletedGames
  List<GameHistoryEntry> loadCompletedGames() {
    // Get all values from the box
    final games = _completedGamesBox.values.toList();
    // Sort in Dart, since Hive doesn't have "ORDER BY"
    games.sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    return games;
  }

  // Replaces saveGameState
  Future<void> saveGameState(GameState state) async {
    // Use 'put' with a fixed key to always save to the same "slot"
    await _gameStateBox.put('last_game_state', state);
  }

  // Replaces loadLastGameState
  GameState? loadLastGameState() {
    // Use 'get' with the same fixed key
    return _gameStateBox.get('last_game_state');
  }
}
