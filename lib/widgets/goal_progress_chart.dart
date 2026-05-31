import 'package:flutter/material.dart';

class GoalProgressChart extends StatelessWidget {
  final int currentGoal;
  final List<int> actualValues;
  final List<int> targetValues;
  final List<String> labels;
  final int maxVal;

  const GoalProgressChart({
    super.key,
    required this.currentGoal,
    this.actualValues = const [5, 12, 8, 15, 6, 10, 14],
    this.targetValues = const [10, 10, 10, 10, 12, 12, 10],
    this.labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.maxVal = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: CustomPaint(
        painter: _GoalProgressChartPainter(
          currentGoal: currentGoal,
          actualValues: actualValues,
          targetValues: targetValues,
          labels: labels,
          maxVal: maxVal,
          accentColor: const Color(0xFF34D399), // Mint Green actual
          targetColor: const Color(0xFF00ADB5).withOpacity(0.18), // Soft teal/cyan target
          lineColor: const Color(0xFFFFD700), // Gold target line
        ),
      ),
    );
  }
}

class _GoalProgressChartPainter extends CustomPainter {
  final int currentGoal;
  final List<int> actualValues;
  final List<int> targetValues;
  final List<String> labels;
  final int maxVal;
  final Color accentColor;
  final Color targetColor;
  final Color lineColor;

  _GoalProgressChartPainter({
    required this.currentGoal,
    required this.actualValues,
    required this.targetValues,
    required this.labels,
    required this.maxVal,
    required this.accentColor,
    required this.targetColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPadding = 24.0;
    const double rightPadding = 48.0; // Space for the goal indicator tag
    final double chartHeight = size.height - bottomPadding;
    final double chartWidth = size.width - rightPadding;

    final int numBars = actualValues.length;
    final double colWidth = chartWidth / numBars;
    final double barWidth = colWidth * 0.4;

    final paintActual = Paint()..style = PaintingStyle.fill;
    final paintTarget = Paint()..style = PaintingStyle.fill;

    // 1. Draw Bars (Target and Actual)
    for (int i = 0; i < numBars; i++) {
      final double x = i * colWidth + (colWidth - barWidth) / 2;

      // Draw Target Bar (subtle background bar)
      final double targetHeight = (targetValues[i] / maxVal) * chartHeight;
      final double targetY = chartHeight - targetHeight;
      final rectTarget = Rect.fromLTWH(x, targetY, barWidth, targetHeight);
      paintTarget.color = targetColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectTarget, const Radius.circular(5)),
        paintTarget,
      );

      // Draw Actual Bar (solid glowing overlay bar)
      final double actualHeight = (actualValues[i] / maxVal) * chartHeight;
      final double actualY = chartHeight - actualHeight;
      final rectActual = Rect.fromLTWH(x, actualY, barWidth, actualHeight);
      paintActual.color = accentColor;
      
      // Add a slight blur shadow for actual bars to give them a glowing presence
      final actualShadowPaint = Paint()
        ..color = accentColor.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectActual.translate(0, 1), const Radius.circular(5)),
        actualShadowPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rectActual, const Radius.circular(5)),
        paintActual,
      );

      // Draw Day Labels at the bottom
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, chartHeight + 6),
      );
    }

    // 2. Draw Dynamic Target Line (Moves with Slider)
    final double lineY = chartHeight - (currentGoal / maxVal) * chartHeight;

    // A. Draw Glow Shadow for Target Line
    final paintLineGlow = Paint()
      ..color = lineColor.withOpacity(0.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(0, lineY), Offset(chartWidth, lineY), paintLineGlow);

    // B. Draw Solid Line
    final paintLine = Paint()
      ..color = lineColor.withOpacity(0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Draw dashed effect manually for premium feel
    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    double currentX = 0.0;
    while (currentX < chartWidth) {
      canvas.drawLine(
        Offset(currentX, lineY),
        Offset(currentX + dashWidth, lineY),
        paintLine,
      );
      currentX += dashWidth + dashSpace;
    }

    // C. Draw Circular Target Dot at the end of the line
    final paintCircle = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(chartWidth, lineY), 4.0, paintCircle);

    // D. Draw Text Goal Label at the right edge
    final textPainterGoal = TextPainter(
      text: TextSpan(
        text: "$currentGoal p",
        style: TextStyle(
          color: lineColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Goal indicator background tag
    final tagRect = Rect.fromLTWH(
      chartWidth + 6,
      lineY - (textPainterGoal.height + 8) / 2,
      textPainterGoal.width + 12,
      textPainterGoal.height + 8,
    );
    final paintTagBg = Paint()
      ..color = lineColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(tagRect, const Radius.circular(6)),
      paintTagBg,
    );

    // Paint goal text inside the tag
    textPainterGoal.paint(
      canvas,
      Offset(chartWidth + 12, lineY - textPainterGoal.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GoalProgressChartPainter oldDelegate) {
    return oldDelegate.currentGoal != currentGoal ||
        oldDelegate.actualValues != actualValues ||
        oldDelegate.targetValues != targetValues;
  }
}
