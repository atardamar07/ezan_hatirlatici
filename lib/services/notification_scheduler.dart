import 'dart:convert';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/prayer_times_api.dart';
import 'notification_service.dart';

class NotificationScheduler {
  final PrayerTimesApi _prayerApi = PrayerTimesApi();

  /// Uygulama açılmasa da bildirimler gelsin diye bu kadar gün ilerisi kurulur.
  /// shortcut: eklenti her bildirimde kayıtlı listenin tamamını yeniden yazar (iş, bildirim
  /// sayısının karesiyle büyür; 14 gün ≈ en çok 154 bildirim). Daha uzun süre gerekirse
  /// günlük arka plan yenilemesi (WorkManager) ekleyin.
  static const _daysAhead = 14;

  /// Bu süreçte kurulan son planın imzası: aynı gün aynı ayarlarla yeniden kurmaya gerek yok.
  /// Süreç yeniden başlayınca (ör. "zorla durdur" alarmları sildiyse) plan yine baştan kurulur.
  static String? _lastSignature;

  /// Aynı anda iki planlama birbirinin kurduğu bildirimleri silmesin diye sıraya alınır
  static Future<void> _queue = Future.value();

  /// TEST MODE: Her 1 dakikada bir bildirim gönder
  Future<void> scheduleTestNotifications() async {
    await NotificationService.cancelAllNotifications();
    debugPrint('🧪 TEST MODE: Scheduling repeating notifications every 1 minute');

    await NotificationService.scheduleRepeatingTestNotification(
      title: '🧪 Dakika bildirimi',
      body: 'Test bildirimi her dakika tetikleniyor.',
    );

    debugPrint('🧪 TEST MODE: Repeating notification scheduled (every 1 min)');
  }

  /// Kayıtlı konum için önümüzdeki günlerin bildirimlerini Ayarlar'daki tercihlere göre kurar
  Future<void> scheduleAllPrayerNotifications() {
    return _queue = _queue.then((_) => _scheduleAll()).catchError((Object e) {
      debugPrint('⚠️ Notification scheduling failed: $e');
    });
  }

  Future<void> _scheduleAll() async {
    final prefs = await SharedPreferences.getInstance();
    final locationType = prefs.getString('locationType');
    if (locationType == null) {
      debugPrint('⚠️ No location type set, skipping notification scheduling');
      return;
    }

    final method = await _prayerApi.getSavedMethodOrDefault();
    final lat = locationType == 'location' ? prefs.getDouble('latitude') : null;
    final lng = locationType == 'location' ? prefs.getDouble('longitude') : null;
    final enabled = _enabledPrayers(prefs);
    final minutesBefore = prefs.getInt('preAlertMinutes') ?? 10;
    final loc = _localizations();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(now.year, now.month, now.day + _daysAhead - 1);

    // Konum ~1 km'ye yuvarlanır: GPS her açılışta biraz oynar ama vakitler değişmez
    final signature = [
      locationType, lat?.toStringAsFixed(2), lng?.toStringAsFixed(2),
      prefs.getString('selectedCity'), prefs.getString('selectedCountry'),
      method, enabled, minutesBefore, loc.localeName, today,
    ].join('|');
    if (signature == _lastSignature) return;

    // Aylık takvim tek istekte gelir; aralık ay sonuna taşarsa sonraki ay da alınır
    final days = <DateTime, Map<String, dynamic>>{};
    for (final month in {
      DateTime(today.year, today.month),
      DateTime(lastDay.year, lastDay.month),
    }) {
      final data = await _prayerApi.getMonthlyPrayerTimes(
        month: month.month,
        year: month.year,
        lat: lat,
        lng: lng,
        city: prefs.getString('selectedCity'),
        country: prefs.getString('selectedCountry'),
        method: method,
      );
      if (data != null) days.addAll(data);
    }
    // Takvim tüm ayı döndürür; yalnızca önümüzdeki günler kurulur (Android'de alarm sınırı ~500)
    days.removeWhere((day, _) => day.isBefore(today) || day.isAfter(lastDay));

    if (days.isEmpty) {
      // İnternet yoksa eskileri silme; önceki planlama geçerli kalsın
      debugPrint('⚠️ Failed to get prayer timings, keeping existing notifications');
      return;
    }

    final plan = planNotifications(
      days: days,
      enabled: enabled,
      minutesBefore: minutesBefore,
      now: now,
      loc: loc,
    );

    await NotificationService.cancelAllNotifications();
    for (final n in plan) {
      await NotificationService.scheduleNotification(
        title: n.title,
        body: n.body,
        scheduledTime: n.time,
      );
    }
    _lastSignature = signature;

    debugPrint('🔔 Notification scheduling complete. Total scheduled: ${plan.length}');
  }

