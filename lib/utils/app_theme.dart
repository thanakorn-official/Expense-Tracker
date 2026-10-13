import 'package:flutter/material.dart';

class AppThemes {
  // ── โหมดสว่าง: พื้นขาวนวล การ์ดขาวขอบบาง น้ำเงิน iOS ──
  static ThemeData get lightTheme {
    const primary = Color(0xFF007AFF);
    const secondary = Color(0xFF5856D6);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, secondary: secondary, surface: Colors.white);
    return _build(
      scheme: scheme,
      scaffold: const Color(0xFFF2F2F7),
      card: Colors.white,
      border: const Color(0xFFE3E3E8),
      inputFill: const Color(0xFFF2F2F7),
      dialog: Colors.white,
      fabBg: primary,
      fabFg: Colors.white,
    );
  }

  // ── โหมดมืด: เทาเข้มระดับ iOS น้ำเงินสว่าง ──
  static ThemeData get darkTheme {
    const primary = Color(0xFF0A84FF);
    const secondary = Color(0xFF5E5CE6);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: const Color(0xFF2C2C2E),
    );
    return _build(
      scheme: scheme,
      scaffold: const Color(0xFF1C1C1E),
      card: const Color(0xFF2C2C2E),
      border: const Color(0xFF3A3A3C),
      inputFill: const Color(0xFF2C2C2E),
      dialog: const Color(0xFF2C2C2E),
      fabBg: primary,
      fabFg: Colors.white,
    );
  }

  static ThemeData getTheme(String themeKey) {
    switch (themeKey) {
      case 'dark':
        return darkTheme;
      case 'light':
      default:
        return lightTheme;
    }
  }

  // โครง component กลางของทุกธีม ให้ทุกแบบมีดีไซน์เดียวกัน ต่างกันแค่ชุดสี
  static ThemeData _build({
    required ColorScheme scheme,
    required Color scaffold,
    required Color card,
    required Color border,
    required Color inputFill,
    required Color dialog,
    required Color fabBg,
    required Color fabFg,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 0.8),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontSize: 14,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabBg,
        foregroundColor: fabFg,
        elevation: 0,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}
