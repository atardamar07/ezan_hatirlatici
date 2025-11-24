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
  /// **'Support Options Available on Mobile App'**
  String get donationsForWeb;

  /// No description provided for @donateInfo.
  ///
  /// In en, this message translates to:
  /// **'You can leave an optional tip using the app on your Android or iOS device.'**
  String get donateInfo;

  /// No description provided for @donationTitle.
  ///
  /// In en, this message translates to:
  /// **'Support / Tip'**
  String get donationTitle;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get thankYou;

  /// No description provided for @donationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get donationSuccess;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see ads in the app.'**
  String get noAds;

  /// No description provided for @donationFailed.
  ///
  /// In en, this message translates to:
  /// **'Support payment failed: {error}'**
  String donationFailed(Object error);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @hasDonatedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get hasDonatedThanks;

  /// No description provided for @supportApp.
  ///
  /// In en, this message translates to:
  /// **'Would you like to leave a tip for the app?'**
  String get supportApp;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your ad-free experience'**
  String get adFreeExperience;

  /// No description provided for @supportOptionalText.
  ///
  /// In en, this message translates to:
  /// **'Tips are completely optional and not required to use the app.'**
  String get supportOptionalText;

  /// No description provided for @donationInfoText.
  ///
  /// In en, this message translates to:
  /// **'Tips are processed via Google Play Billing and help cover development and server costs.'**
  String get donationInfoText;

  /// No description provided for @noAdsFor30Days.
  ///
  /// In en, this message translates to:
  /// **'No ads will be shown for 30 days after donating.'**
  String get noAdsFor30Days;

  /// No description provided for @coffeeDonation.
  ///
  /// In en, this message translates to:
  /// **'☕ Small Tip'**
  String get coffeeDonation;

  /// No description provided for @coffeeDescription.
  ///
  /// In en, this message translates to:
  /// **'One-time small show of support'**
  String get coffeeDescription;

  /// No description provided for @mealDonation.
  ///
  /// In en, this message translates to:
  /// **'🍽️ Standard Support'**
  String get mealDonation;

  /// No description provided for @mealDescription.
  ///
  /// In en, this message translates to:
  /// **'One-time support to keep improvements coming'**
  String get mealDescription;

  /// No description provided for @generousDonation.
  ///
  /// In en, this message translates to:
  /// **'💎 Big Support'**
  String get generousDonation;

  /// No description provided for @generousDescription.
  ///
  /// In en, this message translates to:
  /// **'A generous tip to help grow the app'**
  String get generousDescription;

  /// No description provided for @donateButton.
  ///
  /// In en, this message translates to:
  /// **'Send Support'**
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

  /// No description provided for @subhanallahMeaning.
  ///
  /// In en, this message translates to:
  /// **'Allah is free from imperfections.'**
  String get subhanallahMeaning;

  /// No description provided for @alhamdulillahMeaning.
  ///
  /// In en, this message translates to:
  /// **'Praise be to Allah.'**
  String get alhamdulillahMeaning;

  /// No description provided for @allahuAkbarMeaning.
  ///
  /// In en, this message translates to:
  /// **'Allah is the Greatest.'**
  String get allahuAkbarMeaning;

  /// No description provided for @laIlaheIllallahMeaning.
  ///
  /// In en, this message translates to:
  /// **'There is no deity except Allah.'**
  String get laIlaheIllallahMeaning;

  /// No description provided for @astagfirullahMeaning.
  ///
  /// In en, this message translates to:
  /// **'I seek forgiveness from Allah.'**
  String get astagfirullahMeaning;

  /// No description provided for @hasbunallahMeaning.
  ///
  /// In en, this message translates to:
  /// **'Allah is sufficient for us.'**
  String get hasbunallahMeaning;

  /// No description provided for @savedLocation.
  ///
  /// In en, this message translates to:
  /// **'Saved location: {location}'**
  String savedLocation(Object location);

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting location...'**
  String get detectingLocation;

  /// No description provided for @locationPermissionActive.
  ///
  /// In en, this message translates to:
  /// **'Location permission active: {location}'**
  String locationPermissionActive(Object location);

  /// No description provided for @locationPermissionLimited.
  ///
  /// In en, this message translates to:
  /// **'Location permission is off. Notifications may be limited.'**
  String get locationPermissionLimited;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated: {location}'**
  String locationUpdated(Object location);

  /// No description provided for @citySelected.
  ///
  /// In en, this message translates to:
  /// **'City selected: {location}'**
  String citySelected(Object location);

  /// No description provided for @locationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Location permission active'**
  String get locationPermissionGranted;

  /// No description provided for @locationPermissionPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for location permission'**
  String get locationPermissionPending;

  /// No description provided for @notificationsReady.
  ///
  /// In en, this message translates to:
  /// **'Notifications ready'**
  String get notificationsReady;

  /// No description provided for @notificationsPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for notification permission'**
  String get notificationsPending;

  /// No description provided for @quickActionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get quickActionToday;

  /// No description provided for @quickActionWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly view'**
  String get quickActionWeekly;

  /// No description provided for @quickActionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get quickActionNotifications;

  /// No description provided for @locationInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Location information not found.'**
  String get locationInfoMissing;

  /// No description provided for @cityInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'City information not found.'**
  String get cityInfoMissing;

  /// No description provided for @selectLocationOrCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a location or city first.'**
  String get selectLocationOrCity;

  /// No description provided for @weeklyTimesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weekly prayer times could not be retrieved.'**
  String get weeklyTimesUnavailable;

  /// No description provided for @dataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data unavailable'**
  String get dataUnavailable;

  /// No description provided for @weeklyViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly View'**
  String get weeklyViewTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @weeklyDataMissing.
  ///
  /// In en, this message translates to:
  /// **'Weekly data not found.'**
  String get weeklyDataMissing;

  /// No description provided for @noDataForDay.
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected day.'**
  String get noDataForDay;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @monthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyLabel;

  /// No description provided for @weeklyLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyLabel;

  /// No description provided for @selectedDayTimes.
  ///
  /// In en, this message translates to:
  /// **'Selected day times'**
  String get selectedDayTimes;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationInfoLine1.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders arrive on time when you enable them.'**
  String get notificationInfoLine1;

  /// No description provided for @notificationInfoLine2.
  ///
  /// In en, this message translates to:
  /// **'Manage notification permissions from device settings and enable adhan sounds.'**
  String get notificationInfoLine2;

  /// No description provided for @notificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Notification status'**
  String get notificationStatus;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get notificationPermission;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission'**
  String get exactAlarmPermission;

  /// No description provided for @schedulingActive.
  ///
  /// In en, this message translates to:
  /// **'Scheduling active'**
  String get schedulingActive;

  /// No description provided for @exactAlarmDisabled.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm disabled'**
  String get exactAlarmDisabled;

  /// No description provided for @soundNotification.
  ///
  /// In en, this message translates to:
  /// **'Sound notification'**
  String get soundNotification;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Adhan sound on'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Sound off'**
  String get soundOff;

  /// No description provided for @adControl.
  ///
  /// In en, this message translates to:
  /// **'Ad control'**
  String get adControl;

  /// No description provided for @sdkInitialized.
  ///
  /// In en, this message translates to:
  /// **'SDK initialized'**
  String get sdkInitialized;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Initialization pending'**
  String get statusWaiting;

  /// No description provided for @bannerAd.
  ///
  /// In en, this message translates to:
  /// **'Banner'**
  String get bannerAd;

  /// No description provided for @loaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded'**
  String get loaded;

  /// No description provided for @notLoaded.
  ///
  /// In en, this message translates to:
  /// **'Not loaded'**
  String get notLoaded;

  /// No description provided for @interstitialAd.
  ///
  /// In en, this message translates to:
  /// **'Interstitial'**
  String get interstitialAd;

  /// No description provided for @showing.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get showing;

  /// No description provided for @notReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get notReady;

  /// No description provided for @locationStatusOn.
  ///
  /// In en, this message translates to:
  /// **'Location enabled'**
  String get locationStatusOn;

  /// No description provided for @locationStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Location disabled'**
  String get locationStatusOff;

  /// No description provided for @internetStatusOn.
  ///
  /// In en, this message translates to:
  /// **'Internet active'**
  String get internetStatusOn;

  /// No description provided for @internetStatusOff.
  ///
  /// In en, this message translates to:
  /// **'No internet'**
  String get internetStatusOff;

  /// No description provided for @prayerNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer notifications'**
  String get prayerNotificationsTitle;

  /// No description provided for @prayerNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage notification time and status for each prayer.'**
  String get prayerNotificationsSubtitle;

  /// No description provided for @notificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notification on'**
  String get notificationEnabled;

  /// No description provided for @notificationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notification off'**
  String get notificationDisabled;

  /// No description provided for @notificationOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification options'**
  String get notificationOptionsTitle;

  /// No description provided for @notificationOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours and pre-alert preferences'**
  String get notificationOptionsSubtitle;

  /// No description provided for @quietHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHoursLabel;

  /// No description provided for @quietHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String quietHoursShort(int hours);

  /// No description provided for @quietHoursLong.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String quietHoursLong(int hours);

  /// No description provided for @preAlert.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert'**
  String get preAlert;

  /// No description provided for @preAlertOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get preAlertOff;

  /// No description provided for @preAlertMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String preAlertMinutes(int minutes);

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @systemThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follows device settings'**
  String get systemThemeSubtitle;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// No description provided for @lightThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daytime look'**
  String get lightThemeSubtitle;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @darkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nighttime look'**
  String get darkThemeSubtitle;
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
