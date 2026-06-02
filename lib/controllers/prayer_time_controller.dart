import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';

class PrayerTimeController extends GetxController {
  final PrayerTimeService _service = PrayerTimeService();

  RxBool isLoading = true.obs;
  RxString locationName = 'Detecting location...'.obs;
  RxString hijriDate = ''.obs;
  RxMap<String, String> prayerTimes = <String, String>{}.obs;
  
  RxString nextPrayerName = ''.obs;
  RxString nextPrayerTime = ''.obs;
  Rx<Duration> timeUntilNextPrayer = Duration.zero.obs;

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        locationName.value = 'Location permission denied';
        isLoading.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getCityName(position.latitude, position.longitude);
      await _fetchPrayerTimes(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error initializing prayer times: $e');
      locationName.value = 'Failed to load data';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<void> _getCityName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        locationName.value = '${place.locality}, ${place.country}';
      }
    } catch (e) {
      locationName.value = 'Lat: ${lat.toStringAsFixed(2)}, Lng: ${lng.toStringAsFixed(2)}';
    }
  }

  Future<void> _fetchPrayerTimes(double lat, double lng) async {
    final data = await _service.fetchPrayerTimes(lat, lng);
    if (data != null) {
      final timings = data['timings'] as Map<String, dynamic>;
      prayerTimes.value = {
        'Fajr': timings['Fajr'],
        'Dhuhr': timings['Dhuhr'],
        'Asr': timings['Asr'],
        'Maghrib': timings['Maghrib'],
        'Isha': timings['Isha'],
      };

      final hijri = data['date']['hijri'];
      hijriDate.value = '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}';

      _calculateNextPrayer();
      _startCountdown();
      _scheduleAlarms();
    }
  }

  void _calculateNextPrayer() {
    if (prayerTimes.isEmpty) return;

    DateTime now = DateTime.now();
    DateTime? nextDateTime;
    String? nextName;

    // Ordered list of prayers to check
    List<String> orderedPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (String prayer in orderedPrayers) {
      String timeString = prayerTimes[prayer]!;
      List<String> parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      DateTime prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (prayerTime.isAfter(now)) {
        nextDateTime = prayerTime;
        nextName = prayer;
        break;
      }
    }

    // If no prayer left today, next prayer is Fajr tomorrow
    if (nextDateTime == null) {
      String fajrTime = prayerTimes['Fajr']!;
      List<String> parts = fajrTime.split(':');
      DateTime tomorrow = now.add(const Duration(days: 1));
      nextDateTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, int.parse(parts[0]), int.parse(parts[1]));
      nextName = 'Fajr';
    }

    nextPrayerName.value = nextName!;
    
    // Format for display (e.g., 03:45 PM)
    nextPrayerTime.value = DateFormat.jm().format(nextDateTime);
    
    _updateTimeUntilNext(nextDateTime);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (nextPrayerName.isNotEmpty && prayerTimes.isNotEmpty) {
        DateTime now = DateTime.now();
        String targetTimeStr = nextPrayerName.value == 'Fajr' && now.hour > 12 
            ? prayerTimes['Fajr']! 
            : prayerTimes[nextPrayerName.value]!;
        
        List<String> parts = targetTimeStr.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        DateTime targetDateTime = DateTime(now.year, now.month, now.day, hour, minute);
        
        // If next prayer is tomorrow Fajr
        if (nextPrayerName.value == 'Fajr' && now.hour > 12) {
           targetDateTime = targetDateTime.add(const Duration(days: 1));
        }

        if (now.isAfter(targetDateTime)) {
          // Time passed, recalculate next prayer
          _calculateNextPrayer();
        } else {
          _updateTimeUntilNext(targetDateTime);
        }
      }
    });
  }

  void _updateTimeUntilNext(DateTime target) {
    timeUntilNextPrayer.value = target.difference(DateTime.now());
  }

  void _scheduleAlarms() async {
    final notificationService = NotificationService();
    DateTime now = DateTime.now();

    // IDs for prayers: Fajr(1), Dhuhr(2), Asr(3), Maghrib(4), Isha(5)
    Map<String, int> prayerIds = {
      'Fajr': 1,
      'Dhuhr': 2,
      'Asr': 3,
      'Maghrib': 4,
      'Isha': 5,
    };

    prayerTimes.forEach((name, timeStr) {
      List<String> parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      DateTime prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      // If the time has passed today, schedule it for tomorrow
      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }

      int id = prayerIds[name] ?? 0;
      notificationService.schedulePrayerAlarm(id, name, prayerTime);
    });
  }
}
