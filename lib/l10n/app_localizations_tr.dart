// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ezan Hatırlatıcısı';

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
  String get locationError => 'Konum alınamadı. Lütfen konum izinlerini kontrol edin.';

  @override
  String locationErrorDetails(Object error) {
    return 'Konum alınırken hata oluştu: $error';
  }

  @override
  String get prayerTimesLoadError => 'Namaz vakitleri yüklenemedi. Lütfen konum ayarlarını kontrol edin.';

  @override
  String error(Object error) {
    return 'Hata: $error';
  }

  @override
  String get genericError => 'Hata:';

  @override
  String get locationPermissionError => 'Konum izni verilmedi. Lütfen konum servislerini etkinleştirin.';

  @override
  String get currentLocation => 'Mevcut Konum';

  @override
  String nextPrayer(Object prayer) {
    return 'Sonraki Vakit: $prayer';
  }

  @override
  String get nextPrayerSimple => 'Sonraki Vakit';

  @override
  String get menu => 'Menü';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get qiblaCompass => 'Kıble Pusulası';

  @override
  String get dhikrCounter => 'Zikirmatik';

  @override
  String get donate => 'Destek Ol';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get settings => 'Ayarlar';

  @override
  String get calculationMethod => 'Hesaplama Metodu';

  @override
  String get methodDiyanetName => 'Diyanet İşleri Başkanlığı';

  @override
  String get methodDiyanetDescription => 'Türkiye için resmi yöntem';

  @override
  String get methodMwlName => 'Dünya Müslüman Birliği';

  @override
  String get methodMwlDescription => 'Genel uluslararası yöntem';

  @override
  String get methodEgyptianName => 'Mısır Genel Otoritesi';

  @override
  String get methodEgyptianDescription => 'Mısır yöntemi';

  @override
  String get methodKarachiName => 'Karaçi';

  @override
  String get methodKarachiDescription => 'Pakistan yöntemi';

  @override
  String get methodUmmAlQuraName => 'Umm Al-Qura';

  @override
  String get methodUmmAlQuraDescription => 'Suudi Arabistan';

  @override
  String get methodMoonsightingName => 'İslam Bilimleri Üniversitesi';

  @override
  String get methodMoonsightingDescription => 'Ürdün / İslam Bilimleri Üniversitesi';

  @override
  String get methodTehranName => 'Tahran Jeofizik Enstitüsü';

  @override
  String get methodTehranDescription => 'İran yöntemi';

  @override
  String get methodFranceName => 'Fransa İslam Organizasyonları Birliği';

  @override
  String get methodFranceDescription => 'Fransa yöntemi';

  @override
  String get cancel => 'İptal';

  @override
  String get selectLocation => 'Konum Seçin';

  @override
  String get sabah => 'Sabah';

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
  String get donationsForWeb => 'Destek İşlemleri Mobil Uygulamada Mevcut';

  @override
  String get donateInfo => 'Android veya iOS uygulamasından isteğe bağlı bahşiş verebilirsiniz.';

  @override
  String get donationTitle => 'Destek / Bahşiş';

  @override
  String get thankYou => 'Teşekkürler!';

  @override
  String get donationSuccess => 'Desteğiniz için çok teşekkür ederiz!';

  @override
  String get noAds => 'Artık uygulamada reklam görmeyeceksiniz.';

  @override
  String donationFailed(Object error) {
    return 'Destek işlemi başarısız oldu: $error';
  }

  @override
  String get errorTitle => 'Hata';

  @override
  String get hasDonatedThanks => 'Desteğiniz için teşekkürler!';

  @override
  String get supportApp => 'Uygulamayı bahşişle desteklemek ister misiniz?';

  @override
  String get adFreeExperience => 'Reklamsız deneyimin keyfini çıkarın';

  @override
  String get supportOptionalText => 'Bahşiş vermek tamamen gönüllüdür; uygulamadaki özelliklere erişmek için zorunlu değildir.';

  @override
  String get donationInfoText => 'Bahşişler Google Play Faturalandırma ile alınır ve geliştirme masrafları için kullanılır.';

  @override
  String get coffeeDonation => '☕ Küçük Destek';

  @override
  String get coffeeDescription => 'Tek seferlik küçük bir bahşiş';

  @override
  String get mealDonation => '🍽️ Standart Destek';

  @override
  String get mealDescription => 'Geliştirmeyi sürdürmek için tek seferlik destek';

  @override
  String get generousDonation => '💎 Gönülden Destek';

  @override
  String get generousDescription => 'Uygulamayı ileri taşımak için cömert bahşiş';

  @override
  String get donateButton => 'Destek Ol';

  @override
  String get locationNotDetected => 'Konum alınamadı. Lütfen manuel olarak şehir seçin.';

  @override
  String get failedToLoadPrayerTimes => 'Namaz vakitleri yüklenemedi. Lütfen konum ayarlarını kontrol edin.';

  @override
  String get prayerTimeEntered => 'Vakit girdi';

  @override
  String get selectCityTitle => 'Şehir Seçin';

  @override
  String get popularCitiesTitle => 'Popüler Şehirler';

  @override
  String get citySearchHint => 'Şehir ara...';

  @override
  String get noCityFoundMessage => 'Şehir bulunamadı';

  @override
  String get searchLanguageInfo => 'Arama uygulama diline göre yapılır. Lütfen şehir adını seçili dilde yazın.';

  @override
  String get useCurrentLocationButton => 'Mevcut Konumumu Kullan';

  @override
  String get prayerTimesLoadFailed => 'Namaz vakitleri yüklenemedi';

  @override
  String get loadingPrayerTimes => 'Namaz vakitleri yükleniyor...';

  @override
  String locationErrorRetry(Object error) {
    return 'Konum hatası: $error';
  }

  @override
  String get invalidTimeInfo => 'Zaman bilgisi geçersiz';

  @override
  String get resetCounter => 'Sıfırla';

  @override
  String get continueCounting => 'Devam Et';

  @override
  String get tapToIncrement => 'Tap to increase count';

  @override
  String get prayerNotificationTitle => '🕌 Prayer Time';

  @override
  String prayerNotificationBody(Object prayer) {
    return '$prayer time has arrived. Time to pray!';
  }

  @override
  String get reminderNotificationTitle => '⏰ Prayer Reminder';

  @override
  String reminderNotificationBody(Object minutes, Object prayer) {
    return '$prayer in $minutes minutes';
  }

  @override
  String get tomorrow => 'Yarın';

  @override
  String get tomorrowFajr => 'Yarın İmsak';

  @override
  String get subhanallahMeaning => 'Allah sübhandır (eksikliklerden münezzehtir)';

  @override
  String get alhamdulillahMeaning => 'Allah\'a hamd olsun';

  @override
  String get allahuAkbarMeaning => 'Allah en büyüktür';

  @override
  String get laIlaheIllallahMeaning => 'Allah\'tan başka ilah yoktur';

  @override
  String get astagfirullahMeaning => 'Allah\'tan af dilerim';

  @override
  String get hasbunallahMeaning => 'Allah bize yeter';

  @override
  String savedLocation(Object location) {
    return 'Kaydedilen konum: $location';
  }

  @override
  String get detectingLocation => 'Konum tespiti yapılıyor...';

  @override
  String locationPermissionActive(Object location) {
    return 'Konum izni aktif: $location';
  }

  @override
  String get locationPermissionLimited => 'Konum izni kapalı. Bildirimler sınırlı çalışabilir.';

  @override
  String locationUpdated(Object location) {
    return 'Konum güncellendi: $location';
  }

  @override
  String citySelected(Object location) {
    return 'Şehir seçildi: $location';
  }

  @override
  String get locationPermissionGranted => 'Konum izni aktif';

  @override
  String get locationPermissionPending => 'Konum izni bekleniyor';

  @override
  String get notificationsReady => 'Bildirimler hazır';

  @override
  String get notificationsPending => 'Bildirim izni bekleniyor';

  @override
  String get quickActionToday => 'Bugün';

  @override
  String get quickActionWeekly => 'Haftalık görünüm';

  @override
  String get quickActionNotifications => 'Bildirimler';

  @override
  String get locationInfoMissing => 'Konum bilgisi bulunamadı.';

  @override
  String get cityInfoMissing => 'Şehir bilgisi bulunamadı.';

  @override
  String get selectLocationOrCity => 'Lütfen önce konum veya şehir seçin.';

  @override
  String get weeklyTimesUnavailable => 'Haftalık vakitler getirilemedi.';

  @override
  String get dataUnavailable => 'Veri alınamadı';

  @override
  String get weeklyViewTitle => 'Haftalık Görünüm';

  @override
  String get refresh => 'Yenile';

  @override
  String get weeklyDataMissing => 'Haftalık veriler bulunamadı.';

  @override
  String get noDataForDay => 'Seçilen güne ait veri bulunamadı.';

  @override
  String get calendarTitle => 'Takvim';

  @override
  String get monthlyLabel => 'Aylık';

  @override
  String get weeklyLabel => 'Haftalık';

  @override
  String get selectedDayTimes => 'Seçilen gün vakitleri';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationInfoLine1 => 'Namaz hatırlatıcılarını etkinleştirdiğinizde uyarılar zamanında gelir.';

  @override
  String get notificationInfoLine2 => 'Bildirim izinlerini cihaz ayarlarınızdan yönetebilir, sesli ezan bildirimlerini açabilirsiniz.';

  @override
  String get notificationStatus => 'Bildirim durumu';

  @override
  String get notificationPermission => 'Bildirim izni';

  @override
  String get permissionGranted => 'İzin verildi';

  @override
  String get permissionDenied => 'İzin kapalı';

  @override
  String get exactAlarmPermission => 'Exact alarm izni';

  @override
  String get schedulingActive => 'Planlama aktif';

  @override
  String get exactAlarmDisabled => 'Exact alarm kapalı';

  @override
  String get soundNotification => 'Sesli bildirim';

  @override
  String get soundOn => 'Ezan sesi açık';

  @override
  String get soundOff => 'Ses kapalı';

  @override
  String get adControl => 'Reklam kontrolü';

  @override
  String get sdkInitialized => 'SDK başlatıldı';

  @override
  String get statusReady => 'Hazır';

  @override
  String get statusWaiting => 'Başlatma bekleniyor';

  @override
  String get bannerAd => 'Banner';

  @override
  String get loaded => 'Yüklendi';

  @override
  String get notLoaded => 'Yüklenmedi';

  @override
  String get interstitialAd => 'Geçiş reklamı';

  @override
  String get showing => 'Gösteriliyor';

  @override
  String get notReady => 'Hazır değil';

  @override
  String get locationStatusOn => 'Konum açık';

  @override
  String get locationStatusOff => 'Konum kapalı';

  @override
  String get internetStatusOn => 'İnternet aktif';

  @override
  String get internetStatusOff => 'İnternet yok';

  @override
  String get prayerNotificationsTitle => 'Vakit bildirimleri';

  @override
  String get prayerNotificationsSubtitle => 'Her vakit için bildirim saatini ve durumu yönetin.';

  @override
  String get notificationEnabled => 'Bildirim açık';

  @override
  String get notificationDisabled => 'Bildirim kapalı';

  @override
  String get notificationOptionsTitle => 'Bildirim seçenekleri';

  @override
  String get notificationOptionsSubtitle => 'Sessiz saatler ve önceden uyar tercihleri';

  @override
  String get quietHoursLabel => 'Sessiz saatler';

  @override
  String quietHoursShort(int hours) {
    return '$hours sa';
  }

  @override
  String quietHoursLong(int hours) {
    return '$hours saat';
  }

  @override
  String get preAlert => 'Önceden uyar';

  @override
  String get preAlertOff => 'Kapalı';

  @override
  String preAlertMinutes(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String get systemTheme => 'Sistem Teması';

  @override
  String get systemThemeSubtitle => 'Cihaz ayarlarına göre';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String get lightThemeSubtitle => 'Gündüz görünümü';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get darkThemeSubtitle => 'Gece görünümü';
}
