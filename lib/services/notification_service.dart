import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'prayer_channel_id_v2';
  static const _androidChannelName = 'Namaz Bildirimleri';
  static const _androidChannelDescription =
      'Namaz vakitleri ve hatırlatıcıları';

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // ✅ Timezone ayarlarını yap
    tz.initializeTimeZones();
    try {
      final dynamic timeZoneResult = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = _normalizeTimezoneName(timeZoneResult);

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('🌍 Local Timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ Failed to set local timezone: $e');
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const androidChannel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('ezan'),
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(androidChannel);
      debugPrint('📢 Notification channel created: $_androidChannelId');

      await androidPlugin.requestNotificationsPermission();

      final canScheduleExact =
          await androidPlugin.canScheduleExactNotifications();

      if (canScheduleExact != true) {
        await androidPlugin.requestExactAlarmsPermission();
      }

      debugPrint('📢 Notification permissions requested');
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      debugPrint('Web notification: $title - $body');
      return;
    }

    final details = _buildNotificationDetails();

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 10000,
      title,
      body,
      details,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) {
      debugPrint('Web scheduled notification: $title - $body at $scheduledTime');
      return;
    }

    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);
    
    debugPrint('🔔 Scheduling for: $tzScheduledTime (Local: ${tz.local.name})');

    final details = _buildNotificationDetails();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 10000,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<NotificationStatus> getStatus() async {
    if (kIsWeb) {
      return const NotificationStatus(
        notificationsEnabled: true,
        exactAlarmsEnabled: true,
        soundEnabled: true,
      );
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final notificationsEnabled =
        await androidPlugin?.areNotificationsEnabled() ?? true;
    final exactAlarms =
        await androidPlugin?.canScheduleExactNotifications() ?? true;

    return NotificationStatus(
      notificationsEnabled: notificationsEnabled,
      exactAlarmsEnabled: exactAlarms,
      soundEnabled: notificationsEnabled,
    );
  }

  static NotificationDetails _buildNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('ezan'),
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'ezan.mp3',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Test bildirimi için her dakika tekrarlayan bir bildirim planlar.
  static Future<void> scheduleRepeatingTestNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      debugPrint('Web repeating notification: $title - $body');
      return;
    }

    final details = _buildNotificationDetails();

    await flutterLocalNotificationsPlugin.periodicallyShow(
      9999,
      title,
      body,
      RepeatInterval.everyMinute,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Normalizes timezone strings to a format accepted by the `timezone` package.
  ///
  /// Some platforms return a wrapped string like
  /// `TimezoneInfo(Europe/Istanbul, (locale: tr_TR, name: GMT+03:00))`.
  /// This method extracts the actual timezone name (e.g. `Europe/Istanbul`).
  static String _normalizeTimezoneName(dynamic timeZoneResult) {
    final raw = timeZoneResult.toString().trim();
    final match = RegExp(r'TimezoneInfo\(([^,]+)').firstMatch(raw);
    if (match != null) {
      return match.group(1)!;
    }
    return raw;
  }
}

class NotificationStatus {
  final bool notificationsEnabled;
  final bool exactAlarmsEnabled;
  final bool soundEnabled;

  const NotificationStatus({
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
    required this.soundEnabled,
  });
}