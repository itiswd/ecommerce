// lib/services/customer_auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/user.dart' as models;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

/// خدمة مصادقة العملاء (تطبيق المستخدم)
class CustomerAuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Getters ====================

  auth.User? get currentUser => _firebaseAuth.currentUser;
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ==================== تسجيل الدخول كزائر ====================

  Future<models.User?> signInAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        final guestUser = models.User(
          id: user.uid,
          name: 'زائر',
          phone: '',
          isGuest: true,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(guestUser.toMap(), SetOptions(merge: true));

        debugPrint('✅ تم تسجيل الدخول كزائر: ${user.uid}');
        return guestUser;
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول كزائر: $e');
      return null;
    }
  }

  // ==================== تسجيل الدخول بالإيميل ====================

  /// إنشاء حساب عميل جديد بالإيميل والباسورد
  Future<models.User?> createCustomerAccount({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // إرسال إيميل التحقق
      await firebaseUser.sendEmailVerification();

      // إنشاء بيانات العميل في Firestore
      final customer = models.User(
        id: firebaseUser.uid,
        name: name,
        phone: phone ?? '',
        email: email,
        role: models.UserRole.customer,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(customer.toMap());

      debugPrint('✅ تم إنشاء حساب العميل: $name');
      return customer;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ خطأ Firebase Auth: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء حساب العميل: $e');
      rethrow;
    }
  }

  /// تسجيل دخول العميل بالإيميل والباسورد
  Future<models.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // التحقق من تأكيد الإيميل
      if (!firebaseUser.emailVerified) {
        debugPrint('⚠️ الإيميل غير مؤكد');
        // يمكن السماح بالدخول أو إجبار التأكيد
      }

      // جلب بيانات العميل
      final userData = await getUserData(firebaseUser.uid);

      if (userData == null) {
        // المستخدم جديد - إنشاء بياناته
        final newUser = models.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'مستخدم',
          phone: firebaseUser.phoneNumber ?? '',
          email: email,
          role: models.UserRole.customer,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        return newUser;
      }

      // تحديث آخر تسجيل دخول
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return userData;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ خطأ Firebase Auth: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل دخول العميل: $e');
      rethrow;
    }
  }

  /// إعادة إرسال إيميل التحقق
  Future<void> resendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('✅ تم إرسال إيميل التحقق');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إرسال إيميل التحقق: $e');
      rethrow;
    }
  }

  /// التحقق من تأكيد الإيميل
  Future<bool> isEmailVerified() async {
    await currentUser?.reload();
    return currentUser?.emailVerified ?? false;
  }

  // ==================== بيانات المستخدم ====================

  Future<models.User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return models.User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  Future<bool> updateUserData({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isEmpty) return true;

      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }

  // ==================== تسجيل الخروج ====================

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('✅ تم تسجيل الخروج');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
      rethrow;
    }
  }

  // ==================== إعادة تعيين كلمة المرور ====================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ تم إرسال رابط إعادة تعيين كلمة المرور');
    } catch (e) {
      debugPrint('❌ خطأ في إرسال رابط إعادة تعيين كلمة المرور: $e');
      rethrow;
    }
  }

  // ==================== حذف الحساب ====================

  Future<bool> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      debugPrint('✅ تم حذف الحساب');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف الحساب: $e');
      return false;
    }
  }
}
