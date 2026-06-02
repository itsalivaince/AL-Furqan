import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ayah_model.dart';
import '../services/storage_service.dart';
import 'audio_controller.dart';

class BookmarkController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final RxList<AyahModel> bookmarkedAyahs = <AyahModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(AudioController());
    _loadBookmarks();
  }

  void _loadBookmarks() {
    try {
      final List<String> list = _storageService.bookmarksList;
      final List<AyahModel> parsed = list.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return AyahModel.fromStorageJson(decoded);
      }).toList();
      bookmarkedAyahs.assignAll(parsed);
    } catch (e) {
      print('Error loading bookmarks: $e');
    }
  }

  bool isBookmarked(AyahModel ayah) {
    return bookmarkedAyahs.any((a) => a.number == ayah.number);
  }

  Future<void> toggleBookmark(AyahModel ayah) async {
    try {
      final index = bookmarkedAyahs.indexWhere((a) => a.number == ayah.number);
      if (index >= 0) {
        bookmarkedAyahs.removeAt(index);
        Get.snackbar(
          'Removed Bookmark',
          'Ayah removed from your bookmarks list',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444), // Red background
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
      } else {
        bookmarkedAyahs.add(ayah);
        Get.snackbar(
          'Saved Bookmark',
          'Ayah added to your bookmarks list',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFD700), // Gold/Amber background
          colorText: const Color(0xFF070B16),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
      }
      
      final List<String> serialized = bookmarkedAyahs.map((a) {
        return jsonEncode(a.toJson());
      }).toList();
      
      await _storageService.setBookmarksList(serialized);
      bookmarkedAyahs.refresh();
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }
}
