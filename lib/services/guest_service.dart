import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// โหมดผู้ใช้ทั่วไป (Guest): ไม่มีระบบบัญชี ชื่อผู้ใช้ที่ตั้งคือ ID ของ
/// พื้นที่ข้อมูล — ชื่อเดียวกันคือชุดข้อมูลเดียวกัน ต่างชื่อคือแยกกันหมด
class GuestService {
  static const _usernameKey = 'guest_username';
  static String? _username;

  static String? get username => _username;

  /// ID พื้นที่ข้อมูล อนุพันธ์จากชื่อผู้ใช้ ('/' เป็นตัวคั่น path ของ
  /// Firestore จึงต้องแทนที่ออก) — ใช้เป็น document ID ของ guests/
  static String get guestId => (_username ?? '').trim().replaceAll('/', '-');

  /// โหลดชื่อผู้ใช้จากเครื่อง คืนค่า true ถ้าเคยตั้งไว้แล้ว
  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_usernameKey);
    if (saved == null || saved.trim().isEmpty) return false;
    _username = saved;
    return true;
  }

  static Future<void> setUsername(String name) async {
    final trimmed = name.trim();
    _username = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, trimmed);
  }

  /// ย้ายรายการจากคอลเลกชันรวมเดิม 'transactions' เข้าพื้นที่ของ guest
  /// คนแรก (ทำครั้งเดียวต่อโปรเจกต์ เก็บธงไว้ที่ meta/legacyMigration)
  static Future<void> migrateLegacyTransactions() async {
    if (username == null) return;
    final fs = FirebaseFirestore.instance;
    final meta = fs.collection('meta').doc('legacyMigration');
    final metaSnap = await meta.get();
    if (metaSnap.data()?['completed'] == true) return;

    final guestDoc = fs.collection('guests').doc(guestId);
    final existing = await guestDoc.collection('transactions').limit(1).get();
    final legacy = await fs.collection('transactions').get();
    final docs = legacy.docs;

    if (existing.docs.isEmpty && docs.isNotEmpty) {
      for (var i = 0; i < docs.length; i += 400) {
        final batch = fs.batch();
        for (final doc in docs.skip(i).take(400)) {
          batch.set(
              guestDoc.collection('transactions').doc(doc.id), doc.data());
        }
        await batch.commit();
      }
    }

    await guestDoc.set({
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await meta.set({
      'completed': true,
      'migratedToGuestId': guestId,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
