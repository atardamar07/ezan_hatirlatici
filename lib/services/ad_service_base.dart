import 'package:flutter/material.dart';

abstract class AdServiceBase {
  Future<void> initialize({bool loadAds = true});
  Widget buildBannerAd();
  Future<void> loadInterstitialAd();
  void showInterstitialAd();
  Future<bool> shouldShowAd();
  Future<AdStatus> getStatus();
  void dispose();
}

class AdStatus {
  final bool initialized;
  final bool bannerReady;
  final bool interstitialReady;
  final bool interstitialShowing;

  const AdStatus({
    required this.initialized,
    required this.bannerReady,
    required this.interstitialReady,
    required this.interstitialShowing,
  });
}