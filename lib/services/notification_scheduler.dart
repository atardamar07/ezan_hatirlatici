import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_times_api.dart';
import 'notification_service.dart';

class NotificationScheduler {
  final PrayerTimesApi _prayerApi = PrayerTimesApi();

  /// Tüm namaz vakitleri için hatırlatıcı ve vakit bildirimlerini planlar
  Future<void> scheduleAllPrayerNotifications() async {
    await NotificationService.cancelAllNotifications();

    final prefs = await SharedPreferences.getInstance();
    final locationType = prefs.getString('locationType');

    if (locationType == null) return;

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

    if (timings == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Kullanıcı ayarı: kaç dakika önce hatırlatılsın
    final minutesBefore = prefs.getInt('notificationMinutesBefore') ?? 15;

    for (final entry in timings.entries) {
      if (entry.key == 'Sunrise') continue; // Güneş için bildirim yok

      final time = _parseTime(entry.value as String);
      final prayerTime = DateTime(
          today.year, today.month, today.day, time.hour, time.minute);

      // Hatırlatıcı bildirimi
      final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
      if (reminderTime.isAfter(now) && minutesBefore > 0) {
        await NotificationService.scheduleNotification(
          title: '⏰ Namaz Hatırlatıcı',
          body: '${_getTurkishPrayerName(entry.key)} vakti ${minutesBefore} dakika sonra',
          scheduledTime: reminderTime,
        );
      }

      // Vakit girince bildirimi
      if (prayerTime.isAfter(now)) {
        await NotificationService.scheduleNotification(
          title: '🕌 Namaz Vakti',
          body: '${_getTurkishPrayerName(entry.key)} vakti geldi. Haydi namaza!',
          scheduledTime: prayerTime,
        );
      }
    }
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
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