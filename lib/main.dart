import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/color_adapter.dart';
import 'models/game_history.dart';
import 'models/game_state.dart';
import 'models/player.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive for Flutter
  await Hive.initFlutter();

  // 2. Register all your adapters
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameHistoryEntryAdapter());

  // 3. Open your boxes (like tables in SQL)
  await Hive.openBox<GameState>('game_states');
  await Hive.openBox<GameHistoryEntry>('completed_games');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squares Conquest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
