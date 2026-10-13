import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

final ValueNotifier<String> themeNotifier = ValueNotifier<String>('light');
final ValueNotifier<String> languageNotifier = ValueNotifier<String>('th');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  final savedLang = prefs.getString('selected_language') ?? 'th';
  languageNotifier.value = savedLang;

  final savedTheme = prefs.getString('app_theme_mode') ?? 'light';
  // เครื่องที่เคยบันทึกธีมที่ถูกถอดออกไปแล้ว ให้กลับไปใช้โหมดสว่าง
  themeNotifier.value =
      (savedTheme == 'light' || savedTheme == 'dark') ? savedTheme : 'light';

  languageNotifier.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageNotifier.value);
  });

  themeNotifier.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_mode', themeNotifier.value);
  });

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLang, _) {
        return ValueListenableBuilder<String>(
          valueListenable: themeNotifier,
          builder: (context, currentThemeKey, _) {
            return MaterialApp(
              title: currentLang == 'th'
                  ? 'บันทึกรายรับ-รายจ่าย'
                  : 'Expense Tracker',
              debugShowCheckedModeBanner: false,
              theme: AppThemes.getTheme(currentThemeKey),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
