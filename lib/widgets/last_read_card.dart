import 'package:flutter/material.dart';
import 'islamic_pattern_painter.dart';

class LastReadCard extends StatelessWidget {
  final String surahName;
  final int ayahNumber;
  final VoidCallback onResume;

  const LastReadCard({
    super.key,
    this.surahName = 'Al-Baqarah',
    this.ayahNumber = 255,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Neumorphic-light soft floating shadow (large blur, small offset, low opacity)
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          // Subtle inner glow simulation from top
          BoxShadow(
            color: const Color(0xFF0A2B4E).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onResume,
            splashColor: const Color(0xFFFFD700).withOpacity(0.12),
            highlightColor: const Color(0xFFFFD700).withOpacity(0.06),
            child: Stack(
              children: [
                // 1. Radial Gradient Background (lighter Royal Blue in center, deeper Midnight Blue at edges)
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF0A2B4E), // Light Royal Blue center
                        Color(0xFF051C36), // Deep Midnight Blue edges
                      ],
                      center: Alignment.center,
                      radius: 1.1,
                    ),
                  ),
                ),

                // 2. Texture: Repeating tileable Islamic pattern overlay
                // Using ClipRect to ensure the pattern is perfectly masked to the card's boundary
                Positioned.fill(
                  child: ClipRect(
                    child: CustomPaint(
                      painter: IslamicPatternPainter(),
                    ),
                  ),
                ),

                // 3. Subtle gold overlay to enrich the radial glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.04), // 4% gold glow
                          Colors.transparent,
                        ],
                        center: const Alignment(-0.3, -0.2),
                        radius: 0.8,
                      ),
                    ),
                  ),
                ),

                // 4. Content Layout
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(22.0),
                  child: Row(
                    children: [
                      // Left column: Progress info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Row with mini icon + "Last Read" label
                            Row(
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: Color(0xFFE2B93B), // Warm Gold
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'LAST READ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE2B93B), // Gold color
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Surah name
                            Text(
                              surahName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ayah description
                            Text(
                              'Ayah No: $ayahNumber',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right side: Resume button
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildResumeButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumeButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2B93B), // Gold accent
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2B93B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow_rounded,
            color: Color(0xFF051C36),
            size: 18,
          ),
          SizedBox(width: 4),
          Text(
            'Resume',
            style: TextStyle(
              color: Color(0xFF051C36),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
