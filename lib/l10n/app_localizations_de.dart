// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Gebetszeiten-Erinnerung';

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
  String get locationError =>
      'Standort konnte nicht abgerufen werden. Bitte überprüfen Sie die Standortberechtigungen.';

  @override
  String locationErrorDetails(Object error) {
    return 'Fehler beim Abrufen des Standorts: $error';
  }

  @override
  String get prayerTimesLoadError =>
      'Gebetszeiten konnten nicht geladen werden. Bitte überprüfen Sie die Standorteinstellungen.';

  @override
  String error(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get locationPermissionError =>
      'Standortberechtigung verweigert. Bitte aktivieren Sie die Standortdienste.';

  @override
  String get currentLocation => 'Aktueller Standort';

  @override
  String nextPrayer(Object prayer) {
    return 'Nächstes Gebet: $prayer';
  }

  @override
  String get menu => 'Menü';

  @override
  String get home => 'Startseite';

  @override
  String get qiblaCompass => 'Qibla-Kompass';

  @override
  String get dhikrCounter => 'Dhikr-Zähler';

  @override
  String get donate => 'Spenden';

  @override
  String get retry => 'Wiederholen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get calculationMethod => 'Berechnungsmethode';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get selectLocation => 'Standort auswählen';

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
  String get tapToCount =>
      'Tippen Sie auf den Bildschirm, um Ihre Dhikr-Anzahl zu erhöhen';

  @override
  String get donationsForWeb => 'Spenden sind in der mobilen App verfügbar';

  @override
  String get donateInfo =>
      'Sie können spenden, indem Sie die App auf Ihrem Android- oder iOS-Gerät verwenden.';

  @override
  String get donationTitle => 'Spenden';

  @override
  String get thankYou => 'Vielen Dank!';

  @override
  String get donationSuccess => 'Vielen Dank für Ihre Spende!';

  @override
  String get noAds => 'Sie werden keine Anzeigen mehr in der App sehen.';

  @override
  String donationFailed(Object error) {
    return 'Spende fehlgeschlagen: $error';
  }

  @override
  String get errorTitle => 'Fehler';

  @override
  String get hasDonatedThanks => 'Vielen Dank für Ihre Spende!';

  @override
  String get supportApp => 'Möchten Sie die App unterstützen?';

  @override
  String get adFreeExperience => 'Genießen Sie Ihre werbefreie Erfahrung';

  @override
  String get donationInfoText =>
      'Ihre Spenden werden für die App-Entwicklung und Serverkosten verwendet.';

  @override
  String get noAdsFor30Days =>
      'Es werden 30 Tage lang keine Anzeigen angezeigt, nachdem Sie gespendet haben.';

  @override
  String get coffeeDonation => '☕ Eine Tasse Kaffee';

  @override
  String get coffeeDescription => 'Schenken Sie dem Entwickler einen Kaffee';

  @override
  String get mealDonation => '🍽️ Eine Mahlzeit';

  @override
  String get mealDescription => 'Schenken Sie dem Entwickler eine Mahlzeit';

  @override
  String get generousDonation => '💎 Großzügige Spende';

  @override
  String get generousDescription => 'Unterstützen Sie die Entwicklung der App';

  @override
  String get donateButton => 'Spenden';

  @override
  String get locationNotDetected =>
      'Standort nicht erkannt. Bitte wählen Sie eine Stadt manuell aus.';

  @override
  String get failedToLoadPrayerTimes =>
      'Gebetszeiten konnten nicht geladen werden. Bitte überprüfen Sie die Standorteinstellungen.';

  @override
  String get genericError => 'Fehler:';

  @override
  String get qibla => 'Qibla-Kompass';

  @override
  String get zikirmatik => 'Dhikr-Zähler';

  @override
  String get prayerTimesLoadFailed =>
      'Gebetszeiten konnten nicht geladen werden';

  @override
  String get nextPrayerSimple => 'Nächstes Gebet';
}
