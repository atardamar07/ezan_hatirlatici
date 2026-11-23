import 'package:ezan_hatirlatici/l10n/app_localizations.dart';
import 'package:ezan_hatirlatici/services/notification_scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final loc = lookupAppLocalizations(const Locale('tr'));
  final today = DateTime(2026, 3, 10);
  final tomorrow = DateTime(2026, 3, 11);
  // Takvim API'si vakitleri "05:13 (+03)" biçiminde, namaz dışı alanlarla birlikte döndürür
  Map<String, dynamic> timings() => {
        'Fajr': '05:30 (+03)',
        'Sunrise': '07:00 (+03)',
        'Dhuhr': '13:00 (+03)',
        'Asr': '16:00 (+03)',
        'Sunset': '18:40 (+03)',
        'Maghrib': '18:45 (+03)',
        'Isha': '20:15 (+03)',
        'Imsak': '05:20 (+03)',
        'Midnight': '00:50 (+03)',
      };
  const defaults = {
    'imsak': false,
    'sabah': true,
    'ogle': true,
    'ikindi': true,
    'aksam': true,
    'yatsi': true,
  };

  test('geçmiş vakitler atlanır, yarın tümü kurulur, namaz dışı alanlar yok sayılır', () {
    final plan = planNotifications(
      days: {today: timings(), tomorrow: timings()},
      enabled: defaults,
      minutesBefore: 10,
      now: DateTime(2026, 3, 10, 12, 0),
      loc: loc,
    );

    // Bugün: öğle/ikindi/akşam/yatsı × (hatırlatma + vakit) = 8; yarın: + sabah = 9
    expect(plan, hasLength(17));
    expect(plan.first.time, DateTime(2026, 3, 10, 12, 50));
    expect(plan.first.body, 'Öğle vaktine 10 dakika kaldı');
    expect(plan.first.adhan, isFalse, reason: 'ön uyarı normal bildirim sesiyle çalmalı');
    expect(plan[1].body, 'Öğle vakti geldi. Haydi namaza!');
    expect(plan[1].adhan, isTrue, reason: 'vakit girince ezan okunmalı');
    // Yarının ilki: güneşten 1 saat önce "Sabah"
    expect(plan[8].time, DateTime(2026, 3, 11, 6, 0));
    expect(plan[8].body, 'Sabah vakti geldi. Haydi namaza!');
    expect(plan.any((n) => n.time.hour == 0 || n.time.hour == 18 && n.time.minute == 40), isFalse);
  });

  test('kapatılan vakit ve kapalı ön uyarı kurulmaz', () {
    final plan = planNotifications(
      days: {tomorrow: timings()},
      enabled: {...defaults, 'aksam': false, 'imsak': true},
      minutesBefore: 0,
      now: DateTime(2026, 3, 10, 23, 0),
      loc: loc,
    );

    expect(plan.map((n) => '${n.time.hour}:${n.time.minute}'),
        ['5:30', '6:0', '13:0', '16:0', '20:15']);
  });
}
