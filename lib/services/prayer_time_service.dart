import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PrayerTimeService {
  static const String baseUrl = 'http://api.aladhan.com/v1/timings';

  Future<Map<String, dynamic>?> fetchPrayerTimes(double lat, double lng) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?latitude=$lat&longitude=$lng&method=2'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        debugPrint('Failed to load prayer times: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
      return null;
    }
  }
}
