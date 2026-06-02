import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  // Initializer called during dependency injection
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Storage Keys
  static const _keyDailyGoal = 'daily_goal';
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';
  static const _keyLastReadSurahNum = 'last_read_surah_num';
  static const _keyLastReadSurahName = 'last_read_surah_name';
  static const _keyLastReadAyahNum = 'last_read_ayah_num';
  static const _keyStreakDays = 'streak_days';
  static const _keyCompletedAyahsToday = 'completed_ayahs_today';
  static const _keySelectedReciterId = 'selected_reciter_id';

  // 0. Selected Reciter ID (Persisted Qari Syed Sadaqat Ali as default)
  String get selectedReciterId => _prefs.getString(_keySelectedReciterId) ?? 'ar.syedsadaqatali';
  Future<bool> setSelectedReciterId(String value) => _prefs.setString(_keySelectedReciterId, value);

  // 1. Daily Reading Goal (Pages)
  int get dailyGoal => _prefs.getInt(_keyDailyGoal) ?? 10;
  Future<bool> setDailyGoal(int value) => _prefs.setInt(_keyDailyGoal, value);

  // 2. Reminder Alarm Time
  int get reminderHour => _prefs.getInt(_keyReminderHour) ?? 6;
  int get reminderMinute => _prefs.getInt(_keyReminderMinute) ?? 0;
  
  Future<bool> setReminderTime(int hour, int minute) async {
    final hSuccess = await _prefs.setInt(_keyReminderHour, hour);
    final mSuccess = await _prefs.setInt(_keyReminderMinute, minute);
    return hSuccess && mSuccess;
  }

  // 3. Last Read Coordinates (Surah Num, Surah Name, Ayah Num)
  int get lastReadSurahNum => _prefs.getInt(_keyLastReadSurahNum) ?? 2; // Default Al-Baqarah
  String get lastReadSurahName => _prefs.getString(_keyLastReadSurahName) ?? 'Al-Baqarah';
  int get lastReadAyahNum => _prefs.getInt(_keyLastReadAyahNum) ?? 255;

  Future<bool> setLastRead(int surahNum, String surahName, int ayahNum) async {
    final numSuccess = await _prefs.setInt(_keyLastReadSurahNum, surahNum);
    final nameSuccess = await _prefs.setString(_keyLastReadSurahName, surahName);
    final ayahSuccess = await _prefs.setInt(_keyLastReadAyahNum, ayahNum);
    return numSuccess && nameSuccess && ayahSuccess;
  }

  // 4. Streak Counter
  int get streakDays => _prefs.getInt(_keyStreakDays) ?? 5; // Default 5 days to showcase UI
  Future<bool> setStreakDays(int value) => _prefs.setInt(_keyStreakDays, value);

  // 5. Completed Ayahs Today
  int get completedAyahsToday => _prefs.getInt(_keyCompletedAyahsToday) ?? 7; // Default 7 to showcase UI
  Future<bool> setCompletedAyahsToday(int value) => _prefs.setInt(_keyCompletedAyahsToday, value);

  // 6. Bookmarked Ayahs List
  static const _keyBookmarks = 'bookmarks_list';
  List<String> get bookmarksList => _prefs.getStringList(_keyBookmarks) ?? [];
  Future<bool> setBookmarksList(List<String> values) => _prefs.setStringList(_keyBookmarks, values);
}
