import 'donation_service_base.dart';

// Platforma göre mobil/web implementasyonu seçiyoruz
import 'donation_service_mobile.dart'
if (dart.library.html) 'donation_service_web.dart';

/// Ömür boyu reklamsız lisans satın alma (tekil servis, açılışta main.dart başlatır)
class DonationService {
  static final DonationService _instance = DonationService._internal();
  late final DonationServiceBase _impl;

  factory DonationService() => _instance;

  DonationService._internal() : _impl = PlatformDonationService();

  static const lifetimeProductId = 'lifetime_ad_free';

  Future<void> initialize() => _impl.initialize();

  /// Ürünü satın al; ödeme tamamlanınca true
  Future<bool> makeDonation(String productId) => _impl.makeDonation(productId);

  /// Mağazadan gelen, kullanıcının para biriminde fiyat
  String? priceOf(String productId) => _impl.priceOf(productId);

  void dispose() => _impl.dispose();
}
