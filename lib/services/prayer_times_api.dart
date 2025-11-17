import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint; // ✅ EKLEDİK
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesApi {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>?> getPrayerTimesByLocation(
      double latitude, double longitude, int method) async {
    await _initPrefs();

    final cacheKey = 'prayer_times_loc_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}_$method';
    final cached = await _getCachedTimings(cacheKey);
    if (cached != null) return cached;

    try {
      final date = DateTime.now();
      final response = await http.get(
        Uri.parse('$_baseUrl/timings/${date.day}-${date.month}-${date.year}'
            '?latitude=$latitude'
            '&longitude=$longitude'
            '&method=$method'
            '&school=0'),
      );

      if (response.statusCode == 200) { // ✅ DÜZELTİLDİ: status_code -> statusCode
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          await _cacheTimings(cacheKey, data['data']['timings']);
          return data['data']['timings'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching prayer times: $e'); // ✅ debugPrint artık tanımlı
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPrayerTimesByCity(
      String city, String country, int method) async {
    try {
      final date = DateTime.now();
      final cacheKey = 'prayer_times_city_${city}_$method';
      final response = await http.get(
        Uri.parse('$_baseUrl/timingsByCity/${date.day}-${date.month}-${date.year}'
            '?city=$city'
            '&country=$country'
            '&method=$method'
            '&school=0'),
      );

      if (response.statusCode == 200) { // ✅ DÜZELTİLDİ: status_code -> statusCode
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          await _cacheTimings(cacheKey, data['data']['timings']);
          return data['data']['timings'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching prayer times by city: $e'); // ✅ debugPrint artık tanımlı
      return null;
    }
  }

  Future<void> _cacheTimings(String key, Map<String, dynamic> timings) async {
    final cacheData = {
      'timings': timings,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _prefs?.setString(key, json.encode(cacheData));
  }

  Future<Map<String, dynamic>?> _getCachedTimings(String key) async {
    final cachedData = _prefs?.getString(key);
    if (cachedData == null) return null;

    try {
      final data = json.decode(cachedData);
      final timestamp = data['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp < 12 * 60 * 60 * 1000) {
        return Map<String, dynamic>.from(data['timings']);
      }
      return null;
    } catch (e) {
      debugPrint('Cache error: $e'); // ✅ debugPrint artık tanımlı
      return null;
    }
  }

  List<Map<String, dynamic>> getCalculationMethods() {
    // ... (method içeriği değişmedi)
    return [
      {'id': 0, 'name': 'Muslim World League', 'description': 'Fajr: 18°, Isha: 17°'},
      {'id': 1, 'name': 'ISNA', 'description': 'Fajr: 15°, Isha: 15°'},
      {'id': 2, 'name': 'Egypt', 'description': 'Fajr: 19.5°, Isha: 17.5°'},
      {'id': 3, 'name': 'Makkah', 'description': 'Fajr: 18.5°, Isha: 90 min after Maghrib'},
      {'id': 4, 'name': 'Karachi', 'description': 'Fajr: 18°, Isha: 18°'},
      {'id': 5, 'name': 'Umm Al-Qura', 'description': 'Fajr: 18.5°, Isha: 90 min after Maghrib'},
      {'id': 7, 'name': 'Gulf Region', 'description': 'Fajr: 19.5°, Isha: 90 min after Maghrib'},
      {'id': 8, 'name': 'Kuwait', 'description': 'Fajr: 18°, Isha: 17.5°'},
      {'id': 9, 'name': 'Qatar', 'description': 'Fajr: 18°, Isha: 90 min after Maghrib'},
      {'id': 10, 'name': 'Singapore', 'description': 'Fajr: 20°, Isha: 18°'},
      {'id': 11, 'name': 'France (12°)', 'description': 'Fajr: 12°, Isha: 12°'},
      {'id': 12, 'name': 'France (15°)', 'description': 'Fajr: 15°, Isha: 15°'},
      {'id': 13, 'name': 'France (18°)', 'description': 'Fajr: 18°, Isha: 18°'},
      {'id': 99, 'name': 'Custom', 'description': 'Kendi açılarınızı belirleyin'},
    ];
  }

  String? getNextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final prayerTimes = {
      'Fajr': _parseTime(timings['Fajr']),
      'Dhuhr': _parseTime(timings['Dhuhr']),
      'Asr': _parseTime(timings['Asr']),
      'Maghrib': _parseTime(timings['Maghrib']),
      'Isha': _parseTime(timings['Isha']),
    };

    for (final prayer in prayerTimes.entries) {
      final prayerTime = DateTime(
          today.year, today.month, today.day,
          prayer.value.hour, prayer.value.minute
      );

      if (prayerTime.isAfter(now)) {
        return prayer.key;
      }
    }

    return 'Fajr';
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }
}