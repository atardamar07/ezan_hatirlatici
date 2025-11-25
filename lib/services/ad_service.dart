import 'package:flutter/material.dart';

import 'ad_service_base.dart';

// KOŞULLU IMPORT
// Web → ad_service_web.dart içindeki class AdServicePlatform
// Mobil → ad_service_mobile.dart içindeki class AdServicePlatform
import 'ad_service_web.dart'
if (dart.library.io) 'ad_service_mobile.dart';

class AdService {
static final AdService _instance = AdService._internal();
late final AdServiceBase _impl;

factory AdService() => _instance;

AdService._internal() : _impl = AdServicePlatform();

Future<void> initialize({bool loadAds = true}) =>
_impl.initialize(loadAds: loadAds);

  Future<void> loadInterstitialAd() => _impl.loadInterstitialAd();

  void showInterstitialAd() => _impl.showInterstitialAd();

  Future<bool> shouldShowAd() => _impl.shouldShowAd();

Future<AdStatus> getStatus() => _impl.getStatus();

void dispose() => _impl.dispose();
}
