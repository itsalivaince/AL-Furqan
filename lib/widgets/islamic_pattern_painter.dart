import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  IslamicPatternPainter({
    this.color = const Color(0xFFFFFFFF),
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08) // 8% opacity as requested
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.overlay; // BlendMode overlay as requested

    // Grid size for the tiling pattern
    final double step = 50.0;
    final double starRadius = step * 0.35;

    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final center = Offset(x, y);
        _drawEightPointedStar(canvas, center, starRadius, paint);
        _drawConnectingLines(canvas, center, step, paint);
      }
    }
  }

  void _drawEightPointedStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final int points = 8;
    
    // Draw an interlocking 8-pointed star (Khatam)
    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? radius : radius * 0.54;
      final double angle = i * math.pi / points;
      final double px = center.dx + r * math.cos(angle);
      final double py = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Add a delicate outer circle around the star for extra texture
    canvas.drawCircle(center, radius * 1.15, paint);
  }

  void _drawConnectingLines(Canvas canvas, Offset center, double step, Paint paint) {
    // Draw connecting lattices between neighboring stars to make it feel tileable
    // Horizontal and vertical lines
    canvas.drawLine(
      Offset(center.dx + step * 0.35, center.dy),
      Offset(center.dx + step * 0.65, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + step * 0.35),
      Offset(center.dx, center.dy + step * 0.65),
      paint,
    );

    // Diagonals that meet at the center of each tile
    final tileCenter = Offset(center.dx + step / 2, center.dy + step / 2);
    
    // Draw a small 8-sided ring (octagon) at the center of the tile
    final path = Path();
    final double ringRadius = step * 0.12;
    for (int i = 0; i < 8; i++) {
      final double angle = i * math.pi / 4;
      final double px = tileCenter.dx + ringRadius * math.cos(angle);
      final double py = tileCenter.dy + ringRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
