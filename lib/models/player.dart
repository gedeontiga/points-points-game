import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 1)
class Player extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final Color color;

  @HiveField(2)
  int score;

  Player({
    required this.id,
    required this.color,
    required this.score,
  });

  // Add the required copyWith method
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
