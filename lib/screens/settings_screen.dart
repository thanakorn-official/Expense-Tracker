import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/l10n.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ครอบด้วย ValueListenableBuilder เพื่อให้หน้าตั้งค่าเปลี่ยนภาษาทันทีที่เลือก
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(T.get('settings')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 8),
              // --- เมนูตั้งค่าภาษา ---
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(T.get('language')),
                trailing: DropdownButton<String>(
                  value: lang,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'th', child: Text('ภาษาไทย (TH)')),
                    DropdownMenuItem(value: 'en', child: Text('English (EN)')),
                  ],
                  onChanged: (val) {
                    if (val != null) languageNotifier.value = val;
                  },
                ),
              ),
              const Divider(),

              // --- เมนูตั้งค่าธีม ---
              ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, currentMode, child) {
                    return ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(T.get('theme')),
                      trailing: DropdownButton<ThemeMode>(
                        value: currentMode,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(T.get('System'))),
                          DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(T.get('Light Theme'))),
                          DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(T.get('Dark Theme'))),
                        ],
                        onChanged: (val) {
                          if (val != null) themeNotifier.value = val;
                        },
                      ),
                    );
                  }),
              const Divider(),

              // --- เมนู About (หน้าต่างป๊อปอัพลิขสิทธิ์) ---
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(T.get('about')),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset(
                      'assets/logo.png',
                      width: 60,
                      height: 60,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.account_balance_wallet, size: 60),
                    ),
                    applicationName: T.get('appTitle'),
                    applicationVersion: T.get('app_version'),
                    applicationLegalese: '© 2026 Expense Tracker App',
                    children: [
                      const SizedBox(height: 16),
                      Text(T.get('about_desc')),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
