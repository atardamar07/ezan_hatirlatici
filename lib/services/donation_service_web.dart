import 'donation_service_base.dart';

/// Web için dummy implementation (sadece derleme hatası vermesin)
class PlatformDonationService implements DonationServiceBase {
  @override
  Future<void> initialize() async {
    // Web'de mağaza yok, boş geçiyoruz.
  }

  @override
  Future<bool> makeDonation(String productId) async => false; // Web'de bağış yok

  @override
  String? priceOf(String productId) => null;

  @override
  void dispose() {
    // Temizlenecek bir şey yok.
  }
}
