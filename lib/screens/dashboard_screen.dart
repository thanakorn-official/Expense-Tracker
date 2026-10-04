import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  // ฟังก์ชันลบรายการ
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  // ฟังก์ชันเปิดหน้าต่างแก้ไขรายการ
  void _showEditDialog(TransactionModel tx, int index) {
    final titleController = TextEditingController(text: tx.title);
    final amountController = TextEditingController(text: tx.amount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('แก้ไขรายการ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // อัปเดตข้อมูลรายการเดิม พร้อมบันทึกเวลาแก้ไขล่าสุด
                _transactions[index] = tx.copyWith(
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? tx.amount,
                  updatedAt: DateTime.now(), // บันทึกประวัติเวลาแก้ไขตรงนี้
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันเปิดหน้าต่างเพิ่มรายการใหม่ (Bottom Sheet)
  void _showAddTransactionSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isExpense = true; // ตั้งค่าเริ่มต้นให้เป็นรายจ่าย

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // อนุญาตให้ฟอร์มขยับขึ้นเมื่อคีย์บอร์ดโผล่
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // ใช้ StatefulBuilder เพื่อให้ปุ่มสลับรายรับ-รายจ่าย อัปเดตสีได้ภายใน Bottom Sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx)
                    .viewInsets
                    .bottom, // ดันฟอร์มหนีคีย์บอร์ด
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'เพิ่มรายการใหม่',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อรายการ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'จำนวนเงิน',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('ประเภท:', style: TextStyle(fontSize: 16)),
                      ChoiceChip(
                        label: const Text('รายจ่าย'),
                        selected: isExpense,
                        selectedColor: Colors.redAccent.withOpacity(0.3),
                        onSelected: (val) {
                          setModalState(() => isExpense = true);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('รายรับ'),
                        selected: !isExpense,
                        selectedColor: Colors.green.withOpacity(0.3),
                        onSelected: (val) {
                          setModalState(() => isExpense = false);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // ป้องกันการกดบันทึกถ้ายังไม่ได้กรอกข้อมูล
                        if (titleController.text.isEmpty ||
                            amountController.text.isEmpty) {
                          return;
                        }

                        // สร้าง Object รายการใหม่
                        final newTx = TransactionModel(
                          id: DateTime.now()
                              .toString(), // ใช้เวลาปัจจุบันสร้าง ID ชั่วคราว
                          title: titleController.text,
                          amount: double.tryParse(amountController.text) ?? 0.0,
                          date: DateTime.now(),
                          isExpense: isExpense,
                        );

                        // อัปเดตหน้าจอโดยเพิ่มรายการใหม่เข้าไปไว้บนสุดของ List
                        setState(() {
                          _transactions.insert(0, newTx);
                        });

                        Navigator.pop(ctx); // ปิดหน้าต่างลง
                      },
                      child: const Text(
                        'บันทึกรายการ',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกรายรับ-รายจ่าย'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'รายการย้อนหลัง',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final formattedAmount = NumberFormat('#,##0.00')
                    .format(tx.amount);
                final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                    .format(tx.date);

                return Dismissible(
                  key: ValueKey(tx.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteTransaction(tx.id),
                  // ครอบ ListTile ด้วย GestureDetector หรือ InkWell เพื่อให้กดแก้ไขได้
                  child: InkWell(
                    onTap: () => _showEditDialog(tx, index),
                    child: Card(
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formattedDate),
                            // ตรวจสอบว่ามีประวัติการแก้ไขหรือไม่ ถ้ามีให้แสดงเพิ่ม
                            if (tx.updatedAt != null)
                              Text(
                                '(แก้ไขล่าสุด: ${DateFormat('dd/MM/yyyy HH:mm').format(tx.updatedAt!)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          '${tx.isExpense ? '-' : '+'}$formattedAmount ฿',
                          style: TextStyle(
                            color: tx.isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
