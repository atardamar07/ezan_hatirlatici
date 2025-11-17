import 'package:flutter/material.dart';

abstract class AdServiceBase {
  Future<void> initialize({bool loadAds = true});
  Widget buildBannerAd();
  Future<void> loadInterstitialAd();
  void showInterstitialAd();
  Future<bool> shouldShowAd();
  void dispose();
}
