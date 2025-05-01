import 'package:flutter/material.dart';

class GridPreviewPainter extends CustomPainter {
  final int gridSize;
  final Color player1Color;
  final Color player2Color;

  GridPreviewPainter({
    required this.gridSize,
    required this.player1Color,
    required this.player2Color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / gridSize;
    final Paint linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Draw grid
    for (int i = 0; i <= gridSize; i++) {
      final double position = i * cellSize;

      // Draw horizontal line
      canvas.drawLine(
        Offset(0, position),
        Offset(size.width, position),
        linePaint,
      );

      // Draw vertical line
      canvas.drawLine(
        Offset(position, 0),
        Offset(position, size.height),
        linePaint,
      );
    }

    // Add some sample points to show colors
    final Paint point1Paint = Paint()
      ..color = player1Color
      ..style = PaintingStyle.fill;

    final Paint point2Paint = Paint()
      ..color = player2Color
      ..style = PaintingStyle.fill;

    // Add a few sample points of player 1
    canvas.drawCircle(
      Offset(cellSize * 2, cellSize * 2),
      cellSize / 4,
      point1Paint,
    );
    canvas.drawCircle(
      Offset(cellSize * (gridSize - 2), cellSize * 3),
      cellSize / 4,
      point1Paint,
    );

    // Add a few sample points of player 2
    canvas.drawCircle(
      Offset(cellSize * 3, cellSize * (gridSize - 2)),
      cellSize / 4,
      point2Paint,
    );
    canvas.drawCircle(
      Offset(cellSize * (gridSize - 3), cellSize * (gridSize - 3)),
      cellSize / 4,
      point2Paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
