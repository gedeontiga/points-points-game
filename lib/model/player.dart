import 'package:flutter/material.dart';

class Player {
  final int id;
  final Color color;
  int score;

  Player({
    required this.id,
    required this.color,
    this.score = 0,
  });

  Player copyWith({
    int? id,
    Color? color,
    int? score,
  }) {
    return Player(
      id: id ?? this.id,
      color: color ?? this.color,
      score: score ?? this.score,
    );
  }
}
