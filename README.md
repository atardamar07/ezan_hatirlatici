# Namaz Vakti Uygulaması

## 🕌 Uygulama Hakkında

Bu, dünya genelinde tüm şehirlerde namaz vakitlerini gösteren, kıble yönünü bulmaya yardımcı olan, zikirmatik özelliği sunan ve reklam destekli gelir modeliyle çalışan kapsamlı bir İslami uygulamadır.

## ✨ Özellikler

### 🌍 Global Konum Desteği
- Dünya genelinde tüm şehirlerde namaz vakitleri
- GPS konum tespiti veya manuel şehir seçimi
- Konum bazlı otomatik vakit hesaplama
- Farklı hesaplama metodları (Muslim World League, ISNA, vb.)

### 🧭 Kıble Pusulası
- Manyetik sensör kullanarak kıble yönünü bulma
- Modern ve kullanıcı dostu arayüz
- Gerçek zamanlı yön göstergesi
- Kıbleye yöneldiğinizde yeşil onay mesajı ve animasyon

### 📿 Zikirmatik
- 6 farklı zikir seçeneği (Subhanallah, Elhamdülillah, vb.)
- Hedef sayı belirleme özelliği
- Titreşim ve sesli geri bildirim
- İlerleme çubuğu ve yüzdelik gösterim
- Günlük istatistik takibi

### 💰 Reklam ve Bağış Sistemi
- AdMob reklam entegrasyonu
- In-app purchase bağış sistemi
- 3 farklı bağış seçeneği
- Bağış yapan kullanıcılar için reklamsız deneyim
- 30 günlük reklamsız süre

### 🔔 Bildirim Sistemi
- Namaz vakti geldiğinde anlık bildirimler
- Sesli ve titreşimli uyarılar
- Zamanlanmış hatırlatıcılar

## 🛠️ Teknoloji Stack'i

- **Flutter**: Cross-platform mobil uygulama geliştirme
- **Dart**: Programlama dili
- **Provider**: State management
- **Shared Preferences**: Yerel veri saklama
- **Location**: GPS konum servisleri
- **Geocoding**: Coğrafi veri işleme
- **HTTP**: API istekleri
- **Sensors Plus**: Manyetik sensör erişimi
- **Google Mobile Ads**: Reklam entegrasyonu
- **In App Purchase**: Bağış sistemi
- **Vibration**: Titreşim özellikleri

## 📱 Ekranlar

### Ana Sayfa
- Şehir seçimi veya mevcut konum kullanımı
- Günlük namaz vakitleri listesi
- Sonraki vakit bilgisi
- Hesaplama metodu seçimi

### Kıble Pusulası
- Gerçek zamanlı pusula gösterimi
- Kıble yönü işareti
- Mesafe bilgisi
- Yönlendirme metinleri

### Zikirmatik
- Zikir seçimi
- Sayma ekranı
- Ayarlar paneli
- İstatistikler

### Bağış Ekranı
- Bağış seçenekleri
- Ödeme işlemleri
- Bağış durumu takibi

## 🚀 Kurulum

1. **Gereksinimler**
    - Flutter SDK (3.0.0+)
    - Dart SDK
    - Android Studio / VS Code
    - Git

2. **Projeyi Klonla**
   ```bash
   git clone [proje-url]
   cd prayer_time_app
   ```

3. **Bağımlılıkları Yükle**
   ```bash
   flutter pub get
   ```

4. **Uygulamayı Çalıştır**
   ```bash
   flutter run
   ```

## 🧹 Windows'ta Flutter Clean Hatasını Giderme

`flutter clean` komutu sırasında "Failed to remove build" hatası alıyorsanız, muhtemelen Windows'ta açık kalan bir süreç (Flutter, Dart, Gradle veya ADB) `build` klasörünü kilitliyordur. Bu durumda şu adımları izleyebilirsiniz:

1. Çalışan uygulamaları ve emülatörü kapatın.
2. PowerShell'de proje kök dizininde aşağıdaki komutu çalıştırın:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\windows_force_clean.ps1 -KillGradle -KillJava
   ```
    - Gerekirse `-KillGradle` ve `-KillJava` bayraklarını kaldırarak yalnızca Flutter/Dart/ADB süreçlerini sonlandırabilirsiniz.
3. Ardından temiz bir kurulum için şu adımları izleyin:
   ```powershell
   flutter pub get
   flutter clean
   ```

Bu script, kilitli klasörleri zorla kaldırarak temizlik işlemini yeniden denenebilir hale getirir.

## 📦 Paket Yönetimi

### Pubspec.yaml Özeti

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Core packages
  cupertino_icons: ^1.0.2
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  
  # Location & Maps
  location: ^5.0.0
  geocoding: ^2.1.1
  
  # API & HTTP
  http: ^1.1.0
  
  # Sensors
  sensors_plus: ^3.0.2
  
  # Ads & Payment
  google_mobile_ads: ^3.1.0
  in_app_purchase: ^3.1.5
  
  # UI Enhancement
  flutter_svg: ^2.0.9
  animations: ^2.0.8
  
  # Date & Time
  hijri: ^3.0.0
  intl: ^0.18.1
  
  # Vibration
  vibration: ^1.8.4
  
  # Notifications
  flutter_local_notifications: ^16.3.0
```

## 🔧 Yapılandırma

### Android İçin
- `android/app/src/main/AndroidManifest.xml` dosyasında konum izinleri eklenmeli
- Proguard kuralları gerekiyorsa `android/app/proguard-rules.pro` dosyasına eklenmeli

### iOS İçin
- `ios/Runner/Info.plist` dosyasında konum ve bildirim izinleri tanımlanmalı

## 📊 API Entegrasyonu

### Namaz Vakitleri API
- **URL**: `https://api.aladhan.com/v1`
- **Endpoint**: `/timings` ve `/timingsByCity`
- **Desteklenen Metodlar**: 13 farklı hesaplama metodu
- **Cache**: 24 saatlik yerel cache desteği

## 💡 Geliştirme İpuçları

### Performans Optimizasyonu
- API çağrıları için cache mekanizması
- Lazy loading for large data sets
- Image caching and compression

### Hata Yönetimi
- Try-catch blokları ile kapsamlı hata yakalama
- Kullanıcı dostu hata mesajları
- Fallback mekanizmaları

### Güvenlik
- API anahtarlarının güvenli saklanması
- Kullanıcı verilerinin şifrelenmesi
- Güvenli ödeme işlemleri

## 🎯 Gelecek Özellikler

- Takvim entegrasyonu
- Cemaat bulma özelliği
- Cami bilgileri ve yol tarifi
- Hicri takvim desteği
- Widget desteği
- Apple Watch / Wear OS uygulaması
- Sosyal paylaşım özellikleri

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add some amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT Lisansı ile lisanslanmıştır.

## 👨‍💻 Geliştirici

Daha fazla bilgi ve destek için:
- Email: [email@example.com]
- GitHub: [github.com/username]

## 🙏 Teşekkürler

- Aladhan API için namaz vakti verileri
- Flutter topluluğu için harika paketler
- Tüm bağış yapan kullanıcılara

---

**Not**: Bu uygulama dini amaçlarla geliştirilmiştir. Namaz vakitleri ve kıble yönü için lütfen yerel dini otoriteleri de kontrol edin.