import 'package:flutter/material.dart';

import '../../models/game_state.dart';
import '../../models/point.dart';
import '../../models/square.dart';

class SquarePainter extends CustomPainter {
  final Square square;
  final GameState gameState;
  static const double gridSpacing = 32.0;

  SquarePainter({required this.square, required this.gameState});

  @override
  void paint(Canvas canvas, Size size) {
    if (square.points.length != 4) return;

    // Create fill and stroke paints
    final fillPaint = Paint()
      ..color = square.color.withAlpha(60)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = square.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    Point topLeft = square.points.reduce((a, b) =>
        a.row * gameState.gridSize + a.col < b.row * gameState.gridSize + b.col
            ? a
            : b);

    Point topRight = square.points
        .firstWhere((p) => p.row == topLeft.row && p.col == topLeft.col + 1);
    Point bottomLeft = square.points
        .firstWhere((p) => p.col == topLeft.col && p.row == topLeft.row + 1);
    Point bottomRight = square.points
        .firstWhere((p) => p.row == bottomLeft.row && p.col == topRight.col);

    final path = Path();

    void addPointToPath(Point p, bool isFirst) {
      double x = p.col * gridSpacing + gridSpacing / 2;
      double y = p.row * gridSpacing + gridSpacing / 2;
      if (isFirst) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    addPointToPath(topLeft, true);
    addPointToPath(topRight, false);
    addPointToPath(bottomRight, false);
    addPointToPath(bottomLeft, false);

    path.close();

    // Draw fill first, then stroke
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Draw small circle at center of square to indicate ownership
    final centerX =
        (topLeft.col + topRight.col) * gridSpacing / 2 + gridSpacing / 2;
    final centerY =
        (topLeft.row + bottomLeft.row) * gridSpacing / 2 + gridSpacing / 2;

    final playerMarkerPaint = Paint()
      ..color = square.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      4.0,
      playerMarkerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
// class SquarePainter extends CustomPainter {
//   final Square square;
//   final GameState gameState;
//   static const double gridSpacing = 32.0;

//   SquarePainter({required this.square, required this.gameState});

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (square.points.length != 4) return;

//     final paint = Paint()
//       ..color = square.color.withAlpha(204)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     // Trouver les coins du carré 1x1
//     Point topLeft = square.points.reduce((a, b) =>
//         a.row * gameState.gridSize + a.col < b.row * gameState.gridSize + b.col
//             ? a
//             : b);

//     // Les autres points par rapport au top-left
//     Point topRight = square.points
//         .firstWhere((p) => p.row == topLeft.row && p.col == topLeft.col + 1);
//     Point bottomLeft = square.points
//         .firstWhere((p) => p.col == topLeft.col && p.row == topLeft.row + 1);
//     Point bottomRight = square.points
//         .firstWhere((p) => p.row == bottomLeft.row && p.col == topRight.col);

//     // Dessiner dans l'ordre correct pour former un carré 1x1
//     final path = Path();

//     void addPointToPath(Point p, bool isFirst) {
//       double x = p.col * gridSpacing + gridSpacing / 2;
//       double y = p.row * gridSpacing + gridSpacing / 2;
//       if (isFirst) {
//         path.moveTo(x, y);
//       } else {
//         path.lineTo(x, y);
//       }
//     }

//     // Dessiner dans l'ordre: haut-gauche -> haut-droite -> bas-droite -> bas-gauche
//     addPointToPath(topLeft, true);
//     addPointToPath(topRight, false);
//     addPointToPath(bottomRight, false);
//     addPointToPath(bottomLeft, false);

//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
