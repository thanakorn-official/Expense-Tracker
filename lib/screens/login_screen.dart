import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/auth_service.dart';
import '../utils/l10n.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;
  String? _busyProvider;

  Future<void> _signIn(
    String provider,
    Future<UserCredential> Function() method,
  ) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _busyProvider = provider;
    });
    try {
      final credential = await method();
      try {
        await AuthService.migrateLegacyTransactions(credential.user!);
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } on AuthCancelledException {
      // ผู้ใช้ปิดหน้าต่างล็อกอินเอง ไม่ต้องแจ้งเตือน
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${T.get('loginFailed')}: ${_message(e)}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyProvider = null;
        });
      }
    }
  }

  Widget _busyOrText(String provider, String label) {
    if (_busy && _busyProvider == provider) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Text(label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
  }

  String _message(Object e) {
    if (e is StateError) return e.message;
    return e.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isThai = languageNotifier.value == 'th';

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
                    const SizedBox(height: 4),
                    Text(
                      isThai ? 'KeepTang' : 'เก็บตัง',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      T.get('loginTagline'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 36),
                    // ปุ่มเข้าสู่ระบบด้วย Facebook
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _busy
                            ? null
                            : () => _signIn(
                                'facebook', AuthService.signInWithFacebook),
                        icon: const Text('f',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        label: _busyOrText('facebook', T.get('signInFacebook')),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ปุ่มเข้าสู่ระบบด้วย Google
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _busy
                            ? null
                            : () =>
                                _signIn('google', AuthService.signInWithGoogle),
                        icon: const Text('G',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4285F4))),
                        label: _busy && _busyProvider == 'google'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(T.get('signInGoogle'),
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
