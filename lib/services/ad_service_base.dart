abstract class AdServiceBase {
  Future<void> initialize({bool loadAds = true});
  Future<void> loadInterstitialAd();
  void showInterstitialAd();
  Future<bool> shouldShowAd();
  Future<AdStatus> getStatus();
  void dispose();

  /// GDPR bölgesinde kullanıcının reklam onayını değiştirebileceği giriş noktası gerekli mi
  Future<bool> isPrivacyOptionsRequired();
  Future<void> showPrivacyOptions();
}

class AdStatus {
  final bool initialized;
  final bool interstitialReady;
  final bool interstitialShowing;

  const AdStatus({
    required this.initialized,
    required this.interstitialReady,
    required this.interstitialShowing,
  });
}