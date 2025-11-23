import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/zikirmatik_screen.dart';
import 'screens/donation_screen.dart';
import 'screens/city_selection_screen.dart';
import 'theme/app_theme.dart';
import 'screens/weekly_view_screen.dart';
import 'screens/notification_status_screen.dart';
import 'screens/calendar_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString('themeMode');

    setState(() {
      switch (storedMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ezan Hatırlatıcı',
      debugShowCheckedModeBanner: false,

      // Dil ve Yerelleştirme Ayarları
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Desteklenen tüm locale’ler AppLocalizations üzerinden alınır
      supportedLocales: AppLocalizations.supportedLocales,

      // Kullanıcının cihaz diline göre otomatik seçim
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');

        // Tam eşleşme (dil ve ülke)
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }

        // Sadece dil koduna göre eşleşme
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }

        // Desteklenmeyen dil → İngilizce
        return const Locale('en');
      },

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(onOpenSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                currentMode: _themeMode,
                onThemeModeChanged: _setThemeMode,
              ),
            ),
          );
        }),
        '/qibla': (context) => const QiblaScreen(),
        '/zikirmatik': (context) => const ZikirmatikScreen(),
        '/donate': (context) => const DonationScreen(),
        '/city_selection': (context) => const CitySelectionScreen(),
        '/weekly_view': (context) => const WeeklyViewScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/notifications': (context) => const NotificationStatusScreen(),
      },
    );
  }
}
