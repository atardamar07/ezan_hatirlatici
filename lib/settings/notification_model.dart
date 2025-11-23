import 'package:flutter/material.dart';

class PrayerNotificationSetting {
  final String key;
  final String title;
  bool isEnabled;
  TimeOfDay time;

  PrayerNotificationSetting({
    required this.key,
    required this.title,
    required this.isEnabled,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'isEnabled': isEnabled,
    'hour': time.hour,
    'minute': time.minute,
  };

  PrayerNotificationSetting copyWith({
    bool? isEnabled,
    TimeOfDay? time,
  }) {
    return PrayerNotificationSetting(
      key: key,
      title: title,
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
    );
  }

  static PrayerNotificationSetting fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSetting(
      key: json['key'] as String,
      title: json['title'] as String,
      isEnabled: json['isEnabled'] as bool,
      time: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
    );
  }
}