import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_ids.dart';

import 'ad_service_base.dart';

class AdServicePlatform implements AdServiceBase {
  BannerAd? _banner;
  InterstitialAd? _interstitial;


  @override
  Future<void> initialize({bool loadAds = true}) async {
    await MobileAds.instance.initialize();

    _banner = BannerAd(
      adUnitId:
      Platform.isIOS ? AdIds.iosBannerAdUnitId : AdIds.androidBannerAdUnitId,
      size: AdSize.banner,
      listener: BannerAdListener(),
      request: const AdRequest(),
    )..load();

    await loadInterstitialAd();
  }

  @override
  Widget buildBannerAd() {
    if (_banner == null) return const SizedBox.shrink();
    return SizedBox(height: 50, child: AdWidget(ad: _banner!));
  }

  @override
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: Platform.isIOS
          ? AdIds.iosInterstitialAdUnitId
          : AdIds.androidInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  @override
  void showInterstitialAd() {
    _interstitial?.show();
    _interstitial = null;
    loadInterstitialAd();
  }

  @override
  Future<bool> shouldShowAd() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdFree = prefs.getBool('isAdFree') ?? false;
    if (isAdFree) return false;

    final last = prefs.getInt("lastAdTime") ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - last > 1 * 60 * 1000) {
      prefs.setInt("lastAdTime", now);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _banner?.dispose();
    _interstitial?.dispose();
  }
}
