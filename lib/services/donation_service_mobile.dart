import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  @override
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP kullanılabilir değil');
      return;
    }

    // Satın alma akışını dinle
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (Object e) {
        debugPrint('Purchase stream error: $e');
      },
    );

    // Ürünleri sorgula
    const ids = {coffeeId, mealId, generousId};
    final response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Bulunamayan ürünler: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
        // işlem iptal/pending, bir şey yapmıyoruz
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasDonated', true);
    await prefs.setString('donationDate', DateTime.now().toIso8601String());
    await prefs.setString('lastDonationProductId', purchase.productID);

    // 30 gün reklam yok varsayımı için flag
    await prefs.setBool('isAdFree', true);

    // İşlemi tamamla
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  @override
  Future<void> makeDonation(String productId) async {
    if (!_isAvailable) {
      debugPrint('IAP kullanılabilir değil, makeDonation çalışmıyor');
      return;
    }

    try {
      final product = _products.firstWhere(
            (p) => p.id == productId,
        orElse: () {
          throw Exception('Ürün bulunamadı: $productId');
        },
      );

      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (e) {
      debugPrint('makeDonation hata: $e');
      rethrow;
    }
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
