import 'dart:async';
import 'package:flutter/material.dart';

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
  final ValueNotifier<String> _remainingText = ValueNotifier('Hesaplanıyor...');
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

  void _calculateRemaining() {
    try {
      final now = DateTime.now();
      final reg = RegExp(r'(\d{1,2}:\d{2})');
      final match = reg.firstMatch(widget.time);
      String timePart = match?.group(1) ?? widget.time;

      final parts = timePart.split(':');
      if (parts.length < 2) {
        _remainingText.value = "Zaman bilgisi geçersiz";
        return;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      Duration diff = prayerTime.difference(now);
      final isPast = diff.isNegative;

      if (isPast) {
        _remainingText.value = "🕌 Vakit girdi";
        _vakitGirdi.value = true;

        // Bildirim tetikle (sadece bir kere)
        if (!_ezanPlayed) {
          _ezanPlayed = true;
          // Burada NotificationService.showNotification çağrılabilir
          // ancak scheduler zaten planladı, burası sadece UI için
        }
      } else {
        _vakitGirdi.value = false;
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;

        if (hours > 0) {
          _remainingText.value = "⏳ $hours sa ${minutes.toString().padLeft(2, '0')} dk kaldı";
        } else if (minutes > 0) {
          _remainingText.value = "⏳ $minutes dk ${seconds.toString().padLeft(2, '0')} sn kaldı";
        } else {
          _remainingText.value = "⏳ $seconds sn kaldı";
        }
      }
    } catch (e) {
      _remainingText.value = "Zaman bilgisi geçersiz";
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _remainingText.dispose();
    _vakitGirdi.dispose();
    super.dispose();
  }

  String _getTurkishPrayerName(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr': return 'İmsak';
      case 'sunrise': return 'Güneş';
      case 'dhuhr': return 'Öğle';
      case 'asr': return 'İkindi';
      case 'maghrib': return 'Akşam';
      case 'isha': return 'Yatsı';
      default: return prayerName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final turkishName = _getTurkishPrayerName(widget.prayerName);
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
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            title: Text(
              turkishName,
              style: TextStyle(
                color: widget.isNextPrayer ? Colors.white : Colors.amber,
                fontSize: 20,
                fontWeight: widget.isNextPrayer ? FontWeight.bold : FontWeight.normal,
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
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: widget.isNextPrayer
                ? const Icon(Icons.access_time, color: Colors.white, size: 24)
                : null,
          ),
        );
      },
    );
  }
}