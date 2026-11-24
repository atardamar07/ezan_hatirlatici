import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_free.dart';
import 'ad_ids.dart';

import 'ad_service_base.dart';

class AdServicePlatform implements AdServiceBase {
  static const _adInterval = Duration(minutes: 3);
  static const _retryDelay = Duration(minutes: 1);

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _isInterstitialShowing = false;
  bool _initialized = false;
  bool _canLoadAds = true;
  bool _isLoadingInterstitial = false;
  bool _isLoadingRewarded = false;
  // Debug derlemede ve iOS'ta (iOS için birim yok) Google'ın test reklamları
  final bool _useTestAds = kDebugMode || Platform.isIOS;

  String get _interstitialAdUnitId => !_useTestAds
      ? AdIds.androidInterstitialAdUnitId
      : Platform.isIOS
          ? AdIds.iosTestInterstitialAdUnitId
          : AdIds.androidTestInterstitialAdUnitId;

  String get _rewardedAdUnitId => !_useTestAds
      ? AdIds.androidRewardedAdUnitId
      : Platform.isIOS
          ? AdIds.iosTestRewardedAdUnitId
          : AdIds.androidTestRewardedAdUnitId;

  Future<void>? _initFuture;

  /// Tekil servis: ana sayfa yeniden kurulsa da onay + SDK başlatma bir kez yapılır
  @override
  Future<void> initialize({bool loadAds = true}) =>
      _initFuture ??= _initialize(loadAds);

  Future<void> _initialize(bool loadAds) async {
    // AB/İngiltere'de (GDPR) Google onaylı onay formu zorunlu; onay yoksa reklam istenmez
    await _gatherConsent();
    if (!await ConsentInformation.instance.canRequestAds()) {
      debugPrint('Ads disabled: consent not given');
      _canLoadAds = false;
      return;
    }

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
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (!_initialized || !_canLoadAds || _isLoadingRewarded || _rewarded != null) return;
    _isLoadingRewarded = true;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingRewarded = false;
          _rewarded = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: ${error.message}');
          _isLoadingRewarded = false;
        },
      ),
    );
  }

  @override
  Future<bool?> showRewardedAd() async {
    final ad = _rewarded;
    if (ad == null) {
      _loadRewardedAd();
      return null;
    }
    _rewarded = null;

    var earned = false;
    final closed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        if (!closed.isCompleted) closed.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewardedAd();
        if (!closed.isCompleted) closed.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => earned = true);
    return closed.future;
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
    // Ömür boyu lisans ya da ödüllü reklamla kazanılmış süre varsa geçiş reklamı yok
    if (AdFree.isActive(prefs, DateTime.now()) ||
        _isInterstitialShowing ||
        _interstitial == null) {
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
    _rewarded?.dispose();
  }
  Future<void> _updateLastAdTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("lastAdTime", DateTime.now().millisecondsSinceEpoch);
  }

  /// Gerekliyse (yalnızca onay gereken bölgelerde) Google'ın onay formunu gösterir
  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) debugPrint('Consent form error: ${error.message}');
      })
          .catchError((Object e) => debugPrint('Consent form failed: $e'))
          .whenComplete(done.complete),
      (error) {
        debugPrint('Consent info update failed: ${error.message}');
        done.complete();
      },
    );
    return done.future;
  }

  @override
  Future<bool> isPrivacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) debugPrint('Privacy options error: ${error.message}');
      });

  void _retryLoadInterstitial() {
    Future.delayed(_retryDelay, () {
      if (_isInterstitialShowing || !_canLoadAds) return;
      loadInterstitialAd();
    });
  }
}
