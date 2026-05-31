import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../widgets/islamic_pattern_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showTagline = false;
  bool _showChallenge = false;

  @override
  void initState() {
    super.initState();
    Get.put(SplashController());
    // Staggered entrance animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showLogo = true);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showTagline = true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showChallenge = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B16), // Premium Midnight Blue background
      body: Stack(
        children: [
          // 1. Subtle Slogan Pattern (Background Tiling Lattices)
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: const Color(0xFFFFD700), // Gold overlay
                strokeWidth: 0.8,
              ),
            ),
          ),

          // 2. Central Glow Layer
          Center(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.08), // Gentle gold glow
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Brand Elements
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated App Icon
                AnimatedOpacity(
                  opacity: _showLogo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack,
                  child: AnimatedScale(
                    scale: _showLogo ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Animated Tagline Slogan
                AnimatedOpacity(
                  opacity: _showTagline ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  child: const Text(
                    "Your Daily Journey into the Quran",
                    style: TextStyle(
                      color: Color(0xFFFFD700), // Shimmering Gold
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Animated App Subtitle
                AnimatedOpacity(
                  opacity: _showChallenge ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  child: Text(
                    "30-Day Quran Challenge",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7), // Soft cream/white
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
