import 'ad_service_base.dart';

class AdServicePlatform implements AdServiceBase {
  @override
  Future<void> initialize({bool loadAds = true}) async {}

  @override
  Future<void> loadInterstitialAd() async {}

  @override
  void showInterstitialAd() {}

  @override
  Future<bool> shouldShowAd() async => false;

  @override
  Future<AdStatus> getStatus() async {
    return const AdStatus(
      initialized: false,
      interstitialReady: false,
      interstitialShowing: false,
    );
  }

  @override
  void dispose() {}
}
