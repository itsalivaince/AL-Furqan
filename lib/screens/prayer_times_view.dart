import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/prayer_time_controller.dart';

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  final PrayerTimeController controller = Get.put(PrayerTimeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070B16), // Deepest dark space color
                image: const DecorationImage(
                  image: AssetImage('assets/images/islamic_bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0xFF070B16),
                    BlendMode.srcATop,
                  ),
                  opacity: 0.15,
                ),
              ),
            ),
          ),
          
          // Ambient Glow
          Positioned(
            top: 0,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                );
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),
                    
                    // Next Prayer Hero Card
                    _buildHeroCard(),
                    const SizedBox(height: 32),
                    
                    // Daily Schedule Title
                    Text(
                      'Daily Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Schedule List
                    if (controller.prayerTimes.isNotEmpty) ...[
                      _buildPrayerTile('Fajr', controller.prayerTimes['Fajr']!),
                      _buildPrayerTile('Dhuhr', controller.prayerTimes['Dhuhr']!),
                      _buildPrayerTile('Asr', controller.prayerTimes['Asr']!),
                      _buildPrayerTile('Maghrib', controller.prayerTimes['Maghrib']!),
                      _buildPrayerTile('Isha', controller.prayerTimes['Isha']!),
                    ] else ...[
                       Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    ]
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.locationName.value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: Colors.white.withOpacity(0.5), size: 14),
            const SizedBox(width: 6),
            Text(
              controller.hijriDate.value.isNotEmpty ? controller.hijriDate.value : 'Loading Date...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981).withOpacity(0.2), // Emerald glow
                const Color(0xFF0A2B4E).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEXT PRAYER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Icon(Icons.notifications_active_rounded, color: Colors.white.withOpacity(0.5), size: 18),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                controller.nextPrayerName.value.isEmpty ? '---' : controller.nextPrayerName.value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.nextPrayerTime.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              _buildCountdownTimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    final dur = controller.timeUntilNextPrayer.value;
    String hours = dur.inHours.toString().padLeft(2, '0');
    String minutes = (dur.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (dur.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        _timeBox(hours, 'HR'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        _timeBox(minutes, 'MIN'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        _timeBox(seconds, 'SEC'),
      ],
    );
  }

  Widget _timeBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTile(String name, String timeStr) {
    bool isActive = controller.nextPrayerName.value == name;
    
    // Parse time for 12-hour format display
    String displayTime = '';
    try {
      List<String> parts = timeStr.split(':');
      DateTime dt = DateTime(2020, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      // To format we'd use intl, but here is a simple manual fallback, or just use parts
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      String ampm = h >= 12 ? 'PM' : 'AM';
      int h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      displayTime = '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
    } catch (e) {
      displayTime = timeStr;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981).withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          Icons.access_time_rounded,
          color: isActive ? const Color(0xFF10B981) : Colors.white.withOpacity(0.5),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.8),
          ),
        ),
        trailing: Text(
          displayTime,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isActive ? const Color(0xFF10B981) : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
