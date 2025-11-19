import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'prayer_channel_id';
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
    tz.initializeTimeZones();

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Android 13 (API 33) ve üzeri için hem bildirim hem de exact alarm izinlerini iste
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      final canScheduleExact =
        await androidPlugin.canScheduleExactNotifications();

      if (canScheduleExact != true) {
        await androidPlugin.requestExactAlarmsPermission();
      }
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

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final details = _buildNotificationDetails();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 10000,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // ❌ KALDIRILDI: uiLocalNotificationDateInterpretation
    );
  }

  static Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancelAll();
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
}