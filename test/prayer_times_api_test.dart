import 'dart:convert';

import 'package:ezan_hatirlatici/services/prayer_times_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('aylık takvim: tarihler anahtar olur, saatlerdeki saat dilimi eki atılır', () async {
    // Aladhan takvim ucunun gerçek biçimi: tarih "gg-aa-yyyy", saat "12:53 (+03)"
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'data': [
              {
                'date': {
                  'gregorian': {'date': '01-11-2026'},
                  'hijri': {'day': '22', 'month': {'number': 5}, 'year': '1448'},
                },
                'timings': {'Sunrise': '06:58 (+03)', 'Dhuhr': '12:53 (+03)'},
              },
              {
                'date': {'gregorian': {'date': '02-11-2026'}},
                'timings': {'Sunrise': '06:59 (+03)', 'Dhuhr': '12:53 (+03)'},
              },
            ],
          }),
          200,
        ));

    final result = await http.runWithClient(
      () => PrayerTimesApi().getMonthlyPrayerTimes(
          month: 11, year: 2026, lat: 41.0, lng: 29.0, method: 13),
      () => client,
    );

    expect(result!.keys, [DateTime(2026, 11, 1), DateTime(2026, 11, 2)]);
    expect(result[DateTime(2026, 11, 1)], {
      'Sunrise': '06:58',
      'Dhuhr': '12:53',
      'HijriDay': 22,
      'HijriMonth': 5,
      'HijriYear': 1448,
    });
    expect(result[DateTime(2026, 11, 2)]!.containsKey('HijriDay'), isFalse);
  });
}
