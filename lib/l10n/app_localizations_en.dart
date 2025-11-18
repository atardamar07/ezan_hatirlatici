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
  String get donationsForWeb => 'Donations Available on Mobile App';

  @override
  String get donateInfo => 'You can make donations by using the app on your Android or iOS device.';

  @override
  String get donationTitle => 'Donate';

  @override
  String get thankYou => 'Thank You!';

  @override
  String get donationSuccess => 'Thank you for your donation!';

  @override
  String get noAds => 'You will no longer see ads in the app.';

  @override
  String donationFailed(Object error) {
    return 'Donation failed: $error';
  }

  @override
  String get errorTitle => 'Error';

  @override
  String get hasDonatedThanks => 'Thank you for your donation!';

  @override
  String get supportApp => 'Would you like to support the app?';

  @override
  String get adFreeExperience => 'Enjoy your ad-free experience';

  @override
  String get donationInfoText => 'Your donations will be used for app development and server costs.';

  @override
  String get noAdsFor30Days => 'No ads will be shown for 30 days after donating.';

  @override
  String get coffeeDonation => '☕ A Cup of Coffee';

  @override
  String get coffeeDescription => 'Buy the developer a coffee';

  @override
  String get mealDonation => '🍽️ A Meal';

  @override
  String get mealDescription => 'Buy the developer a meal';

  @override
  String get generousDonation => '💎 Generous Donation';

  @override
  String get generousDescription => 'Support the development of the app';

  @override
  String get donateButton => 'Donate';

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
}
