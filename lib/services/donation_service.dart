import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'donation_service_base.dart';

// Platforma göre mobil/web implementasyonu seçiyoruz
import 'donation_service_mobile.dart'
if (dart.library.html) 'donation_service_web.dart';

class DonationService {
  static final DonationService _instance = DonationService._internal();
  late final DonationServiceBase _impl;

  factory DonationService() => _instance;

  DonationService._internal() : _impl = PlatformDonationService();

  /// Bağış sistemini başlat (DonationScreen içinden çağırıyorsun)
  Future<void> initialize() => _impl.initialize();

  /// Seçilen ürünü satın al; ödeme tamamlanınca true
  Future<bool> makeDonation(String productId) => _impl.makeDonation(productId);

  /// Mağazadan gelen, kullanıcının para biriminde fiyat
  String? priceOf(String productId) => _impl.priceOf(productId);

  void dispose() => _impl.dispose();

  /// SharedPreferences üzerinden bağış durumunu oku
  static Future<Map<String, dynamic>> getDonationInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final hasDonated = prefs.getBool('hasDonated') ?? false;
    final isAdFree = prefs.getBool('isAdFree') ?? false;
    final donationDate = prefs.getString('donationDate');
    final lastProductId = prefs.getString('lastDonationProductId');

    return {
      'hasDonated': hasDonated,
      'isActive': isAdFree,
      'donationDate': donationDate,
      'lastDonationProductId': lastProductId,
    };
  }

  /// Ekranda göstereceğimiz destek/bahşiş seçenekleri. Fiyat burada yazılmaz:
  /// Google Play her ülkede kendi fiyatını ve para birimini kullanır (bkz. [priceOf]).
  static List<Map<String, dynamic>> getDonationProducts(AppLocalizations loc) {
    // Buradaki id'ler, mobilde tanımladığımız IAP id'leriyle eşleşiyor
    return [
      {
        'id': 'support_tip_small',
        'title': loc.coffeeDonation,
        'description': loc.coffeeDescription,
        'icon': Icons.local_cafe,
      },
      {
        'id': 'support_tip_standard',
        'title': loc.mealDonation,
        'description': loc.mealDescription,
        'icon': Icons.fastfood,
      },
      {
        'id': 'support_tip_plus',
        'title': loc.generousDonation,
        'description': loc.generousDescription,
        'icon': Icons.diamond,
      },
    ];
  }
}
