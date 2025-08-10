import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/game_history.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';

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

    // *** ADD THIS NEW TABLE ***
    await db.execute('''
      CREATE TABLE IF NOT EXISTS completed_games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        winner_id INTEGER NOT NULL,
        player1_color TEXT NOT NULL,
        player2_color TEXT NOT NULL,
        player1_score INTEGER NOT NULL,
        player2_score INTEGER NOT NULL,
        grid_size INTEGER NOT NULL,
        finished_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // *** ADD THIS NEW METHOD TO SAVE A FINISHED GAME ***
  static Future<GameHistoryEntry> saveCompletedGame(
      Database db, GameState state) async {
    final player1Score = state.player1.score;
    final player2Score = state.player2.score;
    int winnerId = 0; // 0 for a tie
    if (player1Score > player2Score) {
      winnerId = 1;
    } else if (player2Score > player1Score) {
      winnerId = 2;
    }

    final finishedAt = DateTime.now();
    final data = {
      'winner_id': winnerId,
      'player1_color': _colorToHex(state.player1.color),
      'player2_color': _colorToHex(state.player2.color),
      'player1_score': player1Score,
      'player2_score': player2Score,
      'grid_size': state.gridSize,
      'finished_at': finishedAt.toIso8601String(),
    };

    await db.insert('completed_games', data);

    return GameHistoryEntry(
      winnerId: winnerId,
      player1Color: state.player1.color,
      player2Color: state.player2.color,
      player1Score: player1Score,
      player2Score: player2Score,
      gridSize: state.gridSize,
      finishedAt: finishedAt,
    );
  }

  // *** ADD THIS NEW METHOD TO LOAD ALL COMPLETED GAMES ***
  static Future<List<GameHistoryEntry>> loadCompletedGames(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'completed_games',
      orderBy: 'finished_at DESC', // Newest first
    );

    return List.generate(maps.length, (i) {
      return GameHistoryEntry(
        winnerId: maps[i]['winner_id'],
        player1Color: _hexToColor(maps[i]['player1_color']),
        player2Color: _hexToColor(maps[i]['player2_color']),
        player1Score: maps[i]['player1_score'],
        player2Score: maps[i]['player2_score'],
        gridSize: maps[i]['grid_size'],
        finishedAt: DateTime.parse(maps[i]['finished_at']),
      );
    });
  }

  static Future<void> saveGameState(Database db, GameState state) async {
    final pointsMap = <String, String>{};

    state.points.forEach((key, color) {
      // Handle transparent colors specially
      if (color == Colors.transparent) {
        pointsMap[key] = 'transparent';
      } else {
        pointsMap[key] = _colorToHex(color);
      }
    });

    await db.insert(
      'game_states',
      {
        'points': jsonEncode(pointsMap),
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
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'game_states',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      final Map<String, dynamic> rawPointsMap = jsonDecode(maps[0]['points']);
      final Map<String, Color> pointsMap = {};

      rawPointsMap.forEach((key, value) {
        // Handle transparent colors specially when loading
        if (value == 'transparent') {
          pointsMap[key] = Colors.transparent;
        } else {
          pointsMap[key] = _hexToColor(value);
        }
      });

      return GameState(
        points: pointsMap,
        squares: [], // Squares will be reconstructed after loading
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
    } catch (e) {
      return null;
    }
  }

  static String _colorToHex(Color color) {
    // Handle special case for transparent
    if (color == Colors.transparent) {
      return 'transparent';
    }

    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static Color _hexToColor(String hex) {
    // Handle special case for transparent
    if (hex == 'transparent') {
      return Colors.transparent;
    }

    hex = hex.replaceAll('#', '');
    return Color(int.parse('0xFF$hex'));
  }
}
