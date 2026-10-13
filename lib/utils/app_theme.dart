import 'package:flutter/material.dart';

final ValueNotifier<String> themeNotifier = ValueNotifier<String>('light');

class AppThemes {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      );

  static ThemeData get blackCatTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF2F2F7),
          secondary: Color(0xFFFFB340),
          surface: Color(0xFF121212),
          onSurface: Color(0xFFF2F2F7),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF121212),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.8),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Color(0xFFF2F2F7),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFF2F2F7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFB340),
          foregroundColor: Color(0xFF000000),
        ),
      );

  static ThemeData get glassCupTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFFFF),
          secondary: Color(0xFF64D2FF),
          surface: Color(0xFF2C2C2E),
          onSurface: Color(0xFFFFFFFF),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2C2C2E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF48484A), width: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF1C1C1E),
        ),
      );

  static ThemeData getTheme(String themeKey) {
    switch (themeKey) {
      case 'dark':
        return darkTheme;
      case 'black_cat':
        return blackCatTheme;
      case 'glass_cup':
        return glassCupTheme;
      case 'light':
      default:
        return lightTheme;
    }
  }
}
