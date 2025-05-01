import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../game_state.dart';
import '../player.dart';

class GameDatabase {
  static Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE game_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        points TEXT,
        player1_color TEXT,
        player2_color TEXT,
        player1_score INTEGER,
        player2_score INTEGER,
        current_player INTEGER,
        grid_size INTEGER,
        is_game_over INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> saveGameState(Database db, GameState state) async {
    await db.insert(
      'game_states',
      {
        'points': jsonEncode(state.points),
        'player1_color': _colorToHex(state.player1.color),
        'player2_color': _colorToHex(state.player2.color),
        'player1_score': state.player1.score,
        'player2_score': state.player2.score,
        'current_player': state.currentPlayerId,
        'grid_size': state.gridSize,
        'is_game_over': state.isGameOver ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<GameState?> loadLastGameState(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'game_states',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty || maps[0]['is_game_over'] == 1) return null;

    return GameState(
      points: jsonDecode(maps[0]['points']),
      squares: [],
      player1: Player(
        id: 1,
        color: _hexToColor(maps[0]['player1_color']),
        score: maps[0]['player1_score'],
      ),
      player2: Player(
        id: 2,
        color: _hexToColor(maps[0]['player2_color']),
        score: maps[0]['player2_score'],
      ),
      currentPlayerId: maps[0]['current_player'],
      gridSize: maps[0]['grid_size'],
      isGameOver: maps[0]['is_game_over'] == 1,
    );
  }

  static String _colorToHex(Color color) {
    return '#${color.r.toInt().toRadixString(16).padLeft(2, '0')}${color.g.toInt().toRadixString(16).padLeft(2, '0')}${color.b.toInt().toRadixString(16).padLeft(2, '0')}';
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('0xFF$hex'));
  }
}
