abstract class DonationServiceBase {
  /// Uygulama açılırken IAP sistemini başlatır.
  Future<void> initialize();

  /// Seçilen ürünü satın almaya başlar.
  Future<void> makeDonation(String productId);

  /// Listener vs. temizler.
  void dispose();
}
