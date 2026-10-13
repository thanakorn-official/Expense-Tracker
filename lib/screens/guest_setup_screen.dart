import 'package:flutter/material.dart';

import '../main.dart';
import '../services/guest_service.dart';
import '../utils/l10n.dart';
import 'dashboard_screen.dart';

/// หน้าตั้งชื่อผู้ใช้ครั้งแรก (โหมดผู้ใช้ทั่วไป) — ชื่อนี้คือ ID พื้นที่ข้อมูล
class GuestSetupScreen extends StatefulWidget {
  const GuestSetupScreen({super.key});

  @override
  State<GuestSetupScreen> createState() => _GuestSetupScreenState();
}

class _GuestSetupScreenState extends State<GuestSetupScreen> {
  final _controller = TextEditingController();
  bool _busy = false;

  Future<void> _start() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(T.get('usernameEmpty'))),
      );
      return;
    }
    setState(() => _busy = true);
    await GuestService.setUsername(name);
    try {
      await GuestService.migrateLegacyTransactions();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ตัวกระปุกเงินเดิมของแอป
                    SizedBox(
                      width: 96,
                      height: 84,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned(
                            top: -10,
                            left: 4,
                            child: Icon(Icons.change_history,
                                size: 26, color: Colors.black87),
                          ),
                          const Positioned(
                            top: -10,
                            right: 4,
                            child: Icon(Icons.change_history,
                                size: 26, color: Colors.black87),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 12,
                            child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle)),
                          ),
                          Positioned(
                            top: 18,
                            right: 12,
                            child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      T.get('appTitle'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      T.get('guestTagline'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _start(),
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: T.get('usernameLabel'),
                        prefixIcon: const Icon(Icons.person_outline),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _start,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(T.get('startButton'),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
