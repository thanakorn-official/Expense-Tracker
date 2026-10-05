import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ตั้งเวลาหน้าโหลด 2.5 วินาที แล้วให้สลับไปหน้า Dashboard
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // 1. วงกลมโหลดที่หมุนวน
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                // 2. รูปหน้าแมวดำตรงกลาง
                SizedBox(
                  width: 44,
                  height: 38,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // หูแมว
                      const Positioned(
                          top: -8,
                          left: 2,
                          child: Icon(Icons.change_history,
                              size: 20, color: Colors.black87)),
                      const Positioned(
                          top: -8,
                          right: 2,
                          child: Icon(Icons.change_history,
                              size: 20, color: Colors.black87)),
                      // โครงหน้า
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // ตาเรืองแสง
                      Positioned(
                          top: 14,
                          left: 8,
                          child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle))),
                      Positioned(
                          top: 14,
                          right: 8,
                          child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'กำลังเตรียมพร้อม...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
