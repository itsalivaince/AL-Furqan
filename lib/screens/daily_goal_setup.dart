import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/progress_controller.dart';
import '../services/notification_service.dart';
import '../widgets/goal_progress_chart.dart';

class DailyGoalSetupScreen extends StatefulWidget {
  final int initialPages;
  final TimeOfDay initialReminder;

  const DailyGoalSetupScreen({
    super.key,
    this.initialPages = 10,
    this.initialReminder = const TimeOfDay(hour: 6, minute: 0),
  });

  @override
  State<DailyGoalSetupScreen> createState() => _DailyGoalSetupScreenState();
}

class _DailyGoalSetupScreenState extends State<DailyGoalSetupScreen> {
  final ProgressController progressController = Get.find<ProgressController>();

  @override
  void initState() {
    super.initState();
    // Pre-populate if not loaded
    if (progressController.dailyPageGoal.value <= 0) {
      progressController.updateDailyGoal(widget.initialPages);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: progressController.reminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF34D399), // Mint green accent
              onPrimary: Color(0xFF070B16),
              surface: Color(0xFF0C1327),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0C1327),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != progressController.reminderTime) {
      // Instantly update the reactive value
      await progressController.updateReminderTime(picked);
      // Trigger the local notification service schedule
      await NotificationService().scheduleDailyReminder(picked);
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reminder set for ${_formatTimeOfDay(picked)}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hourStr:$minuteStr $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen Islamic Background Image with Premium Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF070B16),
                image: DecorationImage(
                  image: AssetImage('assets/images/islamic_bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0xFF070B16),
                    BlendMode.srcATop,
                  ),
                  opacity: 0.22,
                ),
              ),
            ),
          ),

          // Ambient glow elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34D399).withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A2B4E).withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // 2. Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Top Custom Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                     children: [
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
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Text(
                        "Daily Goal Coach",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Obx(() {
                        // Dynamic values
                        final int pagesPerDay = progressController.dailyPageGoal.value;
                        // Calculation for reading frequency
                        final int daysToComplete = (pagesPerDay > 0) ? (604 / pagesPerDay).ceil() : 604;
                        // Time calculation dynamically tracks completed reading plus estimated pace
                        final int minutesPerDay = pagesPerDay * 3; 
                        final int readingsPerYear = daysToComplete > 0 ? (365 ~/ daysToComplete) : 0;
                        final TimeOfDay reminderTime = progressController.reminderTime;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            
                            // --- 1. PERFORMANCE GRAPH (TOP) ---
                            _buildCardSection(
                              title: "PERFORMANCE",
                              child: GoalProgressChart(currentGoal: pagesPerDay),
                            ),
                            const SizedBox(height: 24),

                            // --- 2. STAT CARDS ---
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricTile(
                                    label: "DAILY COMMITMENT",
                                    value: "~$minutesPerDay mins",
                                    subtitle: "estimated time",
                                    icon: Icons.hourglass_top_rounded,
                                    color: const Color(0xFF34D399),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildMetricTile(
                                    label: "YEARLY FREQUENCY",
                                    value: "$readingsPerYear times",
                                    subtitle: "readings per year",
                                    icon: Icons.repeat_on_rounded,
                                    color: const Color(0xFF00ADB5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // --- 3. COACH FORECAST ---
                            _buildCardSection(
                              title: "COACH FORECAST",
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Color(0xFF34D399),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(text: "At this pace, you will complete the entire Quran in "),
                                          TextSpan(
                                            text: "$daysToComplete days",
                                            style: const TextStyle(
                                              color: Color(0xFF34D399),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const TextSpan(text: "."),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- 4. HABIT TRIGGER (REMINDER) ---
                            _buildCardSection(
                              title: "HABIT TRIGGER",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.notifications_active_outlined,
                                        color: Color(0xFF34D399),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Daily Reminder",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "Set a time to build a consistent habit",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Custom Time Picker Button
                                      InkWell(
                                        onTap: () => _selectTime(context),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.04),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFF34D399).withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            _formatTimeOfDay(reminderTime),
                                            style: const TextStyle(
                                              color: Color(0xFF34D399),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- 5. GOAL SELECTION CARD (BOTTOM) ---
                            _buildCardSection(
                              title: "CHOOSE YOUR PACE",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Daily Reading",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF34D399).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "$pagesPerDay Pages/day",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF34D399),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: const Color(0xFF34D399),
                                      inactiveTrackColor: Colors.white.withOpacity(0.08),
                                      thumbColor: Colors.white,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                      overlayColor: const Color(0xFF34D399).withOpacity(0.2),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                                      trackHeight: 6,
                                    ),
                                    child: Slider(
                                      value: pagesPerDay.toDouble(),
                                      min: 1,
                                      max: 30,
                                      divisions: 29,
                                      onChanged: (val) {
                                        // Dynamically triggers updates across all Obx widgets instantly
                                        progressController.updateDailyGoal(val.round());
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Quick Read (1 p)", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35))),
                                      Text("Intense Read (30 p)", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                
                // --- 6. FINAL BUTTON ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF059669),
                          Color(0xFF34D399),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF34D399).withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                         onTap: () {
                          // The settings are already saved on the fly due to the Obx reactivity.
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Daily Goal successfully updated!"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              "Set Daily Goal",
                              style: TextStyle(
                                color: Color(0xFF070B16),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildCardSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.35),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1327).withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.0,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

