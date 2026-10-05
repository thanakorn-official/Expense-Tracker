import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<String> languageNotifier = ValueNotifier('th');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // โหลดค่าภาษาที่บันทึกไว้ล่าสุดก่อนเปิดแอป
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('selected_language') ?? 'th';
  languageNotifier.value = savedLang;

  // บันทึกค่าลง SharedPreferences ทุกครั้งที่ภาษาเปลี่ยน
  languageNotifier.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageNotifier.value);
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
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              title: currentLang == 'th'
                  ? 'บันทึกรายรับ-รายจ่าย'
                  : 'Expense Tracker',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: Brightness.light),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: Brightness.dark),
                useMaterial3: true,
              ),
              themeMode: currentMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
