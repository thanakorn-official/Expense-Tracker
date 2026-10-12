import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/transaction_model.dart';
import '../main.dart';
import '../utils/l10n.dart';
import 'settings_screen.dart';

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

  final Map<String, IconData> _paymentIcons = {
    'cash': Icons.payments_outlined,
    'promptpay': Icons.account_balance_wallet_outlined,
    'truemoney': Icons.account_balance_wallet,
    'paotang': Icons.wallet,
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
  final CollectionReference _transactionsCollection =
      FirebaseFirestore.instance.collection('transactions');

  String _groupType = 'monthly';
  String _filterType = 'all';
  String _paymentFilter = 'all';
  String _sortOrder = 'newest';

  @override
  void initState() {
    super.initState();
    _loadCustomSettings();
  }

  Future<void> _loadCustomSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final customCats = prefs.getString('custom_categories');
    if (customCats != null) {
      final Map<String, dynamic> decoded = jsonDecode(customCats);
      setState(() {
        decoded.forEach((key, value) {
          if (!_categoryIcons.containsKey(key)) {
            _categoryIcons[key] = Icons.label;
            _categoryColors[key] = Colors.blueGrey;
          }
        });
      });
    }

    final customPayments = prefs.getString('custom_payments');
    if (customPayments != null) {
      final List<dynamic> decoded = jsonDecode(customPayments);
      setState(() {
        for (var p in decoded) {
          if (!_paymentIcons.containsKey(p)) {
            _paymentIcons[p] = Icons.payment;
          }
        }
      });
    }
  }

  Future<void> _saveCustomCategory(String name) async {
    if (name.trim().isEmpty || _categoryIcons.containsKey(name)) return;
    setState(() {
      _categoryIcons[name] = Icons.label;
      _categoryColors[name] = Colors.blueGrey;
    });
    final prefs = await SharedPreferences.getInstance();
    final customKeys = _categoryIcons.keys
        .where((k) => ![
              'อาหาร',
              'เดินทาง',
              'ช้อปปิ้ง',
              'บิล/ค่าใช้จ่าย',
              'เงินเดือน/รายรับ',
              'อื่นๆ'
            ].contains(k))
        .toList();
    await prefs.setString(
        'custom_categories', jsonEncode({for (var v in customKeys) v: true}));
  }

  Future<void> _saveCustomPayment(String name) async {
    if (name.trim().isEmpty || _paymentIcons.containsKey(name)) return;
    setState(() {
      _paymentIcons[name] = Icons.payment;
    });
    final prefs = await SharedPreferences.getInstance();
    final customKeys = _paymentIcons.keys
        .where(
            (k) => !['cash', 'promptpay', 'truemoney', 'paotang'].contains(k))
        .toList();
    await prefs.setString('custom_payments', jsonEncode(customKeys));
  }

  Color _colorOf(String category) =>
      _categoryColors[category] ?? Colors.blueGrey;

  IconData _iconOf(String category) =>
      _categoryIcons[category] ?? Icons.category;

  Future<void> _showAddCategoryDialog(
      BuildContext context, StateSetter setModalState) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(T.get('addCategory')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: T.get('categoryName')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(T.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _saveCustomCategory(controller.text.trim());
                setModalState(() {});
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: Text(T.get('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentDialog(
      BuildContext context, StateSetter setModalState) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(T.get('addPayment')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: T.get('paymentName')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(T.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _saveCustomPayment(controller.text.trim());
                setModalState(() {});
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: Text(T.get('save')),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSummaryRow(double income, double expense) {
    final balance = income - expense;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(T.get('totalIncome'), income, Colors.green),
        _buildSummaryItem(
            T.get('balance'), balance, balance >= 0 ? Colors.blue : Colors.red),
        _buildSummaryItem(T.get('totalExpense'), expense, Colors.redAccent),
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
          items: items
              .map((val) =>
                  DropdownMenuItem(value: val, child: Text(T.get(val))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    List<String> paymentItems = ['all', ..._paymentIcons.keys];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildDropdown(
            _groupType,
            ['daily', 'weekly', 'monthly', 'yearly', 'none'],
            Icons.date_range,
            (val) => setState(() => _groupType = val!),
          ),
          _buildDropdown(
            _filterType,
            ['all', 'income', 'expense'],
            Icons.filter_list,
            (val) => setState(() => _filterType = val!),
          ),
          _buildDropdown(
            _paymentFilter,
            paymentItems,
            Icons.payment,
            (val) => setState(() => _paymentFilter = val!),
          ),
          _buildDropdown(
            _sortOrder,
            ['newest', 'oldest', 'highest', 'lowest'],
            Icons.sort,
            (val) => setState(() => _sortOrder = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField({
    required BuildContext context,
    required String selected,
    required ValueChanged<String?> onChanged,
    required VoidCallback onPickColor,
    required StateSetter? setModalState,
    bool outlined = false,
  }) {
    List<DropdownMenuItem<String>> categoryItems =
        _categoryIcons.keys.map((category) {
      return DropdownMenuItem<String>(
        value: category,
        child: Row(
          children: [
            Icon(_iconOf(category), color: _colorOf(category), size: 20),
            const SizedBox(width: 8),
            Text(T.get(category)),
          ],
        ),
      );
    }).toList();

    categoryItems.add(
      DropdownMenuItem<String>(
        value: '__add_new__',
        child: Text(T.get('addCustomCategory'),
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _categoryIcons.containsKey(selected) ? selected : 'อื่นๆ',
            decoration: InputDecoration(
              labelText: T.get('categoryLabel'),
              border: outlined ? const OutlineInputBorder() : null,
            ),
            items: categoryItems,
            onChanged: (val) {
              if (val == '__add_new__') {
                _showAddCategoryDialog(context, setModalState ?? setState);
              } else {
                onChanged(val);
              }
            },
          ),
        ),
        IconButton(
          tooltip: T.get('changeColor'),
          icon: Icon(Icons.palette, color: _colorOf(selected)),
          onPressed: onPickColor,
        ),
      ],
    );
  }

  Future<void> _showColorPickerDialog(String category) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${T.get('changeColor')} "${T.get(category)}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(T.get('pickColor'),
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _categoryColors[category] == color;
                return GestureDetector(
                  onTap: () {
                    setState(() => _categoryColors[category] = color);
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
              onPressed: () => Navigator.pop(ctx), child: Text(T.get('close'))),
        ],
      ),
    );
  }

  void _showEditDialog(TransactionModel tx) {
    final titleController = TextEditingController(text: tx.title);
    final amountController = TextEditingController(text: tx.amount.toString());
    String selectedCategory = tx.category;
    String selectedPaymentMethod =
        _paymentIcons.containsKey(tx.paymentMethod) ? tx.paymentMethod : 'cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          List<DropdownMenuItem<String>> paymentItems =
              _paymentIcons.keys.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Row(
                children: [
                  Icon(_paymentIcons[method] ?? Icons.payment,
                      color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(T.get(method)),
                ],
              ),
            );
          }).toList();

          paymentItems.add(
            DropdownMenuItem(
              value: '__add_new__',
              child: Text(T.get('addCustomPayment'),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          );

          return AlertDialog(
            title: Text(T.get('edit')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: titleController,
                      decoration:
                          InputDecoration(labelText: T.get('titleLabel'))),
                  const SizedBox(height: 16),
                  TextField(
                      controller: amountController,
                      decoration:
                          InputDecoration(labelText: T.get('amountLabel')),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildCategoryField(
                    context: context,
                    selected: selectedCategory,
                    setModalState: setStateDialog,
                    onChanged: (val) =>
                        setStateDialog(() => selectedCategory = val!),
                    onPickColor: () async {
                      await _showColorPickerDialog(selectedCategory);
                      setStateDialog(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    decoration:
                        InputDecoration(labelText: T.get('paymentMethodLabel')),
                    items: paymentItems,
                    onChanged: (val) {
                      if (val == '__add_new__') {
                        _showAddPaymentDialog(context, setStateDialog);
                      } else {
                        setStateDialog(() => selectedPaymentMethod = val!);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(T.get('cancel'))),
              ElevatedButton(
                onPressed: () {
                  _transactionsCollection.doc(tx.id).update({
                    'title': titleController.text,
                    'amount':
                        double.tryParse(amountController.text) ?? tx.amount,
                    'category': selectedCategory,
                    'paymentMethod': selectedPaymentMethod,
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
    String selectedPaymentMethod = 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<DropdownMenuItem<String>> paymentItems =
                _paymentIcons.keys.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Row(
                  children: [
                    Icon(_paymentIcons[method] ?? Icons.payment,
                        color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(T.get(method)),
                  ],
                ),
              );
            }).toList();

            paymentItems.add(
              DropdownMenuItem(
                value: '__add_new__',
                child: Text(T.get('addCustomPayment'),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    16,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(T.get('addTransaction'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                            labelText: T.get('titleLabel'),
                            border: const OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                            labelText: T.get('amountLabel'),
                            border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildCategoryField(
                      context: context,
                      selected: selectedCategory,
                      outlined: true,
                      setModalState: setModalState,
                      onChanged: (val) =>
                          setModalState(() => selectedCategory = val!),
                      onPickColor: () async {
                        await _showColorPickerDialog(selectedCategory);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMethod,
                      decoration: InputDecoration(
                          labelText: T.get('paymentMethodLabel'),
                          border: const OutlineInputBorder()),
                      items: paymentItems,
                      onChanged: (val) {
                        if (val == '__add_new__') {
                          _showAddPaymentDialog(context, setModalState);
                        } else {
                          setModalState(() => selectedPaymentMethod = val!);
                        }
                      },
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
                            onSelected: (_) =>
                                setModalState(() => isExpense = true)),
                        ChoiceChip(
                            label: Text(T.get('income')),
                            selected: !isExpense,
                            onSelected: (_) =>
                                setModalState(() => isExpense = false)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white),
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
                            'paymentMethod': selectedPaymentMethod,
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
              ),
            );
          },
        );
      },
    );
  }

  List<TransactionModel> _filterAndSort(List<TransactionModel> transactions) {
    final result = transactions.where((tx) {
      if (_filterType == 'income' && tx.isExpense) return false;
      if (_filterType == 'expense' && !tx.isExpense) return false;
      if (_paymentFilter != 'all' && tx.paymentMethod != _paymentFilter)
        return false;
      return true;
    }).toList();

    result.sort((a, b) {
      switch (_sortOrder) {
        case 'newest':
          return b.date.compareTo(a.date);
        case 'oldest':
          return a.date.compareTo(b.date);
        case 'highest':
          return b.amount.compareTo(a.amount);
        case 'lowest':
          return a.amount.compareTo(b.amount);
        default:
          return 0;
      }
    });
    return result;
  }

  String _groupKey(TransactionModel tx) {
    switch (_groupType) {
      case 'daily':
        return DateFormat('dd/MM/yyyy').format(tx.date);
      case 'weekly':
        final startOfWeek =
            tx.date.subtract(Duration(days: tx.date.weekday - 1));
        return DateFormat('dd/MM/yyyy').format(startOfWeek);
      case 'monthly':
        return DateFormat('MM/yyyy').format(tx.date);
      case 'yearly':
        return DateFormat('yyyy').format(tx.date);
      default:
        return DateFormat('yyyy').format(tx.date);
    }
  }

  int _compareGroupKeys(String a, String b) {
    switch (_groupType) {
      case 'daily':
      case 'weekly':
        final format = DateFormat('dd/MM/yyyy');
        return format.parse(b).compareTo(format.parse(a));
      case 'monthly':
        final format = DateFormat('MM/yyyy');
        return format.parse(b).compareTo(format.parse(a));
      case 'yearly':
        return int.parse(b).compareTo(int.parse(a));
      default:
        return 0;
    }
  }

  String _groupHeader(String key) {
    switch (_groupType) {
      case 'daily':
        return '${T.get('date_prefix')} $key';
      case 'weekly':
        final start = DateFormat('dd/MM/yyyy').parse(key);
        final end = start.add(const Duration(days: 6));
        return '${T.get('week_prefix')} $key - ${DateFormat('dd/MM/yyyy').format(end)}';
      case 'monthly':
        return '${T.get('month_prefix')} $key';
      case 'yearly':
        return '${T.get('year_prefix')} $key';
      default:
        return key;
    }
  }

  List<dynamic> _buildListItems(List<TransactionModel> transactions) {
    if (_groupType == 'none' || transactions.isEmpty) return transactions;
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      grouped.putIfAbsent(_groupKey(tx), () => []).add(tx);
    }
    var sortedKeys = grouped.keys.toList()..sort(_compareGroupKeys);
    if (_sortOrder == 'oldest') sortedKeys = sortedKeys.reversed.toList();

    final List<dynamic> items = [];
    for (final key in sortedKeys) {
      items.add(_groupHeader(key));
      items.addAll(grouped[key]!);
    }
    return items;
  }

  Widget _buildPieChart(List<TransactionModel> transactions) {
    final Map<String, double> categoryTotals = {};
    for (final tx in transactions) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0.0) + tx.amount;
    }
    final totalSum = categoryTotals.values.fold(0.0, (a, b) => a + b);

    final sections = categoryTotals.entries.map((entry) {
      final percentage = totalSum > 0 ? (entry.value / totalSum * 100) : 0.0;
      return PieChartSectionData(
        color: _colorOf(entry.key),
        value: entry.value,
        title: '',
        radius: 65,
        badgeWidget: percentage >= 6.0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconOf(entry.key), color: Colors.white, size: 18),
                  const SizedBox(height: 2),
                  Text('${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              )
            : const SizedBox.shrink(),
        badgePositionPercentageOffset: 0.5,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
            height: 200,
            child: PieChart(PieChartData(
                sectionsSpace: 2, centerSpaceRadius: 40, sections: sections))),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGroupHeaderWidget(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 4),
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary)),
    );
  }

  void _handleDelete(BuildContext context, TransactionModel tx) {
    setState(() => _pendingDeleteIds.add(tx.id));
    bool isUndone = false;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger
        .showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            backgroundColor: Colors.black.withOpacity(0.75),
            content: Text('${T.get('deleted')} ${tx.title}',
                style: const TextStyle(color: Colors.white)),
            action: SnackBarAction(
              label: T.get('undo'),
              textColor: Colors.amberAccent,
              onPressed: () {
                isUndone = true;
                setState(() => _pendingDeleteIds.remove(tx.id));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      if (!isUndone && reason != SnackBarClosedReason.action) {
        _transactionsCollection.doc(tx.id).delete();
        _pendingDeleteIds.remove(tx.id);
      }
    });
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx) {
    final formattedAmount = NumberFormat('#,##0.00').format(tx.amount);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(tx.date);
    final categoryColor = _colorOf(tx.category);

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete, color: Colors.white),
            const SizedBox(width: 8),
            Text(T.get('delete'),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onDismissed: (_) => _handleDelete(context, tx),
      child: InkWell(
        onTap: () => _showEditDialog(tx),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: categoryColor.withOpacity(0.2),
              child: Icon(_iconOf(tx.category), color: categoryColor),
            ),
            title: Text(tx.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(_paymentIcons[tx.paymentMethod] ?? Icons.payment,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(T.get(tx.paymentMethod),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            trailing: Text(
              '${tx.isExpense ? '-' : '+'}$formattedAmount ฿',
              style: TextStyle(
                  color: tx.isExpense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<TransactionModel> allTransactions) {
    List<TransactionModel> scopeTransactions = allTransactions;
    if (_groupType != 'none' && allTransactions.isNotEmpty) {
      final latestKey = _groupKey(allTransactions.first);
      scopeTransactions =
          allTransactions.where((tx) => _groupKey(tx) == latestKey).toList();
    }

    final filteredForStats = scopeTransactions.where((tx) {
      if (_filterType == 'income' && tx.isExpense) return false;
      if (_filterType == 'expense' && !tx.isExpense) return false;
      if (_paymentFilter != 'all' && tx.paymentMethod != _paymentFilter)
        return false;
      return true;
    }).toList();

    final totalIncome = filteredForStats
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = filteredForStats
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final listItems = _buildListItems(_filterAndSort(allTransactions));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              if (allTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(T.get('noData'),
                      style: const TextStyle(color: Colors.grey)),
                )
              else if (filteredForStats.isNotEmpty)
                _buildPieChart(filteredForStats),
              _buildSummaryRow(totalIncome, totalExpense),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(T.get('history'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(T.get('swipeToDelete'),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildFilterBar(),
              const SizedBox(height: 8),
            ],
          ),
        ),
        listItems.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                    child: Text(T.get('noMatch'),
                        style: const TextStyle(color: Colors.grey))),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = listItems[index];
                    if (item is String) return _buildGroupHeaderWidget(item);
                    return _buildTransactionItem(
                        context, item as TransactionModel);
                  },
                  childCount: listItems.length,
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(T.get('appTitle')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: T.get('settings'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
              ),
            ],
          ),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
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

                final allTransactions = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      return TransactionModel.fromMap(data);
                    })
                    .where((tx) => !_pendingDeleteIds.contains(tx.id))
                    .toList();

                return _buildContent(allTransactions);
              },
            ),
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
