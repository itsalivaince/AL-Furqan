import 'package:get/get.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../services/quran_api_service.dart';

class QuranController extends GetxController {
  final QuranApiService _apiService = QuranApiService();

  // Reactive State variables
  final surahList = <SurahModel>[].obs;
  final loadedAyahs = <AyahModel>[].obs;

  final isLoadingSurahs = false.obs;
  final isLoadingDetail = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSurahList();
  }

  // Fetch and cache the 114 Surahs
  Future<void> loadSurahList() async {
    isLoadingSurahs.value = true;
    errorMessage.value = '';
    try {
      final list = await _apiService.fetchSurahList();
      surahList.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingSurahs.value = false;
    }
  }

  // Fetch detail (Arabic and Urdu text) for a specific Surah
  Future<void> loadSurahDetail(int surahNumber) async {
    isLoadingDetail.value = true;
    errorMessage.value = '';
    loadedAyahs.clear();
    try {
      final list = await _apiService.fetchSurahDetail(surahNumber);
      loadedAyahs.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // Fetch detail (Arabic and Urdu text) for a specific Juz
  Future<void> loadJuzDetail(int juzNumber) async {
    isLoadingDetail.value = true;
    errorMessage.value = '';
    loadedAyahs.clear();
    try {
      final list = await _apiService.fetchJuzDetail(juzNumber);
      loadedAyahs.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingDetail.value = false;
    }
  }
}
