import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/zikirmatik_screen.dart';
import 'screens/donation_screen.dart';
import 'screens/city_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E17),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF1B1B27),
          secondary: const Color(0xFF1DE9B6),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),

      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/qibla': (context) => const QiblaScreen(),
        '/zikirmatik': (context) => const ZikirmatikScreen(),
        '/donate': (context) => const DonationScreen(),
        '/city_selection': (context) => const CitySelectionScreen(),
      },
    );
  }
}
