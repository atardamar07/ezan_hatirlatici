import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Seçilen ürünü satın al
  Future<void> makeDonation(String productId) => _impl.makeDonation(productId);

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

  /// Ekranda göstereceğimiz bağış seçenekleri
  static List<Map<String, dynamic>> getDonationProducts() {
    // Buradaki id'ler, mobilde tanımladığımız IAP id'leriyle eşleşiyor
    return const [
      {
        'id': 'coffee_donation',
        'title': 'Bir Kahve Ismarla',
        'description': 'Küçük ama değerli bir destek.',
        'price': '₺20',
        'icon': Icons.local_cafe,
      },
      {
        'id': 'meal_donation',
        'title': 'Bir Yemek Ismarla',
        'description': 'Uygulamanın geliştirilmesine katkı sağla.',
        'price': '₺50',
        'icon': Icons.fastfood,
      },
      {
        'id': 'generous_donation',
        'title': 'Cömert Destek',
        'description': 'Projeye büyük destek vermek isteyenler için.',
        'price': '₺200',
        'icon': Icons.diamond,
      },
    ];
  }
}
