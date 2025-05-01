import 'package:flutter/material.dart';

import '../../models/game_state.dart';
import '../../models/point.dart';

class PointPainter extends CustomPainter {
  final Point point;
  final GameState gameState;

  PointPainter({required this.point, required this.gameState});

  @override
  void paint(Canvas canvas, Size size) {
    final pointColor = gameState.points[point.key] ?? Colors.transparent;
    final bool isOccupied = pointColor != Colors.transparent;

    // Draw outer circle (always visible)
    final borderPaint = Paint()
      ..color = isOccupied ? pointColor : Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw inner circle (only if point is selected)
    final paint = Paint()
      ..color = isOccupied ? pointColor : Colors.transparent
      ..style = PaintingStyle.fill;

    // Draw shadow for selected points
    if (isOccupied) {
      final shadowPaint = Paint()
        ..color = pointColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        7.0,
        shadowPaint,
      );
    }

    // Draw point
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      6.0,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      6.0,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
