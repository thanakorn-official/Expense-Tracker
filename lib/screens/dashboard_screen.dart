import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ข้อมูลสมมติสำหรับทดสอบแสดงผล
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'ข้าวกะเพราหมูกรอบ',
      amount: 60,
      date: DateTime.now(),
      isExpense: true,
    ),
    TransactionModel(
      id: '2',
      title: 'เงินเดือน',
      amount: 35000,
      date: DateTime.now(),
      isExpense: false,
    ),
    TransactionModel(
      id: '3',
      title: 'ค่ากาแฟ',
      amount: 80,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isExpense: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกรายรับ-รายจ่าย'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // ส่วนสรุปยอด (เดี๋ยวเราจะมาทำกราฟหรือการ์ดสรุปตรงนี้เพิ่ม)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'รายการย้อนหลัง',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // ส่วนแสดงรายการ
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                // จัดรูปแบบตัวเลขและวันที่
                final formattedAmount = NumberFormat('#,##0.00')
                    .format(tx.amount);
                final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                    .format(tx.date);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.isExpense
                          ? Colors.redAccent
                          : Colors.green,
                      child: Icon(
                        tx.isExpense ? Icons.remove : Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      tx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formattedDate),
                    trailing: Text(
                      '${tx.isExpense ? '-' : '+'}$formattedAmount ฿',
                      style: TextStyle(
                        color: tx.isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ปุ่มเพิ่มรายการ (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: ทำฟังก์ชันเปิดหน้าต่างกรอกข้อมูลใหม่
          print('กดปุ่มเพิ่มรายการ');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
