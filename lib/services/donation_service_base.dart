abstract class DonationServiceBase {
  /// Uygulama açılırken IAP sistemini başlatır.
  Future<void> initialize();

  /// Seçilen ürünü satın alır. Ödeme gerçekten tamamlanınca true; iptal veya
  /// beklemedeyse false döner; hata olursa fırlatır.
  Future<bool> makeDonation(String productId);

  /// Mağazanın kullanıcının para biriminde verdiği fiyat (ör. "₺49,99", "1,99 €"); yoksa null.
  String? priceOf(String productId);

  /// Listener vs. temizler.
  void dispose();
}
