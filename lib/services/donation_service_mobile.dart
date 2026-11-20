import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'donation_service_base.dart';

/// Mobil (Android / iOS) için bağış servisi
class PlatformDonationService implements DonationServiceBase {
  // Ürün ID'leri (Google Play / App Store'da tanımladığın ID'lerle aynı olmalı)
  // Google Play Billing / App Store ürün kimlikleri (tek seferlik destek)
  static const String coffeeId = 'support_tip_small';
  static const String mealId = 'support_tip_standard';
  static const String generousId = 'support_tip_plus';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  Future<void>? _initFuture;

  /// Ekranda başlatılan satın almanın sonucu (true = ödeme tamamlandı)
  Completer<bool>? _purchaseResult;
  String? _purchasingProductId;

  /// Uygulama açılışında bir kez çağrılır (main.dart); ekran tekrar çağırırsa aynı sonucu bekler
  @override
  Future<void> initialize() => _initFuture ??= _initialize().catchError((Object e) {
        _initFuture = null; // bir sonraki çağrıda yeniden denensin
        throw e;
      });

  Future<void> _initialize() async {
    // Dinleme açılışta başlamalı: "beklemede" kalıp sonradan tamamlanan ödemeler de
    // işlensin. Google, onaylanmayan satın almayı 3 gün sonra iade eder.
    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (Object e) {
        debugPrint('Purchase stream error: $e');
      },
    );

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP kullanılabilir değil');
      _initFuture = null; // mağaza sonra hazır olursa tekrar denensin
      return;
    }

    // Ürünleri sorgula
    const ids = {coffeeId, mealId, generousId};
    final response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Bulunamayan ürünler: ${response.notFoundIDs}');
    }

    _products = response.productDetails;

    // Uygulama kapalıyken tamamlanmış, henüz onaylanmamış satın almaları getir
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchase);
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error}');
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          // Beklemedeki ödemede Google Play kullanıcıyı kendisi bilgilendirir
          break;
      }
      _reportResult(purchase);
    }
  }

  /// Ekranda bekleyen satın almaya sonucunu bildirir; teşekkür yalnızca gerçek ödemede gösterilir
  void _reportResult(PurchaseDetails purchase) {
    final result = _purchaseResult;
    if (result == null || result.isCompleted || purchase.productID != _purchasingProductId) {
      return;
    }
    if (purchase.status == PurchaseStatus.error) {
      result.completeError(Exception(purchase.error?.message ?? 'Purchase error'));
    } else {
      result.complete(purchase.status == PurchaseStatus.purchased);
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasDonated', true);
    await prefs.setString('donationDate', DateTime.now().toIso8601String());
    await prefs.setString('lastDonationProductId', purchase.productID);

    // 30 gün reklam yok varsayımı için flag
    await prefs.setBool('isAdFree', true);

    if (Platform.isAndroid && purchase.status == PurchaseStatus.restored) {
      // Önceki oturumdan gelen bahşiş otomatik tüketilmez; tüketilmezse aynısı bir daha alınamaz
      await _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .consumePurchase(purchase);
    } else if (purchase.pendingCompletePurchase) {
      // İşlemi tamamla
      await _iap.completePurchase(purchase);
    }
  }

  @override
  Future<bool> makeDonation(String productId) async {
    await initialize();
    if (!_isAvailable) {
      throw Exception('Google Play Billing kullanılamıyor');
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Ürün bulunamadı: $productId'),
    );

    _purchasingProductId = productId;
    final result = _purchaseResult = Completer<bool>();
    // buyConsumable ödeme ekranı açılınca döner; asıl sonuç _onPurchaseUpdated'dan gelir
    final started = await _iap.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!started) {
      throw Exception('Satın alma başlatılamadı');
    }
    return result.future;
  }

  @override
  String? priceOf(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product.price;
    }
    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
  }

  /// Bağış geçmişini sıfırlamak istersen kullanabilirsin.
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasDonated');
    await prefs.remove('donationDate');
    await prefs.remove('lastDonationProductId');
    await prefs.setBool('isAdFree', false);
  }
}
