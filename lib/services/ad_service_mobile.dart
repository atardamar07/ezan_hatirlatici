import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_ids.dart';

import 'ad_service_base.dart';

class AdServicePlatform implements AdServiceBase {
  static const _adInterval = Duration(minutes: 3);
  static const _retryDelay = Duration(minutes: 1);

  InterstitialAd? _interstitial;
  bool _isInterstitialShowing = false;
  bool _initialized = false;
  bool _canLoadAds = true;
  bool _isLoadingInterstitial = false;
  final bool _useTestAds = kDebugMode;


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
      // Add timeout protection to prevent indefinite hanging
      await MobileAds.instance.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('AdMob initialization timed out after 10 seconds');
          throw TimeoutException('AdMob initialization timeout');
        },
      );
      _initialized = true;
      debugPrint('AdMob initialized successfully');
    } catch (e, stack) {
      debugPrint('AdMob initialization failed: $e\n$stack');
      _initialized = false;
      _canLoadAds = false;
      return;
    }

    if (!loadAds) return;

    await loadInterstitialAd();
  }

  @override
  Future<void> loadInterstitialAd() async {
    if (!_canLoadAds || _isLoadingInterstitial) return;

    _isLoadingInterstitial = true;
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
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
    if (!_initialized || _isInterstitialShowing || _interstitial == null) {
      debugPrint('Cannot show ad: initialized=$_initialized, showing=$_isInterstitialShowing, ad=${_interstitial != null}');
      return;
    }

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
      interstitialReady: _interstitial != null,
      interstitialShowing: _isInterstitialShowing,
    );
  }

  @override
  void dispose() {
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
