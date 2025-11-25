import 'dart:convert';

import 'package:ezan_hatirlatici/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesApi {
  static const String baseUrl = "https://api.aladhan.com/v1";

  /// 🔥 Diyanet sabit metod ID
  static const int diyanetMethodId = 13;

  /// 🔥 Varsayılan hesaplama metodu
  int defaultMethod = diyanetMethodId;

  /// 📌 SharedPreferences’ten kayıtlı metodu okur, yoksa Diyanet döner
  Future<int> getSavedMethodOrDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('calculationMethod') ?? diyanetMethodId;
    } catch (e) {
      debugPrint('Error reading calculationMethod: $e');
      return diyanetMethodId;
    }
  }

  /// 🔥 Şehre göre namaz vakitleri
  Future<Map<String, dynamic>?> getPrayerTimesByCity(
      String city, String country, int method) async {
    final url = Uri.parse(
      "$baseUrl/timingsByCity?city=$city&country=$country&method=$method",
    );

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Map<String, dynamic>.from(json["data"]["timings"]);
      } else {
        debugPrint(
            "getPrayerTimesByCity failed: ${res.statusCode} → ${res.body}");
      }
    } catch (e) {
      debugPrint("getPrayerTimesByCity error: $e");
    }

    return null;
  }

  /// 🔥 Koordinata göre namaz vakitleri
  Future<Map<String, dynamic>?> getPrayerTimesByLocation(
      double lat, double lng, int method) async {
    final url = Uri.parse(
      "$baseUrl/timings?latitude=$lat&longitude=$lng&method=$method",
    );

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Map<String, dynamic>.from(json["data"]["timings"]);
      } else {
        debugPrint(
            "getPrayerTimesByLocation failed: ${res.statusCode} → ${res.body}");
      }
    } catch (e) {
      debugPrint("getPrayerTimesByLocation error: $e");
    }

    return null;
  }

  /// 🔥 YARININ NAMAZ VAKİTLERİ
  Future<Map<String, dynamic>?> getTomorrowsPrayerTimes(
      double lat, double lng, int method) async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final formatted =
          "${tomorrow.day}-${tomorrow.month}-${tomorrow.year}";

      final url = Uri.parse(
        "$baseUrl/timings/$formatted?latitude=$lat&longitude=$lng&method=$method",
      );

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Map<String, dynamic>.from(json["data"]["timings"]);
      } else {
        debugPrint("Tomorrow API failed: ${res.statusCode} → ${res.body}");
      }
    } catch (e) {
      debugPrint("Tomorrow prayer error: $e");
    }

    return null;
  }

  /// 🔥 Belirli bir tarihe ait namaz vakitleri
  Future<Map<String, dynamic>?> getPrayerTimesForDate({
    required DateTime date,
    double? lat,
    double? lng,
    String? city,
    String? country,
    required int method,
  }) async {
    final formatted = "${date.day}-${date.month}-${date.year}";
    Uri? url;

    if (lat != null && lng != null) {
      url = Uri.parse(
        "$baseUrl/timings/$formatted?latitude=$lat&longitude=$lng&method=$method",
      );
    } else if (city != null && country != null) {
      url = Uri.parse(
        "$baseUrl/timingsByCity/$formatted?city=$city&country=$country&method=$method",
      );
    }

    if (url == null) return null;

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Map<String, dynamic>.from(json["data"]["timings"]);
      } else {
        debugPrint(
            "getPrayerTimesForDate failed: ${res.statusCode} → ${res.body}");
      }
    } catch (e) {
      debugPrint("getPrayerTimesForDate error: $e");
    }

    return null;
  }

  /// 🔥 Hesaplama metodları listesi
  List<Map<String, dynamic>> getCalculationMethods(AppLocalizations l10n) {
    return [
      {
        "id": diyanetMethodId,
        "name": l10n.methodDiyanetName,
        "description": l10n.methodDiyanetDescription
      },
      {
        "id": 0,
        "name": l10n.methodMwlName,
        "description": l10n.methodMwlDescription,
      },
      {
        "id": 1,
        "name": l10n.methodEgyptianName,
        "description": l10n.methodEgyptianDescription,
      },
      {
        "id": 2,
        "name": l10n.methodKarachiName,
        "description": l10n.methodKarachiDescription,
      },
      {
        "id": 3,
        "name": l10n.methodUmmAlQuraName,
        "description": l10n.methodUmmAlQuraDescription,
      },
      {
        "id": 5,
        "name": l10n.methodMoonsightingName,
        "description": l10n.methodMoonsightingDescription,
      },
      {
        "id": 7,
        "name": l10n.methodTehranName,
        "description": l10n.methodTehranDescription,
      },
      {
        "id": 12,
        "name": l10n.methodFranceName,
        "description": l10n.methodFranceDescription,
      },
    ];
  }

  /// 🔥 Bir sonraki namazı hesapla
  String? getNextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    DateTime? next;
    String? nextName;

    for (final entry in timings.entries) {
      try {
        final parts = entry.value.split(":");
        if (parts.length != 2) continue;

        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final time = DateTime(now.year, now.month, now.day, hour, minute);

        if (time.isAfter(now)) {
          if (next == null || time.isBefore(next!)) {
            next = time;
            nextName = entry.key;
          }
        }
      } catch (e) {
        debugPrint("Parse error (${entry.key} → ${entry.value}): $e");
      }
    }

    return nextName;
  }
}
