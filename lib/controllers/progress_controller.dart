import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class ProgressController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  // Reactive state values
  final dailyPageGoal = 10.obs;
  final completedAyahsToday = 7.obs;
  final streakDays = 5.obs;

  final lastReadSurahNum = 2.obs;
  final lastReadSurahName = 'Al-Baqarah'.obs;
  final lastReadAyahNum = 255.obs;

  final reminderHour = 6.obs;
  final reminderMinute = 0.obs;

  // Derived progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (dailyPageGoal.value <= 0) return 0.0;
    return (completedAyahsToday.value / dailyPageGoal.value).clamp(0.0, 1.0);
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  // Synchronize initial controller state with SharedPreferences
  void _loadFromStorage() {
    dailyPageGoal.value = _storage.dailyGoal;
    completedAyahsToday.value = _storage.completedAyahsToday;
    streakDays.value = _storage.streakDays;

    lastReadSurahNum.value = _storage.lastReadSurahNum;
    lastReadSurahName.value = _storage.lastReadSurahName;
    lastReadAyahNum.value = _storage.lastReadAyahNum;

    reminderHour.value = _storage.reminderHour;
    reminderMinute.value = _storage.reminderMinute;
  }

  // Update and persist daily page count goal
  Future<void> updateDailyGoal(int pages) async {
    dailyPageGoal.value = pages;
    await _storage.setDailyGoal(pages);
  }

  // Update and persist alarm reminder time
  Future<void> updateReminderTime(TimeOfDay time) async {
    reminderHour.value = time.hour;
    reminderMinute.value = time.minute;
    await _storage.setReminderTime(time.hour, time.minute);
  }

  // Update and persist bookmark coordinates
  Future<void> updateLastRead(int surahNum, String surahName, int ayahNum) async {
    lastReadSurahNum.value = surahNum;
    lastReadSurahName.value = surahName;
    lastReadAyahNum.value = ayahNum;
    await _storage.setLastRead(surahNum, surahName, ayahNum);
  }

  // Increment daily completed reading progress
  Future<void> incrementProgress(int count) async {
    completedAyahsToday.value += count;
    await _storage.setCompletedAyahsToday(completedAyahsToday.value);
  }

  // Directly set completion state for debugging/admin
  Future<void> setCompletedProgress(int count) async {
    completedAyahsToday.value = count;
    await _storage.setCompletedAyahsToday(count);
  }

  // Directly update streak days
  Future<void> updateStreak(int days) async {
    streakDays.value = days;
    await _storage.setStreakDays(days);
  }

  // Helper getter to parse reminder hour/minute into TimeOfDay
  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour.value, minute: reminderMinute.value);
}
