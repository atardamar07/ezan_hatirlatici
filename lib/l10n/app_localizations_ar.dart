// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منبّه الصلاة';

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
  String get locationError => 'تعذر الحصول على الموقع. يرجى التحقق من أذونات الموقع.';

  @override
  String locationErrorDetails(Object error) {
    return 'حدث خطأ أثناء الحصول على الموقع: $error';
  }

  @override
  String get prayerTimesLoadError => 'فشل تحميل أوقات الصلاة. يرجى التحقق من إعدادات الموقع.';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get genericError => 'خطأ:';

  @override
  String get locationPermissionError => 'تم رفض إذن الموقع. يرجى تمكين خدمات الموقع.';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String nextPrayer(Object prayer) {
    return 'الصلاة التالية: $prayer';
  }

  @override
  String get nextPrayerSimple => 'الصلاة التالية';

  @override
  String get menu => 'القائمة';

  @override
  String get home => 'الرئيسية';

  @override
  String get qiblaCompass => 'بوصلة القبلة';

  @override
  String get dhikrCounter => 'عداد الذكر';

  @override
  String get donate => 'قدّم دعمًا';

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
  String get donationsForWeb => 'خيارات الدعم متاحة في تطبيق الجوال';

  @override
  String get donateInfo => 'يمكنك إرسال دعم اختياري عبر تطبيق Android أو iOS.';

  @override
  String get donationTitle => 'دعم التطبيق';

  @override
  String get thankYou => 'شكراً لك!';

  @override
  String get donationSuccess => 'شكراً جزيلاً على دعمك!';

  @override
  String get noAds => 'لن ترى إعلانات بعد الآن في التطبيق.';

  @override
  String donationFailed(Object error) {
    return 'فشل دفع الدعم: $error';
  }

  @override
  String get errorTitle => 'خطأ';

  @override
  String get hasDonatedThanks => 'شكراً جزيلاً على دعمك!';

  @override
  String get supportApp => 'هل ترغب في دعم التطبيق بإكرامية؟';

  @override
  String get adFreeExperience => 'استمتع بتجربة خالية من الإعلانات';

  @override
  String get supportOptionalText => 'الدعم اختياري بالكامل وليس مطلوبًا لاستخدام التطبيق.';

  @override
  String get donationInfoText => 'تُعالج مبالغ الدعم عبر فوترة Google Play وتساعد في تغطية التطوير وتكاليف الخادم.';

  @override
  String get noAdsFor30Days => 'لن يتم عرض إعلانات لمدة 30 يوماً بعد التبرع.';

  @override
  String get coffeeDonation => '☕ دعم صغير';

  @override
  String get coffeeDescription => 'مساهمة بسيطة لمرة واحدة';

  @override
  String get mealDonation => '🍽️ دعم قياسي';

  @override
  String get mealDescription => 'دعم لمرة واحدة لمواصلة التحسين';

  @override
  String get generousDonation => '💎 دعم سخي';

  @override
  String get generousDescription => 'إكرامية سخية للمساعدة في تطوير التطبيق';

  @override
  String get donateButton => 'تقديم دعم';

  @override
  String get locationNotDetected => 'تعذر الحصول على الموقع. يرجى اختيار المدينة يدوياً.';

  @override
  String get failedToLoadPrayerTimes => 'فشل تحميل أوقات الصلاة. يرجى التحقق من إعدادات الموقع.';

  @override
  String get prayerTimeEntered => 'بدأ وقت الصلاة';

  @override
  String get selectCityTitle => 'Select City';

  @override
  String get popularCitiesTitle => 'Popular Cities';

  @override
  String get citySearchHint => 'Search city...';

  @override
  String get noCityFoundMessage => 'No city found';

  @override
  String get useCurrentLocationButton => 'Use My Current Location';

  @override
  String get prayerTimesLoadFailed => 'تعذر تحميل أوقات الصلاة';

  @override
  String get loadingPrayerTimes => 'Loading prayer times...';

  @override
  String locationErrorRetry(Object error) {
    return 'Location error: $error';
  }

  @override
  String get invalidTimeInfo => 'Invalid time information';

  @override
  String get resetCounter => 'Reset';

  @override
  String get continueCounting => 'Continue';

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
  String get tomorrow => 'غدًا';

  @override
  String get tomorrowFajr => 'فجر الغد';

  @override
  String get subhanallahMeaning => 'الله منزّه عن النقصان.';

  @override
  String get alhamdulillahMeaning => 'الحمد لله.';

  @override
  String get allahuAkbarMeaning => 'الله أكبر.';

  @override
  String get laIlaheIllallahMeaning => 'لا إله إلا الله.';

  @override
  String get astagfirullahMeaning => 'أستغفر الله.';

  @override
  String get hasbunallahMeaning => 'حسبنا الله.';

  @override
  String savedLocation(Object location) {
    return 'الموقع المحفوظ: $location';
  }

  @override
  String get detectingLocation => 'جارٍ تحديد الموقع...';

  @override
  String locationPermissionActive(Object location) {
    return 'إذن الموقع مفعّل: $location';
  }

  @override
  String get locationPermissionLimited => 'إذن الموقع مغلق. قد تكون الإشعارات محدودة.';

  @override
  String locationUpdated(Object location) {
    return 'تم تحديث الموقع: $location';
  }

  @override
  String citySelected(Object location) {
    return 'تم اختيار المدينة: $location';
  }

  @override
  String get locationPermissionGranted => 'إذن الموقع مفعّل';

  @override
  String get locationPermissionPending => 'بانتظار إذن الموقع';

  @override
  String get notificationsReady => 'الإشعارات جاهزة';

  @override
  String get notificationsPending => 'بانتظار إذن الإشعارات';

  @override
  String get quickActionToday => 'اليوم';

  @override
  String get quickActionWeekly => 'عرض أسبوعي';

  @override
  String get quickActionNotifications => 'الإشعارات';

  @override
  String get locationInfoMissing => 'معلومات الموقع غير موجودة.';

  @override
  String get cityInfoMissing => 'معلومات المدينة غير موجودة.';

  @override
  String get selectLocationOrCity => 'يرجى اختيار موقع أو مدينة أولاً.';

  @override
  String get weeklyTimesUnavailable => 'تعذر جلب أوقات الصلاة الأسبوعية.';

  @override
  String get dataUnavailable => 'البيانات غير متاحة';

  @override
  String get weeklyViewTitle => 'عرض أسبوعي';

  @override
  String get refresh => 'تحديث';

  @override
  String get weeklyDataMissing => 'لا توجد بيانات أسبوعية.';

  @override
  String get noDataForDay => 'لا تتوفر بيانات لليوم المحدد.';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get monthlyLabel => 'شهري';

  @override
  String get weeklyLabel => 'أسبوعي';

  @override
  String get selectedDayTimes => 'أوقات اليوم المحدد';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationInfoLine1 => 'تصل تذكيرات الصلاة في وقتها عند تفعيلها.';

  @override
  String get notificationInfoLine2 => 'يمكنك إدارة أذونات الإشعارات من إعدادات الجهاز وتفعيل أذان الصوت.';

  @override
  String get notificationStatus => 'حالة الإشعارات';

  @override
  String get notificationPermission => 'إذن الإشعارات';

  @override
  String get permissionGranted => 'تم منح الإذن';

  @override
  String get permissionDenied => 'الإذن مرفوض';

  @override
  String get exactAlarmPermission => 'إذن التنبيه الدقيق';

  @override
  String get schedulingActive => 'الجدولة مفعّلة';

  @override
  String get exactAlarmDisabled => 'التنبيه الدقيق معطّل';

  @override
  String get soundNotification => 'إشعار صوتي';

  @override
  String get soundOn => 'صوت الأذان مفعّل';

  @override
  String get soundOff => 'الصوت معطّل';

  @override
  String get adControl => 'التحكم بالإعلانات';

  @override
  String get sdkInitialized => 'تم تهيئة الـSDK';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusWaiting => 'بانتظار التهيئة';

  @override
  String get bannerAd => 'لافتة';

  @override
  String get loaded => 'تم التحميل';

  @override
  String get notLoaded => 'غير محمّل';

  @override
  String get interstitialAd => 'إعلان انتقالي';

  @override
  String get showing => 'قيد العرض';

  @override
  String get notReady => 'غير جاهز';

  @override
  String get locationStatusOn => 'الموقع مفعّل';

  @override
  String get locationStatusOff => 'الموقع معطّل';

  @override
  String get internetStatusOn => 'الاتصال نشط';

  @override
  String get internetStatusOff => 'لا يوجد إنترنت';

  @override
  String get prayerNotificationsTitle => 'إشعارات الصلاة';

  @override
  String get prayerNotificationsSubtitle => 'إدارة وقت وحالة كل إشعار.';

  @override
  String get notificationEnabled => 'الإشعار مفعّل';

  @override
  String get notificationDisabled => 'الإشعار معطّل';

  @override
  String get notificationOptionsTitle => 'خيارات الإشعارات';

  @override
  String get notificationOptionsSubtitle => 'أوقات الصمت والتنبيه المسبق';

  @override
  String get quietHoursLabel => 'أوقات الصمت';

  @override
  String quietHoursShort(int hours) {
    return '$hours س';
  }

  @override
  String quietHoursLong(int hours) {
    return '$hours ساعة';
  }

  @override
  String get preAlert => 'تنبيه مسبق';

  @override
  String get preAlertOff => 'متوقف';

  @override
  String preAlertMinutes(int minutes) {
    return '$minutes دقيقة قبل';
  }

  @override
  String get systemTheme => 'سمة النظام';

  @override
  String get systemThemeSubtitle => 'يتبع إعدادات الجهاز';

  @override
  String get lightTheme => 'سمة فاتحة';

  @override
  String get lightThemeSubtitle => 'مظهر النهار';

  @override
  String get darkTheme => 'سمة داكنة';

  @override
  String get darkThemeSubtitle => 'مظهر الليل';
}
