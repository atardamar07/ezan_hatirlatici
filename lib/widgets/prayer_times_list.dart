import 'package:flutter/material.dart';

/// Günün beş vakti (Sabah, Öğle, İkindi, Akşam, Yatsı) simgeleriyle; sıradaki vakit vurgulanır.
/// Ana sayfa ve takvim aynı görünümü kullanır.
class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({super.key, required this.rows, this.highlight});

  /// Sırayla (ad, "SS:DD")
  final List<(String, String)> rows;

  /// Vurgulanacak satır (sıradaki vakit); yoksa null
  final int? highlight;

  static const _icons = [
    Icons.wb_twilight,
    Icons.wb_sunny,
    Icons.light_mode_outlined,
    Icons.brightness_4_outlined,
    Icons.nightlight_round,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: i == highlight ? scheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _icons[i % _icons.length],
                  size: 20,
                  color: i == highlight ? scheme.onPrimaryContainer : scheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: i == highlight ? FontWeight.w700 : null,
                      color: i == highlight ? scheme.onPrimaryContainer : null,
                    ),
                  ),
                ),
                Text(
                  rows[i].$2,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: i == highlight ? scheme.onPrimaryContainer : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
