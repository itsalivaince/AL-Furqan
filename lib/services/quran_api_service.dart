import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // Fetch all 114 Surah headers
  Future<List<SurahModel>> fetchSurahList() async {
    final url = Uri.parse('$baseUrl/surah');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['code'] == 200) {
          final List<dynamic> surahsJson = body['data'];
          return surahsJson.map((json) => SurahModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load Surah list from API: status ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error fetching Surah list: $e');
    }
  }

  // Fetch details (Arabic text and Urdu translation) for a specific Surah concurrently and merge them
  Future<List<AyahModel>> fetchSurahDetail(int surahNumber) async {
    final urlArabic = Uri.parse('$baseUrl/surah/$surahNumber');
    final urlUrdu = Uri.parse('$baseUrl/surah/$surahNumber/ur.jalandhry');

    try {
      // Run both network requests in parallel
      final responses = await Future.wait([
        http.get(urlArabic),
        http.get(urlUrdu),
      ]);

      final responseArabic = responses[0];
      final responseUrdu = responses[1];

      if (responseArabic.statusCode == 200 && responseUrdu.statusCode == 200) {
        final Map<String, dynamic> bodyArabic = jsonDecode(responseArabic.body);
        final Map<String, dynamic> bodyUrdu = jsonDecode(responseUrdu.body);

        if (bodyArabic['code'] == 200 && bodyUrdu['code'] == 200) {
          final List<dynamic> arabicAyahs = bodyArabic['data']['ayahs'];
          final List<dynamic> urduAyahs = bodyUrdu['data']['ayahs'];

          final int sNum = bodyArabic['data']['number'] as int;
          final String sName = bodyArabic['data']['englishName'] as String;

          final List<AyahModel> mergedAyahs = [];
          for (int i = 0; i < arabicAyahs.length; i++) {
            final Map<String, dynamic> arabicJson = arabicAyahs[i];
            final String urduText = urduAyahs[i]['text'] as String;
            mergedAyahs.add(AyahModel.fromJson(arabicJson, urduText, surahNumber: sNum, surahName: sName));
          }

          return mergedAyahs;
        }
      }
      throw Exception('Failed to load Surah detail: Arabic status ${responseArabic.statusCode}, Urdu status ${responseUrdu.statusCode}');
    } catch (e) {
      throw Exception('Network error fetching Surah details: $e');
    }
  }

  // Fetch details (Arabic text and Urdu translation) for a specific Juz concurrently and merge them
  Future<List<AyahModel>> fetchJuzDetail(int juzNumber) async {
    final urlArabic = Uri.parse('$baseUrl/juz/$juzNumber/quran-uthmani');
    final urlUrdu = Uri.parse('$baseUrl/juz/$juzNumber/ur.jalandhry');

    try {
      final responses = await Future.wait([
        http.get(urlArabic),
        http.get(urlUrdu),
      ]);

      final responseArabic = responses[0];
      final responseUrdu = responses[1];

      if (responseArabic.statusCode == 200 && responseUrdu.statusCode == 200) {
        final Map<String, dynamic> bodyArabic = jsonDecode(responseArabic.body);
        final Map<String, dynamic> bodyUrdu = jsonDecode(responseUrdu.body);

        if (bodyArabic['code'] == 200 && bodyUrdu['code'] == 200) {
          final List<dynamic> arabicAyahs = bodyArabic['data']['ayahs'];
          final List<dynamic> urduAyahs = bodyUrdu['data']['ayahs'];

          if (arabicAyahs.length != urduAyahs.length) {
            throw Exception('Mismatch between Arabic and Urdu verse count for Juz $juzNumber');
          }

          final List<AyahModel> mergedAyahs = [];
          for (int i = 0; i < arabicAyahs.length; i++) {
            final Map<String, dynamic> arabicJson = arabicAyahs[i];
            final String urduText = urduAyahs[i]['text'] as String;
            mergedAyahs.add(AyahModel.fromJson(arabicJson, urduText));
          }

          return mergedAyahs;
        }
      }
      throw Exception('Failed to load Juz detail: Arabic status ${responseArabic.statusCode}, Urdu status ${responseUrdu.statusCode}');
    } catch (e) {
      throw Exception('Network error fetching Juz details: $e');
    }
  }
}
