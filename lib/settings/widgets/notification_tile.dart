import 'package:flutter/material.dart';

import '../notification_model.dart';

class NotificationTile extends StatelessWidget {
  final PrayerNotificationSetting setting;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  const NotificationTile({
    super.key,
    required this.setting,
    required this.onToggle,
    required this.onTimeTap,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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
                  setting.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  setting.isEnabled
                      ? 'Bildirim açık'
                      : 'Bildirim kapalı',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: onTimeTap,
                style: FilledButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(setting.time),
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
        ],
      ),
    );
  }
}