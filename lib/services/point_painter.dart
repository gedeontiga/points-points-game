import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/point.dart';

class PointPainter extends CustomPainter {
  final Point point;
  final GameState gameState;

  PointPainter({required this.point, required this.gameState});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gameState.points[point.key] ?? Colors.transparent
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = (gameState.points[point.key] == Colors.transparent
          ? Colors.black
          : gameState.points[point.key])!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      5.0,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      5.0,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
