import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Your own project imports
import 'core/services/game_database.dart'; // Ensure this path is correct
import 'screens/splash_screen.dart'; // Ensure this path is correct

// 1. Create a provider that initializes the database asynchronously.
// This provider will be watched by the UI to show loading/error/data states.
final databaseProvider = FutureProvider<Database>((ref) async {
  // This logic is now handled in the background by the provider.
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'game_database.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) => GameDatabase.createTables(db),
  );
});

void main() {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Ensure Flutter is ready before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app within a ProviderScope so providers are available everywhere.
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
      // The SplashScreen no longer needs the database passed to it.
      // It will get it from the provider.
      home: const SplashScreen(),
    );
  }
}
