import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';
import '../main.dart';
import '../utils/l10n.dart';
import 'settings_screen.dart'; // นำเข้าหน้าการตั้งค่า

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

  String _groupType = 'daily';
  String _filterType = 'all';
  String _sortOrder = 'newest';

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

  Widget _buildDropdown(String value, List<String> items, IconData icon,
      ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(icon, size: 16),
          ),
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          items: items.map((String val) {
            return DropdownMenuItem(value: val, child: Text(T.get(val)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showColorPickerDialog(String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${T.get('changeColor')} "${T.get(category)}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              T.get('pickColor'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
            child: Text(T.get('close')),
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
            title: Text(T.get('edit')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: T.get('titleLabel')),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: T.get('amountLabel')),
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
                            InputDecoration(labelText: T.get('categoryLabel')),
                        items: _categoryIcons.keys.map((String category) {
                          final catColor =
                              _categoryColors[category] ?? Colors.blueGrey;
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(_categoryIcons[category],
                                    color: catColor, size: 20),
                                const SizedBox(width: 8),
                                Text(T.get(category)),
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
                      tooltip: T.get('changeColor'),
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
                child: Text(T.get('cancel')),
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
                child: Text(T.get('save')),
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
                  Text(
                    T.get('addTransaction'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: T.get('titleLabel'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: T.get('amountLabel'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: T.get('categoryLabel'),
                            border: const OutlineInputBorder(),
                          ),
                          items: _categoryIcons.keys.map((String category) {
                            final catColor =
                                _categoryColors[category] ?? Colors.blueGrey;
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(_categoryIcons[category],
                                      color: catColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(T.get(category)),
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
                        tooltip: T.get('changeColor'),
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
                      Text(T.get('typeLabel'),
                          style: const TextStyle(fontSize: 16)),
                      ChoiceChip(
                        label: Text(T.get('expense')),
                        selected: isExpense,
                        selectedColor: Colors.redAccent.withOpacity(0.3),
                        onSelected: (val) =>
                            setModalState(() => isExpense = true),
                      ),
                      ChoiceChip(
                        label: Text(T.get('income')),
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
                            amountController.text.isEmpty) return;

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
                      child: Text(T.get('save'),
                          style: const TextStyle(fontSize: 16)),
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
    // ครอบ Scaffold ด้วย ValueListenableBuilder เพื่อให้แปลภาษาได้ทั้งหน้าแบบเรียลไทม์
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(T.get('appTitle')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              // ปุ่มฟันเฟืองสำหรับเข้าหน้า Settings
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: T.get('settings'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
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
                return Center(child: Text('Error: ${snapshot.error}'));
              }

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

              List<TransactionModel> displayTransactions =
                  allTransactions.where((tx) {
                if (_filterType == 'income') return !tx.isExpense;
                if (_filterType == 'expense') return tx.isExpense;
                return true;
              }).toList();

              displayTransactions.sort((a, b) {
                if (_sortOrder == 'newest') return b.date.compareTo(a.date);
                if (_sortOrder == 'oldest') return a.date.compareTo(b.date);
                if (_sortOrder == 'highest')
                  return b.amount.compareTo(a.amount);
                if (_sortOrder == 'lowest') return a.amount.compareTo(b.amount);
                return 0;
              });

              List<dynamic> listItems = [];

              if (_groupType == 'none' || displayTransactions.isEmpty) {
                listItems = displayTransactions;
              } else {
                Map<String, List<TransactionModel>> tempMap = {};
                for (var tx in displayTransactions) {
                  String key;
                  if (_groupType == 'daily')
                    key = DateFormat('dd/MM/yyyy').format(tx.date);
                  else if (_groupType == 'monthly')
                    key = DateFormat('MM/yyyy').format(tx.date);
                  else
                    key = DateFormat('yyyy').format(tx.date);
                  tempMap.putIfAbsent(key, () => []).add(tx);
                }

                List<String> sortedKeys = tempMap.keys.toList();
                sortedKeys.sort((a, b) {
                  if (_groupType == 'daily')
                    return DateFormat('dd/MM/yyyy')
                        .parse(b)
                        .compareTo(DateFormat('dd/MM/yyyy').parse(a));
                  else if (_groupType == 'monthly')
                    return DateFormat('MM/yyyy')
                        .parse(b)
                        .compareTo(DateFormat('MM/yyyy').parse(a));
                  else
                    return int.parse(b).compareTo(int.parse(a));
                });

                if (_sortOrder == 'oldest')
                  sortedKeys = sortedKeys.reversed.toList();

                for (var key in sortedKeys) {
                  String displayHeader = key;
                  if (_groupType == 'daily')
                    displayHeader =
                        '${languageNotifier.value == 'th' ? 'วันที่' : 'Date:'} $key';
                  else if (_groupType == 'monthly')
                    displayHeader =
                        '${languageNotifier.value == 'th' ? 'เดือน' : 'Month:'} $key';
                  else
                    displayHeader =
                        '${languageNotifier.value == 'th' ? 'ปี' : 'Year:'} $key';

                  listItems.add(displayHeader);
                  listItems.addAll(tempMap[key]!);
                }
              }

              return Column(
                children: [
                  const SizedBox(height: 24),
                  if (allTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(T.get('noData'),
                          style: const TextStyle(color: Colors.grey)),
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
                                  categoryTotals[tx.category] =
                                      (categoryTotals[tx.category] ?? 0.0) +
                                          tx.amount;
                                }
                                double totalSum = categoryTotals.values
                                    .fold(0.0, (a, b) => a + b);

                                return categoryTotals.entries.map((entry) {
                                  final category = entry.key;
                                  final amount = entry.value;
                                  final percentage = totalSum > 0
                                      ? (amount / totalSum * 100)
                                      : 0.0;
                                  final color = _categoryColors[category] ??
                                      Colors.blueGrey;

                                  // เช็คว่าพื้นที่เปอร์เซ็นต์มากพอที่จะแสดงไอคอนหรือไม่ (>= 6%)
                                  final bool showIcon = percentage >= 6.0;

                                  return PieChartSectionData(
                                    color: color,
                                    value: amount,
                                    title: '',
                                    radius: 65,
                                    badgeWidget: showIcon
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  _categoryIcons[category] ??
                                                      Icons.category,
                                                  color: Colors.white,
                                                  size: 18),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${percentage.toStringAsFixed(0)}%',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
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
                      _buildSummaryItem(
                          T.get('totalIncome'), totalIncome, Colors.green),
                      _buildSummaryItem(T.get('balance'), balance,
                          balance >= 0 ? Colors.blue : Colors.red),
                      _buildSummaryItem(T.get('totalExpense'), totalExpense,
                          Colors.redAccent),
                    ],
                  ),
                  const Divider(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(T.get('history'),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(T.get('swipeToDelete'),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _buildDropdown(
                                _groupType,
                                ['daily', 'monthly', 'yearly', 'none'],
                                Icons.date_range,
                                (val) => setState(() => _groupType = val!)),
                            _buildDropdown(
                                _filterType,
                                ['all', 'income', 'expense'],
                                Icons.filter_list,
                                (val) => setState(() => _filterType = val!)),
                            _buildDropdown(
                                _sortOrder,
                                ['newest', 'oldest', 'highest', 'lowest'],
                                Icons.sort,
                                (val) => setState(() => _sortOrder = val!)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: listItems.isEmpty
                        ? Center(
                            child: Text(T.get('noMatch'),
                                style: const TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: listItems.length,
                            itemBuilder: (context, index) {
                              final item = listItems[index];

                              if (item is String) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24, right: 16, top: 16, bottom: 4),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              }

                              final tx = item as TransactionModel;
                              final formattedAmount =
                                  NumberFormat('#,##0.00').format(tx.amount);
                              final formattedDate =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(tx.date);
                              final categoryColor =
                                  _categoryColors[tx.category] ??
                                      Colors.blueGrey;

                              return Dismissible(
                                key: ValueKey(tx.id),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.delete,
                                          color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(T.get('delete'),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  final deletedTx = tx;
                                  setState(() =>
                                      _pendingDeleteIds.add(deletedTx.id));
                                  bool isUndone = false;
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.only(
                                              bottom: 24, left: 16, right: 16),
                                          backgroundColor:
                                              Colors.black.withOpacity(0.75),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          duration: const Duration(seconds: 3),
                                          content: Row(
                                            children: [
                                              const Icon(Icons.info_outline,
                                                  color: Colors.white,
                                                  size: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  '${T.get('deleted')} ${deletedTx.title}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                          action: SnackBarAction(
                                            label: T.get('undo'),
                                            textColor: Colors.amberAccent,
                                            onPressed: () {
                                              isUndone = true;
                                              setState(() => _pendingDeleteIds
                                                  .remove(deletedTx.id));
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
                                        horizontal: 16, vertical: 6),
                                    child: ListTile(
                                      leading: Tooltip(
                                        message: T.get('changeColor'),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () => _showColorPickerDialog(
                                              tx.category),
                                          child: CircleAvatar(
                                            backgroundColor:
                                                categoryColor.withOpacity(0.2),
                                            child: Icon(
                                                _categoryIcons[tx.category] ??
                                                    Icons.category,
                                                color: categoryColor),
                                          ),
                                        ),
                                      ),
                                      title: Text(tx.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
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
                                                  color: Colors.orange),
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
      },
    );
  }
}
