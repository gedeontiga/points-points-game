import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/game_database.dart';
import '../core/widgets/game_history_card.dart';
import '../main.dart';
import '../models/game_history.dart'; // To get the databaseProvider

// A provider to fetch the history data asynchronously
final gameHistoryProvider = FutureProvider<List<GameHistoryEntry>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return GameDatabase.loadCompletedGames(db);
});

class GameHistoryScreen extends ConsumerWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(gameHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Games Completed Yet',
                      style: TextStyle(fontSize: 20)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              return GameHistoryCard(entry: history[index]);
            },
          );
        },
      ),
    );
  }
}
