// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Напоминание о молитве';

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
  String get donate => 'Поддержать';

  @override
  String get retry => 'Повторить';

  @override
  String get settings => 'Настройки';

  @override
  String get calculationMethod => 'Метод расчета';

  @override
  String get methodDiyanetName => 'Управление по делам религии';

  @override
  String get methodDiyanetDescription => 'Официальный метод для Турции';

  @override
  String get methodMwlName => 'Мусульманская Всемирная Лига';

  @override
  String get methodMwlDescription => 'Общий международный метод';

  @override
  String get methodEgyptianName => 'Египетское Главное Управление';

  @override
  String get methodEgyptianDescription => 'Египетский метод';

  @override
  String get methodKarachiName => 'Карачи';

  @override
  String get methodKarachiDescription => 'Пакистанский метод';

  @override
  String get methodUmmAlQuraName => 'Умм аль-Кура';

  @override
  String get methodUmmAlQuraDescription => 'Саудовская Аравия';

  @override
  String get methodMoonsightingName => 'Университет исламских наук';

  @override
  String get methodMoonsightingDescription => 'Иордания / Университет исламских наук';

  @override
  String get methodTehranName => 'Институт геофизики, Тегеран';

  @override
  String get methodTehranDescription => 'Иранский метод';

  @override
  String get methodFranceName => 'Союз исламских организаций';

  @override
  String get methodFranceDescription => 'Французский метод';

  @override
  String get cancel => 'Отмена';

  @override
  String get selectLocation => 'Выберите местоположение';

  @override
  String get sabah => 'Утро';

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
  String get donationsForWeb => 'Поддержка доступна в мобильном приложении';

  @override
  String get donateInfo => 'Вы можете отправить добровольную поддержку через приложение на Android или iOS.';

  @override
  String get donationTitle => 'Поддержать';

  @override
  String get thankYou => 'Спасибо!';

  @override
  String get donationSuccess => 'Спасибо за вашу поддержку!';

  @override
  String get noAds => 'Теперь вы не будете видеть рекламу в приложении.';

  @override
  String donationFailed(Object error) {
    return 'Платёж поддержки не прошёл: $error';
  }

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get hasDonatedThanks => 'Спасибо за вашу поддержку!';

  @override
  String get supportApp => 'Хотите поддержать приложение чаевыми?';

  @override
  String get adFreeExperience => 'Наслаждайтесь безрекламным опытом';

  @override
  String get supportOptionalText => 'Поддержка полностью добровольная и не требуется для использования приложения.';

  @override
  String get donationInfoText => 'Поддержка обрабатывается через Google Play Billing и направляется на расходы по разработке.';

  @override
  String get coffeeDonation => '☕ Небольшая поддержка';

  @override
  String get coffeeDescription => 'Разовая маленькая благодарность';

  @override
  String get mealDonation => '🍽️ Стандартная поддержка';

  @override
  String get mealDescription => 'Разовая поддержка для дальнейших улучшений';

  @override
  String get generousDonation => '💎 Щедрая поддержка';

  @override
  String get generousDescription => 'Щедрые чаевые, чтобы развивать приложение';

  @override
  String get donateButton => 'Поддержать';

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
  String get searchLanguageInfo => 'Поиск использует язык приложения. Пожалуйста, вводите названия городов на выбранном языке.';

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

  @override
  String get subhanallahMeaning => 'Аллах свободен от недостатков.';

  @override
  String get alhamdulillahMeaning => 'Хвала Аллаху.';

  @override
  String get allahuAkbarMeaning => 'Аллах – величайший.';

  @override
  String get laIlaheIllallahMeaning => 'Нет божества, кроме Аллаха.';

  @override
  String get astagfirullahMeaning => 'Прошу прощения у Аллаха.';

  @override
  String get hasbunallahMeaning => 'Нам достаточно Аллаха.';

  @override
  String savedLocation(Object location) {
    return 'Сохранённое местоположение: $location';
  }

  @override
  String get detectingLocation => 'Определение местоположения...';

  @override
  String locationPermissionActive(Object location) {
    return 'Доступ к геоданным разрешён: $location';
  }

  @override
  String get locationPermissionLimited => 'Доступ к геоданным выключен. Уведомления могут быть ограничены.';

  @override
  String locationUpdated(Object location) {
    return 'Местоположение обновлено: $location';
  }

  @override
  String citySelected(Object location) {
    return 'Город выбран: $location';
  }

  @override
  String get locationPermissionGranted => 'Разрешение на местоположение активно';

  @override
  String get locationPermissionPending => 'Ожидание разрешения на местоположение';

  @override
  String get notificationsReady => 'Уведомления готовы';

  @override
  String get notificationsPending => 'Ожидается разрешение на уведомления';

  @override
  String get quickActionToday => 'Сегодня';

  @override
  String get quickActionWeekly => 'Неделя';

  @override
  String get quickActionNotifications => 'Уведомления';

  @override
  String get locationInfoMissing => 'Информация о местоположении не найдена.';

  @override
  String get cityInfoMissing => 'Информация о городе не найдена.';

  @override
  String get selectLocationOrCity => 'Сначала выберите местоположение или город.';

  @override
  String get weeklyTimesUnavailable => 'Не удалось получить недельные времена молитв.';

  @override
  String get dataUnavailable => 'Данные недоступны';

  @override
  String get weeklyViewTitle => 'Недельный вид';

  @override
  String get refresh => 'Обновить';

  @override
  String get weeklyDataMissing => 'Недельные данные не найдены.';

  @override
  String get noDataForDay => 'Нет данных для выбранного дня.';

  @override
  String get calendarTitle => 'Календарь';

  @override
  String get monthlyLabel => 'Месяц';

  @override
  String get weeklyLabel => 'Неделя';

  @override
  String get selectedDayTimes => 'Времена выбранного дня';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationInfoLine1 => 'Напоминания о намазе приходят вовремя, когда они включены.';

  @override
  String get notificationInfoLine2 => 'Управляйте разрешениями в настройках устройства и включайте звук азана.';

  @override
  String get notificationStatus => 'Статус уведомлений';

  @override
  String get notificationPermission => 'Разрешение на уведомления';

  @override
  String get permissionGranted => 'Разрешено';

  @override
  String get permissionDenied => 'Запрещено';

  @override
  String get exactAlarmPermission => 'Разрешение на точные будильники';

  @override
  String get schedulingActive => 'Планирование активно';

  @override
  String get exactAlarmDisabled => 'Точные будильники выключены';

  @override
  String get soundNotification => 'Звуковое уведомление';

  @override
  String get soundOn => 'Звук азана включён';

  @override
  String get soundOff => 'Звук выключен';

  @override
  String get adControl => 'Контроль рекламы';

  @override
  String get sdkInitialized => 'SDK инициализирован';

  @override
  String get statusReady => 'Готово';

  @override
  String get statusWaiting => 'Ожидание инициализации';

  @override
  String get bannerAd => 'Баннер';

  @override
  String get loaded => 'Загружено';

  @override
  String get notLoaded => 'Не загружено';

  @override
  String get interstitialAd => 'Межстраничная реклама';

  @override
  String get showing => 'Показывается';

  @override
  String get notReady => 'Не готово';

  @override
  String get locationStatusOn => 'Геолокация включена';

  @override
  String get locationStatusOff => 'Геолокация выключена';

  @override
  String get internetStatusOn => 'Интернет активен';

  @override
  String get internetStatusOff => 'Нет интернета';

  @override
  String get prayerNotificationsTitle => 'Уведомления о молитве';

  @override
  String get prayerNotificationsSubtitle => 'Управляйте временем и статусом каждого уведомления.';

  @override
  String get notificationEnabled => 'Уведомление включено';

  @override
  String get notificationDisabled => 'Уведомление выключено';

  @override
  String get notificationOptionsTitle => 'Параметры уведомлений';

  @override
  String get notificationOptionsSubtitle => 'Тихие часы и предварительные оповещения';

  @override
  String get quietHoursLabel => 'Тихие часы';

  @override
  String quietHoursShort(int hours) {
    return '$hours ч';
  }

  @override
  String quietHoursLong(int hours) {
    return '$hours часов';
  }

  @override
  String get preAlert => 'Предварительное оповещение';

  @override
  String get preAlertOff => 'Выкл.';

  @override
  String preAlertMinutes(int minutes) {
    return 'За $minutes мин.';
  }

  @override
  String get systemTheme => 'Тема системы';

  @override
  String get systemThemeSubtitle => 'Следовать настройкам устройства';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get lightThemeSubtitle => 'Дневной вид';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get darkThemeSubtitle => 'Ночной вид';
}
