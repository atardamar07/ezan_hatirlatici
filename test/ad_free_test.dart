import 'package:ezan_hatirlatici/services/ad_free.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 11, 23, 10, 0);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('4 ödüllü reklam 12 saat reklamsızlık verir, sayaç sıfırlanır', () async {
    final prefs = await SharedPreferences.getInstance();

    for (var i = 0; i < 3; i++) {
      await AdFree.recordRewardedAd(prefs, now);
    }
    expect(AdFree.watchedCount(prefs), 3);
    expect(AdFree.isActive(prefs, now), isFalse);

    await AdFree.recordRewardedAd(prefs, now);
    expect(AdFree.watchedCount(prefs), 0);
    expect(AdFree.isActive(prefs, now.add(const Duration(hours: 11, minutes: 59))), isTrue);
    expect(AdFree.isActive(prefs, now.add(const Duration(hours: 12, minutes: 1))), isFalse);
  });

  test('süre bitmeden 4 reklam daha izlenirse süre kalanın üstüne eklenir', () async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < 4; i++) {
      await AdFree.recordRewardedAd(prefs, now);
    }
    final later = now.add(const Duration(hours: 2));
    for (var i = 0; i < 4; i++) {
      await AdFree.recordRewardedAd(prefs, later);
    }
    expect(AdFree.until(prefs), now.add(const Duration(hours: 24)));
  });

  test('ömür boyu lisans süresiz geçerli', () async {
    final prefs = await SharedPreferences.getInstance();
    await AdFree.grantLifetime(prefs);
    expect(AdFree.isActive(prefs, now.add(const Duration(days: 3650))), isTrue);
  });
}
