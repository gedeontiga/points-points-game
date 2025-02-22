import 'package:flutter/material.dart';

import 'point.dart';

class Square {
  final List<Point> points;
  final Color color;
  final int playerId;

  Square({
    required this.points,
    required this.color,
    required this.playerId,
  });
}
