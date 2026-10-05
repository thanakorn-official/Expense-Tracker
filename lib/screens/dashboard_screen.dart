import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, IconData> _categoryIcons = {
    'อาหาร': Icons.restaurant,
    'เดินทาง': Icons.directions_car,
    'ช้อปปิ้ง': Icons.shopping_bag,
    'บิล/ค่าใช้จ่าย': Icons.receipt,
    'เงินเดือน/รายรับ': Icons.account_balance_wallet,
    'อื่นๆ': Icons.category,
  };

  final Map<String, Color> _categoryColors = {
    'อาหาร': Colors.orange,
    'เดินทาง': Colors.blue,
    'ช้อปปิ้ง': Colors.purple,
    'บิล/ค่าใช้จ่าย': Colors.redAccent,
    'เงินเดือน/รายรับ': Colors.green,
    'อื่นๆ': Colors.teal,
  };

  final List<Color> _availableColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.redAccent,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
  ];

  final Set<String> _pendingDeleteIds = {};

  // ตัวแปรสำหรับเก็บสถานะการกรองและการจัดเรียง
  String _filterType = 'ทั้งหมด'; // ทั้งหมด, รายรับ, รายจ่าย
  String _sortOrder = 'ใหม่ล่าสุด'; // ใหม่ล่าสุด, เก่าสุด, ยอดสูงสุด, ยอดต่ำสุด

  final CollectionReference _transactionsCollection =
      FirebaseFirestore.instance.collection('transactions');

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

  void _showColorPickerDialog(String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('เปลี่ยนสีหมวดหมู่ "$category"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกสีที่ต้องการสำหรับหมวดหมู่นี้:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _categoryColors[category] == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _categoryColors[category] = color;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(TransactionModel tx) {
    final titleController = TextEditingController(text: tx.title);
    final amountController = TextEditingController(text: tx.amount.toString());
    String selectedCategory = tx.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final currentColor =
              _categoryColors[selectedCategory] ?? Colors.blueGrey;
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _categoryIcons.containsKey(selectedCategory)
                            ? selectedCategory
                            : 'อื่นๆ',
                        decoration:
                            const InputDecoration(labelText: 'หมวดหมู่'),
                        items: _categoryIcons.keys.map((String category) {
                          final catColor =
                              _categoryColors[category] ?? Colors.blueGrey;
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _categoryIcons[category],
                                  color: catColor,
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
                    ),
                    IconButton(
                      tooltip: 'เปลี่ยนสีหมวดหมู่นี้',
                      icon: Icon(Icons.palette, color: currentColor),
                      onPressed: () => _showColorPickerDialog(selectedCategory),
                    ),
                  ],
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
                  _transactionsCollection.doc(tx.id).update({
                    'title': titleController.text,
                    'amount':
                        double.tryParse(amountController.text) ?? tx.amount,
                    'category': selectedCategory,
                    'updatedAt': DateTime.now().toIso8601String(),
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
            final currentColor =
                _categoryColors[selectedCategory] ?? Colors.blueGrey;
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'หมวดหมู่',
                            border: OutlineInputBorder(),
                          ),
                          items: _categoryIcons.keys.map((String category) {
                            final catColor =
                                _categoryColors[category] ?? Colors.blueGrey;
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    _categoryIcons[category],
                                    color: catColor,
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
                      ),
                      IconButton(
                        tooltip: 'เปลี่ยนสีหมวดหมู่นี้',
                        icon: Icon(Icons.palette, color: currentColor),
                        onPressed: () =>
                            _showColorPickerDialog(selectedCategory),
                      ),
                    ],
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
                            amountController.text.isEmpty) {
                          return;
                        }

                        _transactionsCollection.add({
                          'title': titleController.text,
                          'amount':
                              double.tryParse(amountController.text) ?? 0.0,
                          'date': DateTime.now().toIso8601String(),
                          'isExpense': isExpense ? 1 : 0,
                          'category': selectedCategory,
                        });

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
      body: StreamBuilder<QuerySnapshot>(
        stream: _transactionsCollection
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          // 1. ดึงข้อมูลทั้งหมดเพื่อใช้วิเคราะห์กราฟและยอดรวม (ไม่โดนฟิลเตอร์)
          final List<TransactionModel> allTransactions = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return TransactionModel.fromMap(data);
              })
              .where((tx) => !_pendingDeleteIds.contains(tx.id))
              .toList();

          double totalIncome = allTransactions
              .where((tx) => !tx.isExpense)
              .fold(0.0, (sum, item) => sum + item.amount);
          double totalExpense = allTransactions
              .where((tx) => tx.isExpense)
              .fold(0.0, (sum, item) => sum + item.amount);
          double balance = totalIncome - totalExpense;

          // 2. คัดกรองและจัดเรียงข้อมูลเฉพาะสำหรับแสดงในรายการย้อนหลัง (ListView)
          List<TransactionModel> displayTransactions =
              allTransactions.where((tx) {
            if (_filterType == 'รายรับ') return !tx.isExpense;
            if (_filterType == 'รายจ่าย') return tx.isExpense;
            return true;
          }).toList();

          displayTransactions.sort((a, b) {
            if (_sortOrder == 'ใหม่ล่าสุด') return b.date.compareTo(a.date);
            if (_sortOrder == 'เก่าสุด') return a.date.compareTo(b.date);
            if (_sortOrder == 'ยอดสูงสุด') return b.amount.compareTo(a.amount);
            if (_sortOrder == 'ยอดต่ำสุด') return a.amount.compareTo(b.amount);
            return 0;
          });

          return Column(
            children: [
              const SizedBox(height: 24),
              if (allTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'ยังไม่มีข้อมูลการทำรายการ',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: () {
                            Map<String, double> categoryTotals = {};
                            for (var tx in allTransactions) {
                              // กราฟยังคงใช้ข้อมูลรวมทั้งหมด
                              categoryTotals[tx.category] =
                                  (categoryTotals[tx.category] ?? 0.0) +
                                      tx.amount;
                            }

                            double totalSum = categoryTotals.values.fold(
                              0.0,
                              (a, b) => a + b,
                            );

                            return categoryTotals.entries.map((entry) {
                              final category = entry.key;
                              final amount = entry.value;
                              final percentage = totalSum > 0
                                  ? (amount / totalSum * 100)
                                  : 0.0;
                              final color =
                                  _categoryColors[category] ?? Colors.blueGrey;

                              return PieChartSectionData(
                                color: color,
                                value: amount,
                                title: '',
                                radius: 65,
                                badgeWidget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _categoryIcons[category] ??
                                          Icons.category,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                badgePositionPercentageOffset: 0.5,
                              );
                            }).toList();
                          }(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('รายรับรวม', totalIncome, Colors.green),
                  _buildSummaryItem(
                    'ยอดคงเหลือ',
                    balance,
                    balance >= 0 ? Colors.blue : Colors.red,
                  ),
                  _buildSummaryItem(
                    'รายจ่ายรวม',
                    totalExpense,
                    Colors.redAccent,
                  ),
                ],
              ),
              const Divider(height: 24),
              // ส่วนควบคุม Filter และ Sort
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'รายการย้อนหลัง',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        // Dropdown แยกรับ-จ่าย
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterType,
                              isDense: true,
                              icon: const Icon(Icons.filter_list, size: 16),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              items: ['ทั้งหมด', 'รายรับ', 'รายจ่าย']
                                  .map((String val) {
                                return DropdownMenuItem(
                                    value: val, child: Text(val));
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _filterType = val!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Dropdown จัดเรียง
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortOrder,
                              isDense: true,
                              icon: const Icon(Icons.sort, size: 16),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              items: [
                                'ใหม่ล่าสุด',
                                'เก่าสุด',
                                'ยอดสูงสุด',
                                'ยอดต่ำสุด'
                              ].map((String val) {
                                return DropdownMenuItem(
                                    value: val, child: Text(val));
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _sortOrder = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '(ปัดซ้ายที่รายการเพื่อลบ)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: displayTransactions.isEmpty
                    ? const Center(
                        child: Text('ไม่มีรายการที่ตรงกับเงื่อนไข',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: displayTransactions.length,
                        itemBuilder: (context, index) {
                          // ใช้ข้อมูลจาก displayTransactions ที่ผ่านการกรองแล้ว
                          final tx = displayTransactions[index];
                          final formattedAmount =
                              NumberFormat('#,##0.00').format(tx.amount);
                          final formattedDate =
                              DateFormat('dd/MM/yyyy HH:mm').format(tx.date);
                          final categoryColor =
                              _categoryColors[tx.category] ?? Colors.blueGrey;

                          return Dismissible(
                            key: ValueKey(tx.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'ลบ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              final deletedTx = tx;

                              setState(() {
                                _pendingDeleteIds.add(deletedTx.id);
                              });

                              bool isUndone = false;
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.only(
                                          bottom: 24, left: 16, right: 16),
                                      backgroundColor:
                                          Colors.black.withOpacity(0.75),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 3),
                                      content: Row(
                                        children: [
                                          const Icon(Icons.info_outline,
                                              color: Colors.white, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'ลบ "${deletedTx.title}" แล้ว',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      action: SnackBarAction(
                                        label: 'เลิกทำ',
                                        textColor: Colors.amberAccent,
                                        onPressed: () {
                                          isUndone = true;
                                          setState(() {
                                            _pendingDeleteIds
                                                .remove(deletedTx.id);
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                  .closed
                                  .then((reason) {
                                if (!isUndone &&
                                    reason != SnackBarClosedReason.action) {
                                  _transactionsCollection
                                      .doc(deletedTx.id)
                                      .delete();
                                  _pendingDeleteIds.remove(deletedTx.id);
                                }
                              });
                            },
                            child: InkWell(
                              onTap: () => _showEditDialog(tx),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: Tooltip(
                                    message: 'แตะเพื่อเปลี่ยนสีหมวดหมู่',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () =>
                                          _showColorPickerDialog(tx.category),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            categoryColor.withOpacity(0.2),
                                        child: Icon(
                                          _categoryIcons[tx.category] ??
                                              Icons.category,
                                          color: categoryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    tx.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      color: tx.isExpense
                                          ? Colors.red
                                          : Colors.green,
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
