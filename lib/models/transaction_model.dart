class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final DateTime? updatedAt;
  final String category; // เพิ่มตัวแปรสำหรับเก็บหมวดหมู่

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.updatedAt,
    this.category = 'อื่นๆ', // ตั้งค่าเริ่มต้น
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    bool? isExpense,
    DateTime? updatedAt,
    String? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category, // โคลนค่าหมวดหมู่
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isExpense': isExpense ? 1 : 0,
      'updatedAt': updatedAt?.toIso8601String(),
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'] == 1,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      category: map['category'] ?? 'อื่นๆ',
    );
  }
}
