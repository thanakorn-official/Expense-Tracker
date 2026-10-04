import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart'; // ตรวจสอบให้ชื่อแพ็กเกจตรงกับชื่อโปรเจกต์

void main() {
  testWidgets('Dashboard UI Test', (WidgetTester tester) async {
    // เรียกใช้คลาสใหม่ของเรา
    await tester.pumpWidget(const ExpenseTrackerApp());

    // ตรวจสอบว่ามีข้อความหัวข้อของหน้า Dashboard แสดงขึ้นมาหรือไม่
    expect(find.text('บันทึกรายรับ-รายจ่าย'), findsOneWidget);
  });
}
