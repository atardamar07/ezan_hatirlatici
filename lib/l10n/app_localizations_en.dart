// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayer Reminder';

  @override
  String get selectCity => 'Select City';

  @override
  String get searchCity => 'Search city...';

  @override
  String get useCurrentLocation => 'Use My Current Location';

  @override
  String get popularCities => 'Popular Cities';

  @override
  String get noCityFound => 'No city found';

  @override
  String get cityNotFound => 'City not found';

  @override
  String get locationError => 'Location could not be retrieved. Please check location permissions.';

  @override
  String locationErrorDetails(Object error) {
    return 'Error getting location: $error';
  }

  @override
  String get prayerTimesLoadError => 'Failed to load prayer times. Please check location settings.';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get genericError => 'Error:';

  @override
  String get locationPermissionError => 'Location permission denied. Please enable location services.';

  @override
  String get currentLocation => 'Current Location';

  @override
  String nextPrayer(Object prayer) {
    return 'Next Prayer: $prayer';
  }

  @override
  String get nextPrayerSimple => 'Next Prayer';

  @override
  String get menu => 'Menu';

  @override
  String get home => 'Home';

  @override
  String get qiblaCompass => 'Qibla Compass';

  @override
  String get dhikrCounter => 'Dhikr Counter';

  @override
  String get donate => 'Donate';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String timeRemainingHours(Object hours, Object minutes) {
    return '⏳ ${hours}h ${minutes}m left';
  }

  @override
  String timeRemainingMinutes(Object minutes, Object seconds) {
    return '⏳ ${minutes}m ${seconds}s left';
  }

  @override
  String timeRemainingSeconds(Object seconds) {
    return '⏳ ${seconds}s left';
  }

  @override
  String get timeEntered => '🕌 Time has entered';

  @override
  String get invalidTime => 'Invalid time information';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get qiblaFound => 'You are facing Qibla';

  @override
  String get turnRight => 'Turn Right';

  @override
  String get turnLeft => 'Turn Left';

  @override
  String distanceToKaaba(Object distance) {
    return 'Distance to Kaaba: $distance km';
  }

  @override
  String get youAreFacingQibla => 'You are currently facing Qibla';

  @override
  String get dhikrSettings => 'Dhikr Settings';

  @override
  String get selectDhikr => 'Select Dhikr';

  @override
  String get targetCount => 'Target Count';

  @override
  String get vibration => 'Vibration';

  @override
  String get sound => 'Sound';

  @override
  String get save => 'Save';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String completedDhikr(Object count, Object dhikr) {
    return 'You have completed $dhikr $count times!';
  }

  @override
  String get restart => 'Restart';

  @override
  String get continueText => 'Continue';

  @override
  String get reset => 'Reset';

  @override
  String get count => 'Count';

  @override
  String get tapToCount => 'Tap the screen to increase your dhikr count';

  @override
  String get donationsForWeb => 'Support Options Available on Mobile App';

  @override
  String get donateInfo => 'You can leave an optional tip using the app on your Android or iOS device.';

  @override
  String get donationTitle => 'Support / Tip';

  @override
  String get thankYou => 'Thank You!';

  @override
  String get donationSuccess => 'Thank you for your support!';

  @override
  String get noAds => 'You will no longer see ads in the app.';

  @override
  String donationFailed(Object error) {
    return 'Support payment failed: $error';
  }

  @override
  String get errorTitle => 'Error';

  @override
  String get hasDonatedThanks => 'Thank you for your support!';

  @override
  String get supportApp => 'Would you like to leave a tip for the app?';

  @override
  String get supportOptionalText =>
      'Tips are completely optional and not required to use the app.';

  @override
  String get adFreeExperience => 'Enjoy your ad-free experience';

  @override
  String get donationInfoText =>
      'Tips are processed via Google Play Billing and help cover development and server costs.';

  @override
  String get noAdsFor30Days => 'No ads will be shown for 30 days after donating.';

  @override
  String get coffeeDonation => '☕ Small Tip';

  @override
  String get coffeeDescription => 'One-time small show of support';

  @override
  String get mealDonation => '🍽️ Standard Support';

  @override
  String get mealDescription => 'One-time support to keep improvements coming';

  @override
  String get generousDonation => '💎 Big Support';

  @override
  String get generousDescription => 'A generous tip to help grow the app';

  @override
  String get donateButton => 'Send Support';

  @override
  String get locationNotDetected => 'Location not detected. Please select a city manually.';

  @override
  String get failedToLoadPrayerTimes => 'Failed to load prayer times. Please check location settings.';

  @override
  String get prayerTimeEntered => 'Prayer time has started';

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
  String get prayerTimesLoadFailed => 'Prayer times could not be loaded';

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
  String get tomorrow => 'Tomorrow';

  @override
  String get tomorrowFajr => 'Tomorrow Fajr';

  @override
  String get subhanallahMeaning => 'Allah is free from imperfections.';

  @override
  String get alhamdulillahMeaning => 'Praise be to Allah.';

  @override
  String get allahuAkbarMeaning => 'Allah is the Greatest.';

  @override
  String get laIlaheIllallahMeaning => 'There is no deity except Allah.';

  @override
  String get astagfirullahMeaning => 'I seek forgiveness from Allah.';

  @override
  String get hasbunallahMeaning => 'Allah is sufficient for us.';

  @override
  String savedLocation(Object location) {
    return 'Saved location: $location';
  }

  @override
  String get detectingLocation => 'Detecting location...';

  @override
  String locationPermissionActive(Object location) {
    return 'Location permission active: $location';
  }

  @override
  String get locationPermissionLimited => 'Location permission is off. Notifications may be limited.';

  @override
  String locationUpdated(Object location) {
    return 'Location updated: $location';
  }

  @override
  String citySelected(Object location) {
    return 'City selected: $location';
  }

  @override
  String get locationPermissionGranted => 'Location permission active';

  @override
  String get locationPermissionPending => 'Waiting for location permission';

  @override
  String get notificationsReady => 'Notifications ready';

  @override
  String get notificationsPending => 'Waiting for notification permission';

  @override
  String get quickActionToday => 'Today';

  @override
  String get quickActionWeekly => 'Weekly view';

  @override
  String get quickActionNotifications => 'Notifications';

  @override
  String get locationInfoMissing => 'Location information not found.';

  @override
  String get cityInfoMissing => 'City information not found.';

  @override
  String get selectLocationOrCity => 'Please select a location or city first.';

  @override
  String get weeklyTimesUnavailable => 'Weekly prayer times could not be retrieved.';

  @override
  String get dataUnavailable => 'Data unavailable';

  @override
  String get weeklyViewTitle => 'Weekly View';

  @override
  String get refresh => 'Refresh';

  @override
  String get weeklyDataMissing => 'Weekly data not found.';

  @override
  String get noDataForDay => 'No data available for the selected day.';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get monthlyLabel => 'Monthly';

  @override
  String get weeklyLabel => 'Weekly';

  @override
  String get selectedDayTimes => 'Selected day times';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationInfoLine1 => 'Prayer reminders arrive on time when you enable them.';

  @override
  String get notificationInfoLine2 => 'Manage notification permissions from device settings and enable adhan sounds.';

  @override
  String get notificationStatus => 'Notification status';

  @override
  String get notificationPermission => 'Notification permission';

  @override
  String get permissionGranted => 'Permission granted';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get exactAlarmPermission => 'Exact alarm permission';

  @override
  String get schedulingActive => 'Scheduling active';

  @override
  String get exactAlarmDisabled => 'Exact alarm disabled';

  @override
  String get soundNotification => 'Sound notification';

  @override
  String get soundOn => 'Adhan sound on';

  @override
  String get soundOff => 'Sound off';

  @override
  String get adControl => 'Ad control';

  @override
  String get sdkInitialized => 'SDK initialized';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusWaiting => 'Initialization pending';

  @override
  String get bannerAd => 'Banner';

  @override
  String get loaded => 'Loaded';

  @override
  String get notLoaded => 'Not loaded';

  @override
  String get interstitialAd => 'Interstitial';

  @override
  String get showing => 'Showing';

  @override
  String get notReady => 'Not ready';

  @override
  String get locationStatusOn => 'Location enabled';

  @override
  String get locationStatusOff => 'Location disabled';

  @override
  String get internetStatusOn => 'Internet active';

  @override
  String get internetStatusOff => 'No internet';

  @override
  String get prayerNotificationsTitle => 'Prayer notifications';

  @override
  String get prayerNotificationsSubtitle => 'Manage notification time and status for each prayer.';

  @override
  String get notificationEnabled => 'Notification on';

  @override
  String get notificationDisabled => 'Notification off';

  @override
  String get notificationOptionsTitle => 'Notification options';

  @override
  String get notificationOptionsSubtitle => 'Quiet hours and pre-alert preferences';

  @override
  String get quietHoursLabel => 'Quiet hours';

  @override
  String quietHoursShort(int hours) {
    return '$hours h';
  }

  @override
  String quietHoursLong(int hours) {
    return '$hours hours';
  }

  @override
  String get preAlert => 'Pre-alert';

  @override
  String get preAlertOff => 'Off';

  @override
  String preAlertMinutes(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String get systemTheme => 'System theme';

  @override
  String get systemThemeSubtitle => 'Follows device settings';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get lightThemeSubtitle => 'Daytime look';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get darkThemeSubtitle => 'Nighttime look';
}
