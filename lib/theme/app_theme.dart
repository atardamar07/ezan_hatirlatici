import 'package:flutter/material.dart';

class AppTheme {
  static const Color _lightPrimary = Color(0xFF0BA88B);
  static const Color _lightSecondary = Color(0xFF1182A5);
  static const Color _lightBackground = Color(0xFFF4F7F6);
  static const Color _lightSurface = Colors.white;

  static const Color _darkPrimary = Color(0xFF11B2A2);
  static const Color _darkSecondary = Color(0xFF1DE9B6);
  static const Color _darkBackground = Color(0xFF0E0E17);
  static const Color _darkSurface = Color(0xFF1C1C27);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: Colors.white,
      secondary: _lightSecondary,
      onSecondary: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: _lightSurface,
      onSurface: const Color(0xFF111418),
      surfaceTint: _lightPrimary,
      background: _lightBackground,
      onBackground: const Color(0xFF111418),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      cardColor: _lightSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface.withOpacity(0.96),
        indicatorColor: colorScheme.primary.withOpacity(0.14),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: MaterialStateProperty.resolveWith(
              (states) => IconThemeData(
            color: states.contains(MaterialState.selected)
                ? colorScheme.primary
                : colorScheme.onSurface,
          ),
        ),
        labelTextStyle: MaterialStateProperty.resolveWith(
              (states) => TextStyle(
            color: states.contains(MaterialState.selected)
                ? colorScheme.primary
                : colorScheme.onSurface,
                fontWeight: states.contains(MaterialState.selected)
                    ? FontWeight.w700
                    : FontWeight.w600,
          ),
        ),
      ),
      textTheme: _textTheme(colorScheme),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: Colors.white,
      secondary: _darkSecondary,
      onSecondary: Colors.black,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      surface: _darkSurface,
      onSurface: Colors.white,
      surfaceTint: _darkPrimary,
      background: _darkBackground,
      onBackground: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: MaterialStateProperty.resolveWith(
              (states) => IconThemeData(
            color: states.contains(MaterialState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.72),
          ),
        ),
        labelTextStyle: MaterialStateProperty.resolveWith(
              (states) => TextStyle(
            color: states.contains(MaterialState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.72),
                fontWeight: states.contains(MaterialState.selected)
                    ? FontWeight.w600
                    : FontWeight.w500,
          ),
        ),
      ),
      textTheme: _textTheme(colorScheme),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    const base = TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
    );

    return base.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}