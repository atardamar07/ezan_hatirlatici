import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_free.dart';
import 'donation_service_base.dart';

/// Mobil (Android / iOS) için ömür boyu reklamsız lisans satışı
class PlatformDonationService implements DonationServiceBase {
  /// Play Console → Tek seferlik ürünler → "Lifetime Ad-Free" (tüketilmez; yeniden kurulumda geri gelir)
  static const String lifetimeId = 'lifetime_ad_free';

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

    final response = await _iap.queryProductDetails({lifetimeId});

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
    if (purchase.productID == lifetimeId) {
      await AdFree.grantLifetime(await SharedPreferences.getInstance());
    }
    // Onaylanmayan satın almayı Google 3 gün sonra iade eder; ürün tüketilmez, kalıcıdır
    if (purchase.pendingCompletePurchase) {
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
    // Ödeme ekranı açılınca döner; asıl sonuç _onPurchaseUpdated'dan gelir
    final started = await _iap.buyNonConsumable(
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
}
