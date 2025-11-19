import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrayerCard extends StatefulWidget {
  final String prayerName;
  final String time;
  final bool isNextPrayer;

  const PrayerCard({
    super.key,
    required this.prayerName,
    required this.time,
    this.isNextPrayer = false,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  late Timer _timer;
  final ValueNotifier<String> _remainingText = ValueNotifier('...');
  final ValueNotifier<bool> _vakitGirdi = ValueNotifier(false);
  bool _ezanPlayed = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  @override
  void didUpdateWidget(PrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time) {
      _ezanPlayed = false;
      _calculateRemaining();
    }
  }

  /// 🔥 DİL DESTEKLİ NAMAZ İSMİ
  String _localizedPrayerName(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;

    switch (key.toLowerCase()) {
      case "fajr":
        return loc.fajr;
      case "dhuhr":
        return loc.dhuhr;
      case "asr":
        return loc.asr;
      case "maghrib":
        return loc.maghrib;
      case "isha":
        return loc.isha;

    /// YARIN IMSAK
      case "tomorrow_fajr":
        return loc.tomorrowFajr;

      default:
        return key;
    }
  }

  void _calculateRemaining() {
    try {
      final nowUtc = DateTime.now().toUtc();
      final locationOffset = _extractOffset(widget.time);
      final nowAtLocation = nowUtc.add(locationOffset);
      final reg = RegExp(r'(\d{1,2}:\d{2})');
      final match = reg.firstMatch(widget.time);
      final timePart = match?.group(1) ?? widget.time;

      final parts = timePart.split(':');
      if (parts.length < 2) {
        _remainingText.value = "Invalid time";
        return;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Zamana konum saat dilimi farkını da uygulayarak UTC tabanlı hesapla
      final prayerTimeUtc = DateTime.utc(
        nowAtLocation.year,
        nowAtLocation.month,
        nowAtLocation.day,
        hour,
        minute,
      ).subtract(locationOffset);

      Duration diff = prayerTimeUtc.difference(nowUtc);

      if (diff.isNegative) {
        _remainingText.value = "🕌 ${AppLocalizations.of(context)!.prayerTimeEntered}";
        _vakitGirdi.value = true;
      } else {
        _vakitGirdi.value = false;
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        final s = diff.inSeconds % 60;

        if (h > 0) {
          _remainingText.value = "⏳ $h h ${m.toString().padLeft(2, '0')} m";
        } else if (m > 0) {
          _remainingText.value = "⏳ $m m ${s.toString().padLeft(2, '0')} s";
        } else {
          _remainingText.value = "⏳ $s s";
        }
      }
    } catch (_) {
      _remainingText.value = "Invalid time";
    }
  }

  Duration _extractOffset(String rawTime) {
    final match = RegExp(r'([+-])(\d{1,2}):?(\d{2})?').firstMatch(rawTime);

    if (match != null) {
      final sign = match.group(1) == '-' ? -1 : 1;
      final hours = int.tryParse(match.group(2) ?? '') ?? 0;
      final minutes = int.tryParse(match.group(3) ?? '') ?? 0;

      return Duration(minutes: sign * (hours * 60 + minutes));
    }

    return DateTime.now().timeZoneOffset;
  }

  @override
  void dispose() {
    _timer.cancel();
    _remainingText.dispose();
    _vakitGirdi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _localizedPrayerName(context, widget.prayerName);
    final isActive = widget.isNextPrayer && !_vakitGirdi.value;

    return ValueListenableBuilder<String>(
      valueListenable: _remainingText,
      builder: (context, remainingText, _) {
        return Card(
          color: widget.isNextPrayer
              ? Colors.teal.shade800
              : const Color(0xFF2C2C38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: widget.isNextPrayer
                ? BorderSide(color: Colors.teal.shade400, width: 2)
                : BorderSide.none,
          ),
          elevation: widget.isNextPrayer ? 8 : 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 20),
            title: Text(
              name,
              style: TextStyle(
                color: widget.isNextPrayer ? Colors.white : Colors.amber,
                fontSize: 20,
                fontWeight:
                widget.isNextPrayer ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remainingText,
                  style: TextStyle(
                    color: isActive ? Colors.white70 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            trailing: widget.isNextPrayer
                ? const Icon(Icons.access_time,
                color: Colors.white, size: 24)
                : null,
          ),
        );
      },
    );
  }
}
