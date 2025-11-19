import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_ids.dart';

import 'ad_service_base.dart';

class AdServicePlatform implements AdServiceBase {
  static const _adInterval = Duration(minutes: 5);

  BannerAd? _banner;
  InterstitialAd? _interstitial;
  bool _isInterstitialShowing = false;

  @override
  Future<void> initialize({bool loadAds = true}) async {
    await MobileAds.instance.initialize();
    if (!loadAds) return;

    _banner = BannerAd(
      adUnitId: Platform.isIOS
          ? AdIds.iosBannerAdUnitId
          : AdIds.androidBannerAdUnitId,
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
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) async {
              _isInterstitialShowing = true;
              await _updateLastAdTime();
            },
            onAdDismissedFullScreenContent: (ad) {
              _isInterstitialShowing = false;
              ad.dispose();
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              _isInterstitialShowing = false;
              ad.dispose();
              loadInterstitialAd();
            },
          );

          _interstitial = ad;
        },
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }
  @override
  void showInterstitialAd() {
    if (_isInterstitialShowing) return;

    _interstitial?.show();
    _interstitial = null;

  }

  @override
  Future<bool> shouldShowAd() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdFree = prefs.getBool('isAdFree') ?? false;
    if (isAdFree || _isInterstitialShowing || _interstitial == null) {
      return false;
    }

    final last = prefs.getInt("lastAdTime") ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    return now - last > _adInterval.inMilliseconds;
  }

  @override
  void dispose() {
    _banner?.dispose();
    _interstitial?.dispose();
  }
  Future<void> _updateLastAdTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("lastAdTime", DateTime.now().millisecondsSinceEpoch);
  }
}
