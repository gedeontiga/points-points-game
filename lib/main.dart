import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/repositories/game_database.dart';
import 'screens/spash_screen.dart';
// import 'services/game_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'game_database.db'),
    onCreate: (db, version) => GameDatabase.createTables(db),
    version: 1,
  );

  // final gameNotifier = GameNotifier();
  // await gameNotifier.loadGame(database);

  runApp(
    ProviderScope(
      child: MyApp(database: database),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({required this.database, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Points - Points',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SplashScreen(database: database),
    );
  }
}
