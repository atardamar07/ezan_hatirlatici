// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ezan Hatırlatıcı';

  @override
  String get selectCity => 'Şehir Seçin';

  @override
  String get searchCity => 'Şehir ara...';

  @override
  String get useCurrentLocation => 'Mevcut Konumumu Kullan';

  @override
  String get popularCities => 'Popüler Şehirler';

  @override
  String get noCityFound => 'Şehir bulunamadı';

  @override
  String get cityNotFound => 'Şehir bulunamadı';

  @override
  String get locationError =>
      'Konum alınamadı. Lütfen konum izinlerini kontrol edin.';

  @override
  String locationErrorDetails(Object error) {
    return 'Konum alınırken hata oluştu: $error';
  }

  @override
  String get prayerTimesLoadError =>
      'Namaz vakitleri yüklenemedi. Lütfen konum ayarlarını kontrol edin.';

  @override
  String error(Object error) {
    return 'Hata: $error';
  }

  @override
  String get locationPermissionError =>
      'Konum izni verilmedi. Lütfen konum servislerini etkinleştirin.';

  @override
  String get currentLocation => 'Mevcut Konum';

  @override
  String nextPrayer(Object prayer) {
    return 'Sonraki Vakit: $prayer';
  }

  @override
  String get menu => 'Menü';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get qiblaCompass => 'Kıble Pusulası';

  @override
  String get dhikrCounter => 'Zikirmatik';

  @override
  String get donate => 'Bağış Yap';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get settings => 'Ayarlar';

  @override
  String get calculationMethod => 'Hesaplama Metodu';

  @override
  String get cancel => 'İptal';

  @override
  String get selectLocation => 'Konum Seçin';

  @override
  String get fajr => 'İmsak';

  @override
  String get sunrise => 'Güneş';

  @override
  String get dhuhr => 'Öğle';

  @override
  String get asr => 'İkindi';

  @override
  String get maghrib => 'Akşam';

  @override
  String get isha => 'Yatsı';

  @override
  String timeRemainingHours(Object hours, Object minutes) {
    return '⏳ $hours sa $minutes dk kaldı';
  }

  @override
  String timeRemainingMinutes(Object minutes, Object seconds) {
    return '⏳ $minutes dk $seconds sn kaldı';
  }

  @override
  String timeRemainingSeconds(Object seconds) {
    return '⏳ $seconds sn kaldı';
  }

  @override
  String get timeEntered => '🕌 Vakit girdi';

  @override
  String get invalidTime => 'Zaman bilgisi geçersiz';

  @override
  String get qiblaDirection => 'Kıble Pusulası';

  @override
  String get qiblaFound => 'Kıbleye Yöneldiniz';

  @override
  String get turnRight => 'Sağa Dönün';

  @override
  String get turnLeft => 'Sola Dönün';

  @override
  String distanceToKaaba(Object distance) {
    return 'Kâbe\'ye Mesafe: $distance km';
  }

  @override
  String get youAreFacingQibla => 'Şu anda kıbleye doğru bakıyorsunuz';

  @override
  String get dhikrSettings => 'Zikirmatik Ayarları';

  @override
  String get selectDhikr => 'Zikir Seçin';

  @override
  String get targetCount => 'Hedef Sayı';

  @override
  String get vibration => 'Titreşim';

  @override
  String get sound => 'Ses';

  @override
  String get save => 'Kaydet';

  @override
  String get congratulations => 'Tebrikler!';

  @override
  String completedDhikr(Object count, Object dhikr) {
    return '$dhikr zikrinizi $count kez tamamladınız!';
  }

  @override
  String get restart => 'Yeniden Başla';

  @override
  String get continueText => 'Devam Et';

  @override
  String get reset => 'Sıfırla';

  @override
  String get count => 'Say';

  @override
  String get tapToCount => 'Ekrana dokunarak zikir sayınızı artırabilirsiniz';

  @override
  String get donationsForWeb => 'Bağış İşlemleri Mobil Uygulamada Mevcut';

  @override
  String get donateInfo =>
      'Uygulamayı Android veya iOS cihazınızdan kullanarak bağış yapabilirsiniz.';

  @override
  String get donationTitle => 'Bağış Yap';

  @override
  String get thankYou => 'Teşekkürler!';

  @override
  String get donationSuccess => 'Bağışınız için çok teşekkür ederiz!';

  @override
  String get noAds => 'Artık uygulamada reklam görmeyeceksiniz.';

  @override
  String donationFailed(Object error) {
    return 'Bağış işlemi başarısız oldu: $error';
  }

  @override
  String get errorTitle => 'Hata';

  @override
  String get hasDonatedThanks => 'Bağış yaptığınız için teşekkürler!';

  @override
  String get supportApp => 'Uygulamayı desteklemek ister misiniz?';

  @override
  String get adFreeExperience => 'Reklamsız deneyimin keyfini çıkarın';

  @override
  String get donationInfoText =>
      'Bağışlarınız uygulamanın geliştirilmesi ve sunucu masraflarının karşılanmasında kullanılacaktır.';

  @override
  String get noAdsFor30Days =>
      'Bağış yaptıktan sonra 30 gün boyunca reklam gösterilmeyecektir.';

  @override
  String get coffeeDonation => '☕ Bir Fincan Kahve';

  @override
  String get coffeeDescription => 'Geliştiriciye kahve ısmarla';

  @override
  String get mealDonation => '🍽️ Bir Öğün Yemek';

  @override
  String get mealDescription => 'Geliştiriciye yemek ısmarla';

  @override
  String get generousDonation => '💎 Cömert Bağış';

  @override
  String get generousDescription => 'Uygulamanın gelişimine destek ol';

  @override
  String get donateButton => 'Bağış Yap';

  @override
  String get locationNotDetected =>
      'Konum alınamadı. Lütfen manuel olarak şehir seçin.';

  @override
  String get failedToLoadPrayerTimes =>
      'Namaz vakitleri yüklenemedi. Lütfen konum ayarlarını kontrol edin.';

  @override
  String get genericError => 'Hata:';

  @override
  String get qibla => 'Kıble Pusulası';

  @override
  String get zikirmatik => 'Zikirmatik';

  @override
  String get prayerTimesLoadFailed => 'Namaz vakitleri yüklenemedi';

  @override
  String get nextPrayerSimple => 'Sonraki Vakit';
}
