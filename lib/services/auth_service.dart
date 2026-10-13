import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ผู้ใช้ปิดหน้าต่างล็อกอินเอง ไม่ถือเป็นข้อผิดพลาด
class AuthCancelledException implements Exception {}

class AuthService {
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static Future<UserCredential> signInWithGoogle() {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});
    return _federatedSignIn(provider);
  }

  static Future<UserCredential> signInWithFacebook() {
    final provider = FacebookAuthProvider()
      ..addScope('email')
      ..addScope('public_profile');
    return _federatedSignIn(provider);
  }

  static Future<UserCredential> _federatedSignIn(AuthProvider provider) async {
    try {
      if (kIsWeb) {
        return await FirebaseAuth.instance.signInWithPopup(provider);
      }
      return await FirebaseAuth.instance.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      if (_isCancelled(e)) throw AuthCancelledException();
      throw StateError(_friendlyMessage(e));
    }
  }

  static bool _isCancelled(FirebaseAuthException e) {
    const codes = {
      'web-context-cancelled',
      'popup-closed-by-user',
      'cancelled-popup-request',
      'canceled',
      'ERROR_CANCELLED',
    };
    final code = e.code.toLowerCase();
    return codes.contains(e.code) ||
        codes.contains(code) ||
        code.contains('cancel');
  }

  static String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
      case 'credential-already-in-use':
        return 'อีเมลนี้ผูกกับวิธีเข้าสู่ระบบอื่นแล้ว';
      case 'operation-not-allowed':
        return 'ยังไม่ได้เปิด Google/Facebook ใน Firebase Authentication';
      case 'network-request-failed':
        return 'เชื่อมต่ออินเทอร์เน็ตไม่สำเร็จ';
      case 'unauthorized-domain':
        return 'โดเมนนี้ยังไม่ได้รับอนุญาตใน Firebase Authentication';
      default:
        return e.message ?? e.code;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// ย้ายรายการจากคอลเลกชันรวมเดิม 'transactions' ไปที่บัญชีแรกที่ล็อกอิน
  /// ทำครั้งเดียวทั้งระบบ เพื่อไม่ให้บัญชีใหม่ได้ข้อมูลของคนอื่น
  static Future<void> migrateLegacyTransactions(User user) async {
    final fs = FirebaseFirestore.instance;
    final meta = fs.collection('meta').doc('legacyMigration');
    final metaSnap = await meta.get();
    if (metaSnap.data()?['completed'] == true) return;

    final userDoc = fs.collection('users').doc(user.uid);
    final existing = await userDoc.collection('transactions').limit(1).get();
    final legacy = await fs.collection('transactions').get();
    final docs = legacy.docs;

    if (existing.docs.isEmpty && docs.isNotEmpty) {
      for (var i = 0; i < docs.length; i += 400) {
        final batch = fs.batch();
        for (final doc in docs.skip(i).take(400)) {
          batch.set(userDoc.collection('transactions').doc(doc.id), doc.data());
        }
        await batch.commit();
      }
    }

    await userDoc.set({
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'providers': user.providerData.map((p) => p.providerId).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await meta.set({
      'completed': true,
      'migratedToUid': user.uid,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
