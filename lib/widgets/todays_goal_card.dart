import 'dart:ui';
import 'package:flutter/material.dart';

class TodaysGoalCard extends StatelessWidget {
  final int completedAyahs;
  final int totalAyahs;
  final int streakDays;
  final VoidCallback? onTap;

  const TodaysGoalCard({
    super.key,
    this.completedAyahs = 7,
    this.totalAyahs = 10,
    this.streakDays = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (completedAyahs / totalAyahs).clamp(0.0, 1.0);
    
    // Cohesive Emerald Green / Teal Accent color palette for an analogous, calming feel
    const Color accentColor = Color(0xFF34D399); // Mint green glow
    const Color darkAccentColor = Color(0xFF059669); // Deep emerald

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            // 40% opacity Navy/Dark Blue background for Glassmorphism
            color: const Color(0xFF0C1327).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              // Microscopic, semi-transparent white border to catch the light
              color: Colors.white.withOpacity(0.1),
              width: 1.0,
            ),
            boxShadow: [
              // Soft, diffuse shadow for floating effect
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. HEADER SECTION
                    Row(
                      children: [
                        // Left: Circular shape holding target icon with highly transparent version of accent color
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.track_changes_outlined, // Thin, elegant line-art icon
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Right: Title and Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Daily's Goal",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Read $totalAyahs Ayahs today",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. PROGRESS BAR
                    _buildProgressBar(percentage, accentColor, darkAccentColor),
                    const SizedBox(height: 22),

                    // 3. FOOTER SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Edge: Completed Ayahs Fraction
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                // Dimmed label to 40% white
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedAyahs/$totalAyahs Ayahs',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Right Edge: Streak Counter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'STREAK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                // Dimmed label to 40% white
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$streakDays-day streak!',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor, // Matches the emerald theme
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percentage, Color accentColor, Color darkAccentColor) {
    // Increased thickness slightly (from 16.0 to 20.0)
    const double barHeight = 20.0;
    const double radius = 10.0;

    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          // Left portion: Solid completed section with horizontal gradient and glow
          if (percentage > 0)
            Expanded(
              flex: (percentage * 100).round(),
              child: Container(
                decoration: BoxDecoration(
                  // Horizontal gradient from deep emerald to glowing mint
                  gradient: LinearGradient(
                    colors: [
                      darkAccentColor,
                      accentColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(radius),
                    bottomLeft: const Radius.circular(radius),
                    topRight: Radius.circular(percentage == 1.0 ? radius : 0),
                    bottomRight: Radius.circular(percentage == 1.0 ? radius : 0),
                  ),
                  boxShadow: [
                    // Glowing soft shadow under the filled portion
                    BoxShadow(
                      color: accentColor.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),

          // Right portion: Patterned remaining section
          if (percentage < 1.0)
            Expanded(
              flex: ((1.0 - percentage) * 100).round(),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(radius),
                  bottomRight: const Radius.circular(radius),
                  topLeft: Radius.circular(percentage == 0.0 ? radius : 0),
                  bottomLeft: Radius.circular(percentage == 0.0 ? radius : 0),
                ),
                child: Stack(
                  children: [
                    // Slightly lighter transparent background
                    Container(
                      color: Colors.white.withOpacity(0.06),
                    ),
                    // Diagonal lines overlay pattern (crisp, highly transparent 15% white)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DiagonalLinesPainter(
                          color: Colors.white.withOpacity(0.15),
                          strokeWidth: 1.5,
                          spacing: 7.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DiagonalLinesPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double spacing;

  DiagonalLinesPainter({
    required this.color,
    required this.strokeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw repeating diagonal lines
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
