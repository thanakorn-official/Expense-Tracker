import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart'; // เพิ่มบรรทัดนี้

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug สีแดงมุมขวาบน
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
