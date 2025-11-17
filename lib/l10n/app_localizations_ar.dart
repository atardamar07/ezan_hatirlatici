// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تذكير الصلاة';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get searchCity => 'ابحث عن مدينة...';

  @override
  String get useCurrentLocation => 'استخدام موقعي الحالي';

  @override
  String get popularCities => 'المدن الشهيرة';

  @override
  String get noCityFound => 'لم يتم العثور على مدينة';

  @override
  String get cityNotFound => 'لم يتم العثور على المدينة';

  @override
  String get locationError =>
      'تعذر الحصول على الموقع. يرجى التحقق من أذونات الموقع.';

  @override
  String locationErrorDetails(Object error) {
    return 'حدث خطأ أثناء الحصول على الموقع: $error';
  }

  @override
  String get prayerTimesLoadError =>
      'فشل تحميل أوقات الصلاة. يرجى التحقق من إعدادات الموقع.';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get locationPermissionError =>
      'تم رفض إذن الموقع. يرجى تمكين خدمات الموقع.';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String nextPrayer(Object prayer) {
    return 'الصلاة التالية: $prayer';
  }

  @override
  String get menu => 'القائمة';

  @override
  String get home => 'الرئيسية';

  @override
  String get qiblaCompass => 'بوصلة القبلة';

  @override
  String get dhikrCounter => 'عداد الذكر';

  @override
  String get donate => 'تبرع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get cancel => 'إلغاء';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String timeRemainingHours(Object hours, Object minutes) {
    return '⏳ متبقي $hours س $minutes د';
  }

  @override
  String timeRemainingMinutes(Object minutes, Object seconds) {
    return '⏳ متبقي $minutes د $seconds ث';
  }

  @override
  String timeRemainingSeconds(Object seconds) {
    return '⏳ متبقي $seconds ث';
  }

  @override
  String get timeEntered => '🕌 حان وقت الصلاة';

  @override
  String get invalidTime => 'معلومات الوقت غير صالحة';

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get qiblaFound => 'أنت تواجه القبلة';

  @override
  String get turnRight => 'استدر لليمين';

  @override
  String get turnLeft => 'استدر لليسار';

  @override
  String distanceToKaaba(Object distance) {
    return 'المسافة إلى الكعبة: $distance كم';
  }

  @override
  String get youAreFacingQibla => 'أنت تواجه القبلة الآن';

  @override
  String get dhikrSettings => 'إعدادات الذكر';

  @override
  String get selectDhikr => 'اختر الذكر';

  @override
  String get targetCount => 'العدد المستهدف';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get sound => 'الصوت';

  @override
  String get save => 'حفظ';

  @override
  String get congratulations => 'مبروك!';

  @override
  String completedDhikr(Object count, Object dhikr) {
    return 'لقد أكملت ذكر $dhikr $count مرة!';
  }

  @override
  String get restart => 'إعادة البدء';

  @override
  String get continueText => 'متابعة';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get count => 'عد';

  @override
  String get tapToCount => 'اضغط على الشاشة لزيادة عدد الأذكار';

  @override
  String get donationsForWeb => 'التبرعات متاحة في تطبيق الجوال';

  @override
  String get donateInfo =>
      'يمكنك التبرع باستخدام التطبيق على جهاز Android أو iOS.';

  @override
  String get donationTitle => 'تبرع';

  @override
  String get thankYou => 'شكراً لك!';

  @override
  String get donationSuccess => 'شكراً جزيلاً على تبرعك!';

  @override
  String get noAds => 'لن ترى إعلانات بعد الآن في التطبيق.';

  @override
  String donationFailed(Object error) {
    return 'فشلت عملية التبرع: $error';
  }

  @override
  String get errorTitle => 'خطأ';

  @override
  String get hasDonatedThanks => 'شكراً جزيلاً على تبرعك!';

  @override
  String get supportApp => 'هل ترغب في دعم التطبيق؟';

  @override
  String get adFreeExperience => 'استمتع بتجربة خالية من الإعلانات';

  @override
  String get donationInfoText =>
      'ستُستخدم تبرعاتك لتطوير التطبيق وتغطية تكاليف الخادم.';

  @override
  String get noAdsFor30Days => 'لن يتم عرض إعلانات لمدة 30 يوماً بعد التبرع.';

  @override
  String get coffeeDonation => '☕ فنجان قهوة';

  @override
  String get coffeeDescription => 'اشتري قهوة للمطور';

  @override
  String get mealDonation => '🍽️ وجبة';

  @override
  String get mealDescription => 'اشتري وجبة للمطور';

  @override
  String get generousDonation => '💎 تبرع سخي';

  @override
  String get generousDescription => 'ادعم تطوير التطبيق';

  @override
  String get donateButton => 'تبرع';

  @override
  String get locationNotDetected =>
      'تعذر الحصول على الموقع. يرجى اختيار المدينة يدوياً.';

  @override
  String get failedToLoadPrayerTimes =>
      'فشل تحميل أوقات الصلاة. يرجى التحقق من إعدادات الموقع.';

  @override
  String get genericError => 'خطأ:';

  @override
  String get qibla => 'بوصلة القبلة';

  @override
  String get zikirmatik => 'عداد الذكر';

  @override
  String get prayerTimesLoadFailed => 'تعذر تحميل أوقات الصلاة';

  @override
  String get nextPrayerSimple => 'الصلاة التالية';
}
