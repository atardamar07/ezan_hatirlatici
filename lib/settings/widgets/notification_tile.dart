import 'package:flutter/material.dart';

import '../notification_model.dart';

class NotificationTile extends StatelessWidget {
  final PrayerNotificationSetting setting;
  final ValueChanged<bool> onToggle;
  final String enabledLabel;
  final String disabledLabel;
  final String? titleOverride;

  const NotificationTile({
    super.key,
    required this.setting,
    required this.onToggle,
    required this.enabledLabel,
    required this.disabledLabel,
    this.titleOverride,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleOverride ?? setting.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  setting.isEnabled ? enabledLabel : disabledLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: setting.isEnabled,
            onChanged: onToggle,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}