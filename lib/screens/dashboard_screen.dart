import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // กำหนดไอคอนสำหรับแต่ละหมวดหมู่
  final Map<String, IconData> _categoryIcons = {
    'อาหาร': Icons.restaurant,
    'เดินทาง': Icons.directions_car,
    'ช้อปปิ้ง': Icons.shopping_bag,
    'บิล/ค่าใช้จ่าย': Icons.receipt,
    'เงินเดือน/รายรับ': Icons.account_balance_wallet,
    'อื่นๆ': Icons.category,
  };

  // ข้อมูลสมมติที่เพิ่มหมวดหมู่เข้าไป
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'ข้าวกะเพราหมูกรอบ',
      amount: 60,
      date: DateTime.now(),
      isExpense: true,
      category: 'อาหาร',
    ),
    TransactionModel(
      id: '2',
      title: 'เงินเดือน',
      amount: 35000,
      date: DateTime.now(),
      isExpense: false,
      category: 'เงินเดือน/รายรับ',
    ),
    TransactionModel(
      id: '3',
      title: 'ค่ากาแฟ',
      amount: 80,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isExpense: true,
      category: 'อาหาร',
    ),
  ];

  double get _totalIncome => _transactions
      .where((tx) => !tx.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get _totalExpense => _transactions
      .where((tx) => tx.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get _balance => _totalIncome - _totalExpense;

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '${NumberFormat('#,##0.00').format(amount)} ฿',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _showEditDialog(TransactionModel tx, int index) {
    final titleController = TextEditingController(text: tx.title);
    final amountController = TextEditingController(text: tx.amount.toString());
    String selectedCategory = tx.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        // ใช้ StatefulBuilder เพื่อให้อัปเดต Dropdown ได้
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('แก้ไขรายการ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // กล่องเลือกหมวดหมู่
                DropdownButtonFormField<String>(
                  value: _categoryIcons.containsKey(selectedCategory)
                      ? selectedCategory
                      : 'อื่นๆ',
                  decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                  items: _categoryIcons.keys.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcons[category],
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setStateDialog(() => selectedCategory = newValue!);
                  },
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
                    _transactions[index] = tx.copyWith(
                      title: titleController.text,
                      amount:
                          double.tryParse(amountController.text) ?? tx.amount,
                      category: selectedCategory,
                      updatedAt: DateTime.now(),
                    );
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('บันทึก'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isExpense = true;
    String selectedCategory = 'อาหาร';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'หมวดหมู่',
                      border: OutlineInputBorder(),
                    ),
                    items: _categoryIcons.keys.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _categoryIcons[category],
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setModalState(() => selectedCategory = newValue!);
                    },
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
                        onSelected: (val) =>
                            setModalState(() => isExpense = true),
                      ),
                      ChoiceChip(
                        label: const Text('รายรับ'),
                        selected: !isExpense,
                        selectedColor: Colors.green.withOpacity(0.3),
                        onSelected: (val) =>
                            setModalState(() => isExpense = false),
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
                        if (titleController.text.isEmpty ||
                            amountController.text.isEmpty)
                          return;

                        final newTx = TransactionModel(
                          id: DateTime.now().toString(),
                          title: titleController.text,
                          amount: double.tryParse(amountController.text) ?? 0.0,
                          date: DateTime.now(),
                          isExpense: isExpense,
                          category: selectedCategory,
                        );

                        setState(() => _transactions.insert(0, newTx));
                        Navigator.pop(ctx);
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
          const SizedBox(height: 24),
          if (_totalIncome == 0 && _totalExpense == 0)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'ยังไม่มีข้อมูลการทำรายการ',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    if (_totalIncome > 0)
                      PieChartSectionData(
                        color: Colors.green,
                        value: _totalIncome,
                        title:
                            'รายรับ\n${(_totalIncome / (_totalIncome + _totalExpense) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (_totalExpense > 0)
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: _totalExpense,
                        title:
                            'รายจ่าย\n${(_totalExpense / (_totalIncome + _totalExpense) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('รายรับรวม', _totalIncome, Colors.green),
              _buildSummaryItem(
                'ยอดคงเหลือ',
                _balance,
                _balance >= 0 ? Colors.blue : Colors.red,
              ),
              _buildSummaryItem('รายจ่ายรวม', _totalExpense, Colors.redAccent),
            ],
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'รายการย้อนหลัง (ปัดซ้ายเพื่อลบ)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                  child: InkWell(
                    onTap: () => _showEditDialog(tx, index),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        // ส่วนที่เปลี่ยนไป: ดึงไอคอนและสีมาแสดง
                        leading: CircleAvatar(
                          backgroundColor: tx.isExpense
                              ? Colors.redAccent.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          child: Icon(
                            _categoryIcons[tx.category] ?? Icons.category,
                            color: tx.isExpense
                                ? Colors.redAccent
                                : Colors.green,
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
