import 'donation_service_base.dart';

/// Web için dummy implementation (sadece derleme hatası vermesin)
class PlatformDonationService implements DonationServiceBase {
  @override
  Future<void> initialize() async {
    // Web'de mağaza yok, boş geçiyoruz.
  }

  @override
  Future<void> makeDonation(String productId) async {
    // Web'de bağış yok, hiçbir şey yapmıyoruz.
  }

  @override
  void dispose() {
    // Temizlenecek bir şey yok.
  }
}
