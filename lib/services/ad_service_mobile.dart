import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_ids.dart';

import 'ad_service_base.dart';

class AdServicePlatform implements AdServiceBase {
  static const _adInterval = Duration(minutes: 5);
  static const _retryDelay = Duration(minutes: 1);

  BannerAd? _banner;
  InterstitialAd? _interstitial;
  bool _isInterstitialShowing = false;
  bool _initialized = false;
  bool _canLoadAds = true;
  bool _isLoadingInterstitial = false;
  final bool _useTestAds = kDebugMode;

  String get _bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isIOS
          ? AdIds.iosTestBannerAdUnitId
          : AdIds.androidTestBannerAdUnitId;
    }

    return Platform.isIOS
        ? AdIds.iosBannerAdUnitId
        : AdIds.androidBannerAdUnitId;
  }

  String get _interstitialAdUnitId {
    if (_useTestAds) {
      return Platform.isIOS
          ? AdIds.iosTestInterstitialAdUnitId
          : AdIds.androidTestInterstitialAdUnitId;
    }

    return Platform.isIOS
        ? AdIds.iosInterstitialAdUnitId
        : AdIds.androidInterstitialAdUnitId;
  }

  @override
  Future<void> initialize({bool loadAds = true}) async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e, stack) {
      debugPrint('AdMob initialization failed: $e\n$stack');
      _canLoadAds = false;
      return;
    }

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
    if (!_canLoadAds || _isLoadingInterstitial) return;

    _isLoadingInterstitial = true;
    await InterstitialAd.load(
      adUnitId: Platform.isIOS
          ? AdIds.iosInterstitialAdUnitId
          : AdIds.androidInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
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
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: ${error.message}');
          _interstitial = null;
          _isLoadingInterstitial = false;
          _retryLoadInterstitial();
        },
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
  Future<AdStatus> getStatus() async {
    return AdStatus(
      initialized: _initialized,
      bannerReady: _banner != null,
      interstitialReady: _interstitial != null,
      interstitialShowing: _isInterstitialShowing,
    );
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

  void _retryLoadInterstitial() {
    Future.delayed(_retryDelay, () {
      if (_isInterstitialShowing || !_canLoadAds) return;
      loadInterstitialAd();
    });
  }
}
