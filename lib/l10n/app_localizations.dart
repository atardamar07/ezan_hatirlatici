import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminder'**
  String get appTitle;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city...'**
  String get searchCity;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use My Current Location'**
  String get useCurrentLocation;

  /// No description provided for @popularCities.
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCities;

  /// No description provided for @noCityFound.
  ///
  /// In en, this message translates to:
  /// **'No city found'**
  String get noCityFound;

  /// No description provided for @cityNotFound.
  ///
  /// In en, this message translates to:
  /// **'City not found'**
  String get cityNotFound;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Location could not be retrieved. Please check location permissions.'**
  String get locationError;

  /// No description provided for @locationErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String locationErrorDetails(Object error);

  /// No description provided for @prayerTimesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prayer times. Please check location settings.'**
  String get prayerTimesLoadError;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get genericError;

  /// No description provided for @locationPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please enable location services.'**
  String get locationPermissionError;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer: {prayer}'**
  String nextPrayer(Object prayer);

  /// No description provided for @nextPrayerSimple.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayerSimple;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @qiblaCompass.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaCompass;

  /// No description provided for @dhikrCounter.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Counter'**
  String get dhikrCounter;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @timeRemainingHours.
  ///
  /// In en, this message translates to:
  /// **'⏳ {hours}h {minutes}m left'**
  String timeRemainingHours(Object hours, Object minutes);

  /// No description provided for @timeRemainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'⏳ {minutes}m {seconds}s left'**
  String timeRemainingMinutes(Object minutes, Object seconds);

  /// No description provided for @timeRemainingSeconds.
  ///
  /// In en, this message translates to:
  /// **'⏳ {seconds}s left'**
  String timeRemainingSeconds(Object seconds);

  /// No description provided for @timeEntered.
  ///
  /// In en, this message translates to:
  /// **'🕌 Time has entered'**
  String get timeEntered;

  /// No description provided for @invalidTime.
  ///
  /// In en, this message translates to:
  /// **'Invalid time information'**
  String get invalidTime;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @qiblaFound.
  ///
  /// In en, this message translates to:
  /// **'You are facing Qibla'**
  String get qiblaFound;

  /// No description provided for @turnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn Right'**
  String get turnRight;

  /// No description provided for @turnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn Left'**
  String get turnLeft;

  /// No description provided for @distanceToKaaba.
  ///
  /// In en, this message translates to:
  /// **'Distance to Kaaba: {distance} km'**
  String distanceToKaaba(Object distance);

  /// No description provided for @youAreFacingQibla.
  ///
  /// In en, this message translates to:
  /// **'You are currently facing Qibla'**
  String get youAreFacingQibla;

  /// No description provided for @dhikrSettings.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Settings'**
  String get dhikrSettings;

  /// No description provided for @selectDhikr.
  ///
  /// In en, this message translates to:
  /// **'Select Dhikr'**
  String get selectDhikr;

  /// No description provided for @targetCount.
  ///
  /// In en, this message translates to:
  /// **'Target Count'**
  String get targetCount;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @completedDhikr.
  ///
  /// In en, this message translates to:
  /// **'You have completed {dhikr} {count} times!'**
  String completedDhikr(Object count, Object dhikr);

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap the screen to increase your dhikr count'**
  String get tapToCount;

  /// No description provided for @donationsForWeb.
  ///
  /// In en, this message translates to:
  /// **'Donations Available on Mobile App'**
  String get donationsForWeb;

  /// No description provided for @donateInfo.
  ///
  /// In en, this message translates to:
  /// **'You can make donations by using the app on your Android or iOS device.'**
  String get donateInfo;

  /// No description provided for @donationTitle.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donationTitle;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get thankYou;

  /// No description provided for @donationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your donation!'**
  String get donationSuccess;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see ads in the app.'**
  String get noAds;

  /// No description provided for @donationFailed.
  ///
  /// In en, this message translates to:
  /// **'Donation failed: {error}'**
  String donationFailed(Object error);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @hasDonatedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your donation!'**
  String get hasDonatedThanks;

  /// No description provided for @supportApp.
  ///
  /// In en, this message translates to:
  /// **'Would you like to support the app?'**
  String get supportApp;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your ad-free experience'**
  String get adFreeExperience;

  /// No description provided for @donationInfoText.
  ///
  /// In en, this message translates to:
  /// **'Your donations will be used for app development and server costs.'**
  String get donationInfoText;

  /// No description provided for @noAdsFor30Days.
  ///
  /// In en, this message translates to:
  /// **'No ads will be shown for 30 days after donating.'**
  String get noAdsFor30Days;

  /// No description provided for @coffeeDonation.
  ///
  /// In en, this message translates to:
  /// **'☕ A Cup of Coffee'**
  String get coffeeDonation;

  /// No description provided for @coffeeDescription.
  ///
  /// In en, this message translates to:
  /// **'Buy the developer a coffee'**
  String get coffeeDescription;

  /// No description provided for @mealDonation.
  ///
  /// In en, this message translates to:
  /// **'🍽️ A Meal'**
  String get mealDonation;

  /// No description provided for @mealDescription.
  ///
  /// In en, this message translates to:
  /// **'Buy the developer a meal'**
  String get mealDescription;

  /// No description provided for @generousDonation.
  ///
  /// In en, this message translates to:
  /// **'💎 Generous Donation'**
  String get generousDonation;

  /// No description provided for @generousDescription.
  ///
  /// In en, this message translates to:
  /// **'Support the development of the app'**
  String get generousDescription;

  /// No description provided for @donateButton.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donateButton;

  /// No description provided for @locationNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Location not detected. Please select a city manually.'**
  String get locationNotDetected;

  /// No description provided for @failedToLoadPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prayer times. Please check location settings.'**
  String get failedToLoadPrayerTimes;

  /// No description provided for @prayerTimeEntered.
  ///
  /// In en, this message translates to:
  /// **'Prayer time has started'**
  String get prayerTimeEntered;

  /// No description provided for @selectCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCityTitle;

  /// No description provided for @popularCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCitiesTitle;

  /// No description provided for @citySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city...'**
  String get citySearchHint;

  /// No description provided for @noCityFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No city found'**
  String get noCityFoundMessage;

  /// No description provided for @useCurrentLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use My Current Location'**
  String get useCurrentLocationButton;

  /// No description provided for @prayerTimesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Prayer times could not be loaded'**
  String get prayerTimesLoadFailed;

  /// No description provided for @loadingPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Loading prayer times...'**
  String get loadingPrayerTimes;

  /// No description provided for @locationErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Location error: {error}'**
  String locationErrorRetry(Object error);

  /// No description provided for @invalidTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'Invalid time information'**
  String get invalidTimeInfo;

  /// No description provided for @resetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetCounter;

  /// No description provided for @continueCounting.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCounting;

  /// No description provided for @tapToIncrement.
  ///
  /// In en, this message translates to:
  /// **'Tap to increase count'**
  String get tapToIncrement;

  /// No description provided for @prayerNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'🕌 Prayer Time'**
  String get prayerNotificationTitle;

  /// No description provided for @prayerNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{prayer} time has arrived. Time to pray!'**
  String prayerNotificationBody(Object prayer);

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'⏰ Prayer Reminder'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in {minutes} minutes'**
  String reminderNotificationBody(Object minutes, Object prayer);

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @tomorrowFajr.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow Fajr'**
  String get tomorrowFajr;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
