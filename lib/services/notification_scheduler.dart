import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_times_api.dart';
import 'notification_service.dart';

class NotificationScheduler {
  final PrayerTimesApi _prayerApi = PrayerTimesApi();

  /// TEST MODE: Her 2 dakikada bir bildirim gönder
  Future<void> scheduleTestNotifications() async {
    await NotificationService.cancelAllNotifications();
    debugPrint('🧪 TEST MODE: Scheduling notifications every 2 minutes');

    final now = DateTime.now();
    
    // 5 test bildirimi planla (2, 4, 6, 8, 10 dakika sonra)
    for (int i = 1; i <= 5; i++) {
      final notificationTime = now.add(Duration(minutes: i * 2));
      
      await NotificationService.scheduleNotification(
        title: '🧪 Test Bildirimi #$i',
        body: 'Bu bir test bildirimidir. Ezan sesi çalacak!',
        scheduledTime: notificationTime,
      );
      
      debugPrint('✅ Test notification #$i scheduled for: $notificationTime');
    }
    
    debugPrint('🧪 TEST MODE: Scheduled 5 test notifications (every 2 min)');
  }

  /// Tüm namaz vakitleri için hatırlatıcı ve vakit bildirimlerini planlar
  Future<void> scheduleAllPrayerNotifications() async {
    await NotificationService.cancelAllNotifications();
    debugPrint('🔔 Starting notification scheduling...');

    final prefs = await SharedPreferences.getInstance();
    final locationType = prefs.getString('locationType');

    if (locationType == null) {
      debugPrint('⚠️ No location type set, skipping notification scheduling');
      return;
    }

    Map<String, dynamic>? timings;
    if (locationType == 'location') {
      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');
      if (lat != null && lng != null) {
        timings = await _prayerApi.getPrayerTimesByLocation(
            lat, lng, prefs.getInt('calculationMethod') ?? 0);
      }
    } else if (locationType == 'city') {
      final city = prefs.getString('selectedCity');
      final country = prefs.getString('selectedCountry');
      if (city != null && country != null) {
        timings = await _prayerApi.getPrayerTimesByCity(
            city, country, prefs.getInt('calculationMethod') ?? 0);
      }
    }

    if (timings == null) {
      debugPrint('⚠️ Failed to get prayer timings');
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Kullanıcı ayarı: kaç dakika önce hatırlatılsın
    final minutesBefore = prefs.getInt('notificationMinutesBefore') ?? 15;

    // Özel Fajr zamanlaması için Sunrise (Güneş) vaktini al
    final sunriseTimeStr = timings['Sunrise'] as String?;
    DateTime? fajrNotificationTime;
    
    if (sunriseTimeStr != null) {
      try {
        final sunriseTime = _parseTime(sunriseTimeStr, today);
        fajrNotificationTime = sunriseTime.subtract(const Duration(minutes: 60));
        debugPrint('☀️ Fajr notification scheduled for: $fajrNotificationTime (60 min before Sunrise at $sunriseTime)');
      } catch (e) {
        debugPrint('⚠️ Failed to calculate Fajr notification time: $e');
      }
    }

    int scheduledCount = 0;
    
    for (final entry in timings.entries) {
      if (entry.key == 'Sunrise') continue; // Güneş için bildirim yok

      // Özel Fajr işleme
      if (entry.key == 'Fajr' && fajrNotificationTime != null) {
        if (fajrNotificationTime.isAfter(now)) {
          await NotificationService.scheduleNotification(
            title: '☀️ Sabah Namazı Hatırlatıcı',
            body: 'Sabah namazı için 60 dakika kaldı (Güneş doğmadan önce)',
            scheduledTime: fajrNotificationTime,
          );
          scheduledCount++;
          debugPrint('✅ Scheduled Fajr notification at $fajrNotificationTime');
        } else {
          debugPrint('⏭️ Skipped Fajr notification (time already passed)');
        }
        continue; // Fajr için normal işlemeyi atla
      }

      try {
        final prayerTime = _parseTime(entry.value as String, today);

        // Hatırlatıcı bildirimi
        final reminderTime =
        prayerTime.subtract(Duration(minutes: minutesBefore));
        if (reminderTime.isAfter(now) && minutesBefore > 0) {
          await NotificationService.scheduleNotification(
            title: '⏰ Namaz Hatırlatıcı',
            body:
            '${_getTurkishPrayerName(entry.key)} vakti $minutesBefore dakika sonra',
            scheduledTime: reminderTime,
          );
          scheduledCount++;
          debugPrint('✅ Scheduled ${entry.key} reminder at $reminderTime');
        }

        // Vakit girince bildirimi
        if (prayerTime.isAfter(now)) {
          await NotificationService.scheduleNotification(
            title: '🕌 Namaz Vakti',
            body:
            '${_getTurkishPrayerName(entry.key)} vakti geldi. Haydi namaza!',
            scheduledTime: prayerTime,
          );
          scheduledCount++;
          debugPrint('✅ Scheduled ${entry.key} prayer time at $prayerTime');
        }
      } catch (e) {
        debugPrint('⚠️ Notification scheduling skipped (${entry.key} → ${entry.value}): $e');
      }
    }
    
    debugPrint('🔔 Notification scheduling complete. Total scheduled: $scheduledCount');
  }

  DateTime _parseTime(String timeStr, DateTime baseDate) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);

    if (match == null) {
      throw FormatException('Invalid time format: $timeStr');
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  String _getTurkishPrayerName(String key) {
    switch (key) {
      case 'Fajr': return 'İmsak';
      case 'Dhuhr': return 'Öğle';
      case 'Asr': return 'İkindi';
      case 'Maghrib': return 'Akşam';
      case 'Isha': return 'Yatsı';
      default: return key;
    }
  }
}