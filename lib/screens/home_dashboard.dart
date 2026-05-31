import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/progress_controller.dart';
import '../controllers/quran_controller.dart';
import '../widgets/last_read_card.dart';
import '../widgets/todays_goal_card.dart';
import 'daily_goal_setup.dart';
import 'surah_list_screen.dart';
import 'surah_reader_screen.dart';
import 'juz_list_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Inject reactive controllers
  final ProgressController progressController = Get.find<ProgressController>();
  final QuranController quranController = Get.find<QuranController>();

  void _handleResume() {
    Get.to(() => SurahReaderScreen(
      surahNumber: progressController.lastReadSurahNum.value,
      surahName: progressController.lastReadSurahName.value,
      initialAyahNumber: progressController.lastReadAyahNum.value,
    ));
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Opening Settings...',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen Islamic Background Image with Premium Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070B16), // Deepest dark space color
                image: const DecorationImage(
                  image: AssetImage('assets/images/islamic_bg.png'),
                  fit: BoxFit.cover,
                  // Very low contrast dark overlay for readability while keeping the pattern visible
                  colorFilter: ColorFilter.mode(
                    Color(0xFF070B16),
                    BlendMode.srcATop,
                  ),
                  opacity: 0.22, // Keeps background pattern extremely subtle
                ),
              ),
            ),
          ),

          // Subtle colorful ambient backdrops (nebula-glow effect in corners)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A2B4E).withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // 2. Foreground Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assalam-o-Alaikum',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'May peace be upon you',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        // Settings Button with soft glassmorphic style
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings_suggest_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _openSettings,
                            tooltip: 'Settings',
                            splashRadius: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- LAST READ CARD SECTION ---
                    Obx(() => LastReadCard(
                      surahName: progressController.lastReadSurahName.value,
                      ayahNumber: progressController.lastReadAyahNum.value,
                      onResume: _handleResume,
                    )),
                    const SizedBox(height: 20),

                    // --- TODAY'S GOAL CARD ---
                    Obx(() => TodaysGoalCard(
                      completedAyahs: progressController.completedAyahsToday.value,
                      totalAyahs: progressController.dailyPageGoal.value,
                      streakDays: progressController.streakDays.value,
                      onTap: () {
                        Get.to(() => DailyGoalSetupScreen(
                          initialPages: progressController.dailyPageGoal.value,
                          initialReminder: progressController.reminderTime,
                        ));
                      },
                    )),
                    const SizedBox(height: 36),

                    // --- QUICK ACTIONS SECTION ---
                    Row(
                      children: [
                        Text(
                          'EXPLORE SERVICES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Grid of 4 Premium Category Buttons
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        _buildMenuCard(
                          title: 'Surah Index',
                          subtitle: 'Read by chapters',
                          icon: Icons.format_list_bulleted_rounded,
                          accentColor: const Color(0xFF00ADB5), // Cyan
                          onTap: () {
                            Get.to(() => const SurahListScreen());
                          },
                        ),
                        _buildMenuCard(
                          title: 'Juz Index',
                          subtitle: 'Read by sections',
                          icon: Icons.grid_on_rounded,
                          accentColor: const Color(0xFFFFD700), // Gold
                          onTap: () {
                            Get.to(() => const JuzListScreen());
                          },
                        ),
                        _buildMenuCard(
                          title: 'Bookmarks',
                          subtitle: 'Saved ayahs',
                          icon: Icons.bookmark_rounded,
                          accentColor: const Color(0xFFEF4444), // Crimson
                          onTap: () {},
                        ),
                        _buildMenuCard(
                          title: 'Prayer Times',
                          subtitle: 'Daily schedule',
                          icon: Icons.access_time_rounded,
                          accentColor: const Color(0xFF10B981), // Emerald
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row with Icon and minor glow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.15),
                      size: 12,
                    ),
                  ],
                ),
                // Titles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
