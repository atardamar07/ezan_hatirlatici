// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Напоминатель о молитве';

  @override
  String get selectCity => 'Выберите город';

  @override
  String get searchCity => 'Поиск города...';

  @override
  String get useCurrentLocation => 'Использовать мое текущее местоположение';

  @override
  String get popularCities => 'Популярные города';

  @override
  String get noCityFound => 'Город не найден';

  @override
  String get cityNotFound => 'Город не найден';

  @override
  String get locationError => 'Не удалось получить местоположение. Пожалуйста, проверьте разрешения местоположения.';

  @override
  String locationErrorDetails(Object error) {
    return 'Ошибка получения местоположения: $error';
  }

  @override
  String get prayerTimesLoadError => 'Не удалось загрузить время молитвы. Пожалуйста, проверьте настройки местоположения.';

  @override
  String error(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get genericError => 'Ошибка:';

  @override
  String get locationPermissionError => 'Разрешение на местоположение отклонено. Пожалуйста, включите службы местоположения.';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String nextPrayer(Object prayer) {
    return 'Следующая молитва: $prayer';
  }

  @override
  String get nextPrayerSimple => 'Следующая молитва';

  @override
  String get menu => 'Меню';

  @override
  String get home => 'Главная';

  @override
  String get qiblaCompass => 'Компас Киблы';

  @override
  String get dhikrCounter => 'Счетчик зикра';

  @override
  String get donate => 'Пожертвовать';

  @override
  String get retry => 'Повторить';

  @override
  String get settings => 'Настройки';

  @override
  String get calculationMethod => 'Метод расчета';

  @override
  String get cancel => 'Отмена';

  @override
  String get selectLocation => 'Выберите местоположение';

  @override
  String get fajr => 'Фаджр';

  @override
  String get sunrise => 'Восход';

  @override
  String get dhuhr => 'Зухр';

  @override
  String get asr => 'Аср';

  @override
  String get maghrib => 'Магриб';

  @override
  String get isha => 'Иша';

  @override
  String timeRemainingHours(Object hours, Object minutes) {
    return '⏳ Осталось $hours ч $minutes мин';
  }

  @override
  String timeRemainingMinutes(Object minutes, Object seconds) {
    return '⏳ Осталось $minutes мин $seconds сек';
  }

  @override
  String timeRemainingSeconds(Object seconds) {
    return '⏳ Осталось $seconds сек';
  }

  @override
  String get timeEntered => '🕌 Время наступило';

  @override
  String get invalidTime => 'Недействительная информация о времени';

  @override
  String get qiblaDirection => 'Компас Киблы';

  @override
  String get qiblaFound => 'Вы смотрите в сторону Киблы';

  @override
  String get turnRight => 'Повернитесь направо';

  @override
  String get turnLeft => 'Повернитесь налево';

  @override
  String distanceToKaaba(Object distance) {
    return 'Расстояние до Каабы: $distance км';
  }

  @override
  String get youAreFacingQibla => 'Вы сейчас смотрите в сторону Киблы';

  @override
  String get dhikrSettings => 'Настройки зикра';

  @override
  String get selectDhikr => 'Выберите зикр';

  @override
  String get targetCount => 'Целевое количество';

  @override
  String get vibration => 'Вибрация';

  @override
  String get sound => 'Звук';

  @override
  String get save => 'Сохранить';

  @override
  String get congratulations => 'Поздравляем!';

  @override
  String completedDhikr(Object count, Object dhikr) {
    return 'Вы завершили зикр $dhikr $count раз(а)!';
  }

  @override
  String get restart => 'Начать сначала';

  @override
  String get continueText => 'Продолжить';

  @override
  String get reset => 'Сбросить';

  @override
  String get count => 'Считать';

  @override
  String get tapToCount => 'Нажмите на экран, чтобы увеличить количество зикра';

  @override
  String get donationsForWeb => 'Пожертвования доступны в мобильном приложении';

  @override
  String get donateInfo => 'Вы можете пожертвовать, используя приложение на устройстве Android или iOS.';

  @override
  String get donationTitle => 'Пожертвовать';

  @override
  String get thankYou => 'Спасибо!';

  @override
  String get donationSuccess => 'Большое спасибо за ваше пожертвование!';

  @override
  String get noAds => 'Теперь вы не будете видеть рекламу в приложении.';

  @override
  String donationFailed(Object error) {
    return 'Сбой пожертвования: $error';
  }

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get hasDonatedThanks => 'Большое спасибо за ваше пожертвование!';

  @override
  String get supportApp => 'Хотите поддержать приложение?';

  @override
  String get adFreeExperience => 'Наслаждайтесь безрекламным опытом';

  @override
  String get donationInfoText => 'Ваши пожертвования будут использованы для разработки приложения и покрытия расходов на сервер.';

  @override
  String get noAdsFor30Days => 'Реклама не будет показываться в течение 30 дней после пожертвования.';

  @override
  String get coffeeDonation => '☕ Чашка кофе';

  @override
  String get coffeeDescription => 'Угостить разработчика кофе';

  @override
  String get mealDonation => '🍽️ Еда';

  @override
  String get mealDescription => 'Угостить разработчика едой';

  @override
  String get generousDonation => '💎 Щедрое пожертвование';

  @override
  String get generousDescription => 'Поддержать разработку приложения';

  @override
  String get donateButton => 'Пожертвовать';

  @override
  String get locationNotDetected => 'Не удалось получить местоположение. Пожалуйста, выберите город вручную.';

  @override
  String get failedToLoadPrayerTimes => 'Не удалось загрузить время молитвы. Пожалуйста, проверьте настройки местоположения.';

  @override
  String get prayerTimeEntered => 'Время молитвы началось';

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
  String get prayerTimesLoadFailed => 'Не удалось загрузить время молитвы';

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
  String get tomorrow => 'Завтра';

  @override
  String get tomorrowFajr => 'Завтра Фаджр';
}
