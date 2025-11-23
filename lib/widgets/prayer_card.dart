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
      final now = DateTime.now();
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

      DateTime prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      final offset = _extractExplicitOffset(widget.time);
      if (offset != null) {
        final localOffset = now.timeZoneOffset;
        prayerTime = prayerTime.subtract(offset).add(localOffset);
      }

      final diff = prayerTime.difference(now);

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

  Duration? _extractExplicitOffset(String rawTime) {
    final match = RegExp(r'([+-])(\d{1,2}):?(\d{2})?').firstMatch(rawTime);

    if (match != null) {
      final sign = match.group(1) == '-' ? -1 : 1;
      final hours = int.tryParse(match.group(2) ?? '') ?? 0;
      final minutes = int.tryParse(match.group(3) ?? '') ?? 0;

      return Duration(minutes: sign * (hours * 60 + minutes));
    }

    return null;
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
        return Stack(
            clipBehavior: Clip.none,
            children: [
        Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: widget.isNextPrayer
        ? [Colors.teal.shade700, Colors.teal.shade400]
            : [const Color(0xFF1F1F2C), const Color(0xFF161623)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
        BoxShadow(
        color: widget.isNextPrayer
        ? Colors.teal.shade900.withOpacity(0.4)
            : Colors.black.withOpacity(0.35),
        blurRadius: 12,
        offset: const Offset(0, 8),
        ),
        ],
        border: widget.isNextPrayer
        ? Border.all(
        color: Colors.tealAccent.withOpacity(0.6),
        width: 1.5,
        )
            : null,
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12),
        ),
        child: Icon(
        _prayerIcon(context),
        color: Colors.white,
        size: 28,
        ),
        ),
        const SizedBox(width: 16),
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
        name,
        style: TextStyle(
        color: widget.isNextPrayer
        ? Colors.white
            : Colors.amber.shade200,
        fontSize: 20,
        fontWeight: widget.isNextPrayer
        ? FontWeight.bold
            : FontWeight.w600,
        ),
        ),
        const SizedBox(height: 6),
        Text(
        widget.time,
        style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
        ),
        ),
        const SizedBox(height: 8),
        Text(
        remainingText,
        style: TextStyle(
        color: isActive ? Colors.white : Colors.white70,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        ),
        ),
        ],
        ),
        ),
        if (widget.isNextPrayer)
        const Icon(Icons.chevron_right, color: Colors.white70),
        ],
              ),
            ),
        if (widget.isNextPrayer)
        Positioned(
        top: 6,
        right: 18,
        child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
        BoxShadow(
        color: Colors.tealAccent.withOpacity(0.35),
        blurRadius: 8,
        offset: const Offset(0, 3),
        )
        ],
                  ),
        child: Text(
        'Bir sonraki vakte kalan süre',
        style: TextStyle(
        color: Colors.teal.shade900,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        ),
                  ),
                ),
        ),
            ],
        );
      },
    );
  }
  IconData _prayerIcon(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final key = widget.prayerName.toLowerCase();

    if (key == loc.fajr.toLowerCase() || key.contains('fajr') || key.contains('imsak')) {
      return Icons.nightlight_round;
    }
    if (key == loc.dhuhr.toLowerCase() || key.contains('dhuhr') || key.contains('öğle')) {
      return Icons.wb_sunny_outlined;
    }
    if (key == loc.asr.toLowerCase() || key.contains('asr') || key.contains('ikindi')) {
      return Icons.sunny_snowing;
    }
    if (key == loc.maghrib.toLowerCase() || key.contains('maghrib') || key.contains('akşam')) {
      return Icons.nightlight_outlined;
    }
    if (key == loc.isha.toLowerCase() || key.contains('isha') || key.contains('yatsı')) {
      return Icons.dark_mode_rounded;
    }

    return Icons.access_time_rounded;
  }
}