  /// Ayarlar ekranındaki vakit anahtarları; varsayılanlar oradakiyle aynı olmalı
  Map<String, bool> _enabledPrayers(SharedPreferences prefs) {
    final enabled = {
      'imsak': false,
      'sabah': true,
      'ogle': true,
      'ikindi': true,
      'aksam': true,
      'yatsi': true,
    };
    final saved = prefs.getString('prayerNotificationSettings');
    if (saved == null) return enabled;

    try {
      for (final item in jsonDecode(saved) as List) {
        enabled[item['key'] as String] = item['isEnabled'] == true;
      }
    } catch (e) {
      debugPrint('⚠️ Invalid notification settings: $e');
    }
    return enabled;
  }

  /// Bildirim metni ekran dışında üretildiği için dil cihaz ayarından seçilir
  AppLocalizations _localizations() {
    final languageCode = PlatformDispatcher.instance.locale.languageCode;
    final locale = AppLocalizations.supportedLocales.firstWhere(
      (l) => l.languageCode == languageCode,
      orElse: () => const Locale('en'),
    );
    return lookupAppLocalizations(locale);
  }
}

/// Kurulacak bildirimler (saat sırasına göre). Ağdan ve eklentiden bağımsız; testte doğrudan çağrılır.
/// [days]: gün (yerel gece yarısı) → API vakitleri; [enabled]: Ayarlar ekranındaki vakit anahtarları.
List<({DateTime time, String title, String body})> planNotifications({
  required Map<DateTime, Map<String, dynamic>> days,
  required Map<String, bool> enabled,
  required int minutesBefore,
  required DateTime now,
  required AppLocalizations loc,
}) {
  // Ayarlar anahtarı → (API anahtarı, bildirimde görünen ad)
  final prayers = {
    'imsak': ('Fajr', loc.fajr),
    'ogle': ('Dhuhr', loc.dhuhr),
    'ikindi': ('Asr', loc.asr),
    'aksam': ('Maghrib', loc.maghrib),
    'yatsi': ('Isha', loc.isha),
  };

  final plan = <({DateTime time, String title, String body})>[];
  void add(DateTime? time, String title, String body) {
    if (time != null && time.isAfter(now)) plan.add((time: time, title: title, body: body));
  }

  for (final MapEntry(key: day, value: timings) in days.entries) {
    // Sabah: ana sayfadaki gibi güneş doğmadan 1 saat önce
    if (enabled['sabah'] == true) {
      add(
        _parseTime(timings['Sunrise'], day)?.subtract(const Duration(hours: 1)),
        loc.prayerNotificationTitle,
        loc.prayerNotificationBody(loc.sabah),
      );
    }

    for (final entry in prayers.entries) {
      if (enabled[entry.key] != true) continue;
      final (apiKey, name) = entry.value;
      final time = _parseTime(timings[apiKey], day);

      if (minutesBefore > 0) {
        add(
          time?.subtract(Duration(minutes: minutesBefore)),
          loc.reminderNotificationTitle,
          loc.reminderNotificationBody(minutesBefore, name),
        );
      }
      add(time, loc.prayerNotificationTitle, loc.prayerNotificationBody(name));
    }
  }

  return plan..sort((a, b) => a.time.compareTo(b.time));
}

/// "05:13" veya takvim API'sinin "05:13 (+03)" biçiminden o günün saatini üretir
DateTime? _parseTime(Object? raw, DateTime day) {
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw is String ? raw : '');
  if (match == null) return null;

  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
  );
}
