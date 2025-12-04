// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Gebetserinnerung';

  @override
  String get selectCity => 'Stadt auswählen';

  @override
  String get searchCity => 'Stadt suchen...';

  @override
  String get useCurrentLocation => 'Meinen aktuellen Standort verwenden';

  @override
  String get popularCities => 'Beliebte Städte';

  @override
  String get noCityFound => 'Stadt nicht gefunden';

  @override
  String get cityNotFound => 'Stadt nicht gefunden';

  @override
  String get locationError => 'Standort konnte nicht abgerufen werden. Bitte überprüfen Sie die Standortberechtigungen.';

  @override
  String locationErrorDetails(Object error) {
    return 'Fehler beim Abrufen des Standorts: $error';
  }

  @override
  String get prayerTimesLoadError => 'Gebetszeiten konnten nicht geladen werden. Bitte überprüfen Sie die Standorteinstellungen.';

  @override
  String error(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get genericError => 'Fehler:';

  @override
  String get locationPermissionError => 'Standortberechtigung verweigert. Bitte aktivieren Sie die Standortdienste.';

  @override
  String get currentLocation => 'Aktueller Standort';

  @override
  String nextPrayer(Object prayer) {
    return 'Nächstes Gebet: $prayer';
  }

  @override
  String get nextPrayerSimple => 'Nächstes Gebet';

  @override
  String get menu => 'Menü';

  @override
  String get home => 'Startseite';

  @override
  String get qiblaCompass => 'Qibla-Kompass';

  @override
  String get dhikrCounter => 'Dhikr-Zähler';

  @override
  String get donate => 'Unterstützen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get calculationMethod => 'Berechnungsmethode';

  @override
  String get methodDiyanetName => 'Präsidium für Religionsangelegenheiten';

  @override
  String get methodDiyanetDescription => 'Offizielle Methode für die Türkei';

  @override
  String get methodMwlName => 'Muslim World League';

  @override
  String get methodMwlDescription => 'Allgemeine internationale Methode';

  @override
  String get methodEgyptianName => 'Ägyptische Generalbehörde';

  @override
  String get methodEgyptianDescription => 'Ägyptische Methode';

  @override
  String get methodKarachiName => 'Karachi';

  @override
  String get methodKarachiDescription => 'Pakistanische Methode';

  @override
  String get methodUmmAlQuraName => 'Umm Al-Qura';

  @override
  String get methodUmmAlQuraDescription => 'Saudi-Arabien';

  @override
  String get methodMoonsightingName => 'Universität der Islamischen Wissenschaften';

  @override
  String get methodMoonsightingDescription => 'Jordanien / Universität der Islamischen Wissenschaften';

  @override
  String get methodTehranName => 'Institut für Geophysik, Teheran';

  @override
  String get methodTehranDescription => 'Iranische Methode';

  @override
  String get methodFranceName => 'Union islamischer Organisationen';

  @override
  String get methodFranceDescription => 'Französische Methode';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get selectLocation => 'Standort auswählen';

  @override
  String get sabah => 'Morgen';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sonnenaufgang';

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
    return '⏳ $hours Std $minutes Min übrig';
  }

  @override
  String timeRemainingMinutes(Object minutes, Object seconds) {
    return '⏳ $minutes Min $seconds Sek übrig';
  }

  @override
  String timeRemainingSeconds(Object seconds) {
    return '⏳ $seconds Sek übrig';
  }

  @override
  String get timeEntered => '🕌 Zeit ist eingetreten';

  @override
  String get invalidTime => 'Ungültige Zeitinformationen';

  @override
  String get qiblaDirection => 'Qibla-Richtung';

  @override
  String get qiblaFound => 'Sie schauen in Richtung Qibla';

  @override
  String get turnRight => 'Drehen Sie sich nach rechts';

  @override
  String get turnLeft => 'Drehen Sie sich nach links';

  @override
  String distanceToKaaba(Object distance) {
    return 'Entfernung zur Kaaba: $distance km';
  }

  @override
  String get youAreFacingQibla => 'Sie schauen jetzt in Richtung Qibla';

  @override
  String get dhikrSettings => 'Dhikr-Einstellungen';

  @override
  String get selectDhikr => 'Dhikr auswählen';

  @override
  String get targetCount => 'Zielanzahl';

  @override
  String get vibration => 'Vibration';

  @override
  String get sound => 'Ton';

  @override
  String get save => 'Speichern';

  @override
  String get congratulations => 'Herzlichen Glückwunsch!';

  @override
  String completedDhikr(Object count, Object dhikr) {
    return 'Sie haben Dhikr $dhikr $count Mal abgeschlossen!';
  }

  @override
  String get restart => 'Neu starten';

  @override
  String get continueText => 'Weitermachen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get count => 'Zählen';

  @override
  String get tapToCount => 'Tippen Sie auf den Bildschirm, um Ihre Dhikr-Anzahl zu erhöhen';

  @override
  String get donationsForWeb => 'Unterstützung ist in der mobilen App verfügbar';

  @override
  String get donateInfo => 'Du kannst eine freiwillige Unterstützung über die Android- oder iOS-App senden.';

  @override
  String get donationTitle => 'App unterstützen';

  @override
  String get thankYou => 'Vielen Dank!';

  @override
  String get donationSuccess => 'Vielen Dank für deine Unterstützung!';

  @override
  String get noAds => 'Sie werden keine Anzeigen mehr in der App sehen.';

  @override
  String donationFailed(Object error) {
    return 'Unterstützung fehlgeschlagen: $error';
  }

  @override
  String get errorTitle => 'Fehler';

  @override
  String get hasDonatedThanks => 'Vielen Dank für deine Unterstützung!';

  @override
  String get supportApp => 'Möchtest du die App mit einem Trinkgeld unterstützen?';

  @override
  String get adFreeExperience => 'Genießen Sie Ihre werbefreie Erfahrung';

  @override
  String get supportOptionalText => 'Die Unterstützung ist völlig freiwillig und nicht erforderlich, um die App zu nutzen.';

  @override
  String get donationInfoText => 'Unterstützungen werden über Google Play Abrechnung abgewickelt und werden für Entwicklungskosten verwendet.';

  @override
  String get coffeeDonation => '☕ Kleine Unterstützung';

  @override
  String get coffeeDescription => 'Einmaliger kleiner Beitrag';

  @override
  String get mealDonation => '🍽️ Standard-Unterstützung';

  @override
  String get mealDescription => 'Einmalige Unterstützung für weitere Verbesserungen';

  @override
  String get generousDonation => '💎 Große Unterstützung';

  @override
  String get generousDescription => 'Großzügiges Trinkgeld, um die App auszubauen';

  @override
  String get donateButton => 'Unterstützen';

  @override
  String get locationNotDetected => 'Standort nicht erkannt. Bitte wählen Sie eine Stadt manuell aus.';

  @override
  String get failedToLoadPrayerTimes => 'Gebetszeiten konnten nicht geladen werden. Bitte überprüfen Sie die Standorteinstellungen.';

  @override
  String get prayerTimeEntered => 'Gebetszeit hat begonnen';

  @override
  String get selectCityTitle => 'Select City';

  @override
  String get popularCitiesTitle => 'Popular Cities';

  @override
  String get citySearchHint => 'Search city...';

  @override
  String get noCityFoundMessage => 'No city found';

  @override
  String get searchLanguageInfo => 'Die Suche verwendet die App-Sprache. Bitte gib Städtenamen in der ausgewählten Sprache ein.';

  @override
  String get useCurrentLocationButton => 'Use My Current Location';

  @override
  String get prayerTimesLoadFailed => 'Gebetszeiten konnten nicht geladen werden';

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
  String get tomorrow => 'Morgen';

  @override
  String get tomorrowFajr => 'Morgen Fadschr';

  @override
  String get subhanallahMeaning => 'Allah ist frei von Mängeln.';

  @override
  String get alhamdulillahMeaning => 'Alles Lob gebührt Allah.';

  @override
  String get allahuAkbarMeaning => 'Allah ist am größten.';

  @override
  String get laIlaheIllallahMeaning => 'Es gibt keine Gottheit außer Allah.';

  @override
  String get astagfirullahMeaning => 'Ich bitte Allah um Vergebung.';

  @override
  String get hasbunallahMeaning => 'Allah genügt uns.';

  @override
  String savedLocation(Object location) {
    return 'Gespeicherter Ort: $location';
  }

  @override
  String get detectingLocation => 'Standort wird ermittelt...';

  @override
  String locationPermissionActive(Object location) {
    return 'Standortfreigabe aktiv: $location';
  }

  @override
  String get locationPermissionLimited => 'Standortfreigabe deaktiviert. Benachrichtigungen sind ggf. eingeschränkt.';

  @override
  String locationUpdated(Object location) {
    return 'Standort aktualisiert: $location';
  }

  @override
  String citySelected(Object location) {
    return 'Stadt gewählt: $location';
  }

  @override
  String get locationPermissionGranted => 'Standortberechtigung aktiv';

  @override
  String get locationPermissionPending => 'Warten auf Standortberechtigung';

  @override
  String get notificationsReady => 'Benachrichtigungen bereit';

  @override
  String get notificationsPending => 'Benachrichtigungsberechtigung ausstehend';

  @override
  String get quickActionToday => 'Heute';

  @override
  String get quickActionWeekly => 'Wochenansicht';

  @override
  String get quickActionNotifications => 'Benachrichtigungen';

  @override
  String get locationInfoMissing => 'Standortinformationen nicht gefunden.';

  @override
  String get cityInfoMissing => 'Stadtinformationen nicht gefunden.';

  @override
  String get selectLocationOrCity => 'Bitte zuerst einen Standort oder eine Stadt wählen.';

  @override
  String get weeklyTimesUnavailable => 'Wöchentliche Gebetszeiten konnten nicht abgerufen werden.';

  @override
  String get dataUnavailable => 'Keine Daten verfügbar';

  @override
  String get weeklyViewTitle => 'Wochenansicht';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get weeklyDataMissing => 'Wöchentliche Daten nicht gefunden.';

  @override
  String get noDataForDay => 'Keine Daten für den ausgewählten Tag.';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get monthlyLabel => 'Monatlich';

  @override
  String get weeklyLabel => 'Wöchentlich';

  @override
  String get selectedDayTimes => 'Zeiten für den gewählten Tag';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationInfoLine1 => 'Gebets-Erinnerungen kommen rechtzeitig an, wenn sie aktiviert sind.';

  @override
  String get notificationInfoLine2 => 'Verwalte die Berechtigungen in den Geräteeinstellungen und aktiviere Adhan-Töne.';

  @override
  String get notificationStatus => 'Benachrichtigungsstatus';

  @override
  String get notificationPermission => 'Benachrichtigungsberechtigung';

  @override
  String get permissionGranted => 'Berechtigung erteilt';

  @override
  String get permissionDenied => 'Berechtigung verweigert';

  @override
  String get exactAlarmPermission => 'Exact-Alarm-Berechtigung';

  @override
  String get schedulingActive => 'Planung aktiv';

  @override
  String get exactAlarmDisabled => 'Exact-Alarm deaktiviert';

  @override
  String get soundNotification => 'Tonbenachrichtigung';

  @override
  String get soundOn => 'Adhan-Ton an';

  @override
  String get soundOff => 'Ton aus';

  @override
  String get adControl => 'Werbekontrolle';

  @override
  String get sdkInitialized => 'SDK initialisiert';

  @override
  String get statusReady => 'Bereit';

  @override
  String get statusWaiting => 'Initialisierung ausstehend';

  @override
  String get bannerAd => 'Banner';

  @override
  String get loaded => 'Geladen';

  @override
  String get notLoaded => 'Nicht geladen';

  @override
  String get interstitialAd => 'Interstitial';

  @override
  String get showing => 'Wird angezeigt';

  @override
  String get notReady => 'Nicht bereit';

  @override
  String get locationStatusOn => 'Standort aktiv';

  @override
  String get locationStatusOff => 'Standort deaktiviert';

  @override
  String get internetStatusOn => 'Internet aktiv';

  @override
  String get internetStatusOff => 'Kein Internet';

  @override
  String get prayerNotificationsTitle => 'Gebets-Benachrichtigungen';

  @override
  String get prayerNotificationsSubtitle => 'Verwalte Uhrzeit und Status jeder Benachrichtigung.';

  @override
  String get notificationEnabled => 'Benachrichtigung an';

  @override
  String get notificationDisabled => 'Benachrichtigung aus';

  @override
  String get notificationOptionsTitle => 'Benachrichtigungsoptionen';

  @override
  String get notificationOptionsSubtitle => 'Ruhezeiten und Vorab-Warnungen';

  @override
  String get quietHoursLabel => 'Ruhezeiten';

  @override
  String quietHoursShort(int hours) {
    return '$hours Std';
  }

  @override
  String quietHoursLong(int hours) {
    return '$hours Stunden';
  }

  @override
  String get preAlert => 'Vorab-Warnung';

  @override
  String get preAlertOff => 'Aus';

  @override
  String preAlertMinutes(int minutes) {
    return '$minutes Minuten vorher';
  }

  @override
  String get systemTheme => 'Systemdesign';

  @override
  String get systemThemeSubtitle => 'Folgt den Geräteeinstellungen';

  @override
  String get lightTheme => 'Hell';

  @override
  String get lightThemeSubtitle => 'Tagesansicht';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get darkThemeSubtitle => 'Nachtansicht';
}
