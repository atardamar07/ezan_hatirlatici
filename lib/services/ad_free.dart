import 'package:shared_preferences/shared_preferences.dart';

/// Reklamsız kullanım hakkı: ömür boyu lisans (tek seferlik satın alma) ya da
/// ödüllü reklam izleyerek kazanılan süre (4 reklam = 12 saat).
class AdFree {
  static const adsPerReward = 4;
  static const rewardDuration = Duration(hours: 12);

  static const _lifetimeKey = 'isAdFree'; // eski sürümlerle aynı anahtar
  static const _untilKey = 'adFreeUntil';
  static const _countKey = 'rewardedAdsWatched';

  static bool hasLifetime(SharedPreferences prefs) =>
      prefs.getBool(_lifetimeKey) ?? false;

  static DateTime? until(SharedPreferences prefs) {
    final ms = prefs.getInt(_untilKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static bool isActive(SharedPreferences prefs, DateTime now) =>
      hasLifetime(prefs) || (until(prefs)?.isAfter(now) ?? false);

  static int watchedCount(SharedPreferences prefs) => prefs.getInt(_countKey) ?? 0;

  /// Bir ödüllü reklam tamamlandı: 4'e ulaşınca 12 saat eklenir (süre bitmediyse
  /// kalanın üstüne) ve sayaç sıfırlanır.
  static Future<void> recordRewardedAd(SharedPreferences prefs, DateTime now) async {
    final count = watchedCount(prefs) + 1;
    if (count < adsPerReward) {
      await prefs.setInt(_countKey, count);
      return;
    }
    final current = until(prefs);
    final start = current != null && current.isAfter(now) ? current : now;
    await prefs.setInt(_untilKey, start.add(rewardDuration).millisecondsSinceEpoch);
    await prefs.setInt(_countKey, 0);
  }

  static Future<void> grantLifetime(SharedPreferences prefs) =>
      prefs.setBool(_lifetimeKey, true);
}
