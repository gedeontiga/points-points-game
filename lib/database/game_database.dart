import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game_state.dart';
import '../models/player.dart';

class GameDatabase {
  static Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE game_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        points TEXT,
        player1_color INTEGER,
        player2_color INTEGER,
        player1_score INTEGER,
        player2_score INTEGER,
        current_player INTEGER,
        grid_size INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> saveGameState(Database db, GameState state) async {
    await db.insert(
      'game_states',
      {
        'points': jsonEncode(state.points),
        'player1_color': state.player1.color.value,
        'player2_color': state.player2.color.value,
        'player1_score': state.player1.score,
        'player2_score': state.player2.score,
        'current_player': state.currentPlayerId,
        'grid_size': state.gridSize,
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

    if (maps.isEmpty) return null;

    return GameState(
      points: jsonDecode(maps[0]['points']),
      squares: [],
      player1: Player(
        id: 1,
        color: Color(maps[0]['player1_color']),
        score: maps[0]['player1_score'],
      ),
      player2: Player(
        id: 2,
        color: Color(maps[0]['player2_color']),
        score: maps[0]['player2_score'],
      ),
      currentPlayerId: maps[0]['current_player'],
      gridSize: maps[0]['grid_size'],
    );
  }
}
