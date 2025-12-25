// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/user.dart' as models;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

/// خدمة المصادقة للتعامل مع Firebase Auth و Firestore
class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Getters ====================

  /// الحصول على المستخدم الحالي من Firebase
  auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Stream للاستماع لتغييرات حالة المستخدم
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ==================== تسجيل الدخول ====================

  /// تسجيل دخول الأدمن بالإيميل والباسورد
  /// يتحقق من أن المستخدم موجود في Firestore وأنه أدمن
  Future<models.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل الدخول في Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugPrint('❌ فشل تسجيل الدخول: لا يوجد مستخدم');
        return null;
      }

      // جلب بيانات المستخدم من Firestore
      final userData = await getUserData(firebaseUser.uid);

      if (userData == null) {
        debugPrint('❌ المستخدم غير موجود في قاعدة البيانات');
        await _firebaseAuth.signOut();
        return null;
      }

      // التحقق من أن المستخدم أدمن
      if (!userData.isAdmin) {
        debugPrint('❌ المستخدم ليس أدمن');
        await _firebaseAuth.signOut();
        return null;
      }

      // تحديث آخر تسجيل دخول
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ تم تسجيل دخول الأدمن: ${userData.name}');
      return userData;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ خطأ Firebase Auth: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول: $e');
      rethrow;
    }
  }

  /// التحقق من حالة المصادقة للأدمن
  Future<models.User?> checkAdminAuthStatus() async {
    try {
      final firebaseUser = currentUser;
      if (firebaseUser == null) return null;

      final userData = await getUserData(firebaseUser.uid);
      if (userData == null || !userData.isAdmin) {
        await _firebaseAuth.signOut();
        return null;
      }

      return userData;
    } catch (e) {
      debugPrint('❌ خطأ في التحقق من حالة الأدمن: $e');
      return null;
    }
  }

  // ==================== بيانات المستخدم ====================

  /// الحصول على بيانات المستخدم من Firestore
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

  /// تحديث بيانات المستخدم
  Future<bool> updateUserData({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isEmpty) return true;

      await _firestore.collection('users').doc(userId).update(updates);
      debugPrint('✅ تم تحديث بيانات المستخدم');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }

  // ==================== إنشاء حساب أدمن ====================

  /// إنشاء حساب أدمن جديد
  Future<models.User?> createAdminAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // إنشاء حساب Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugPrint('❌ فشل إنشاء حساب Firebase');
        return null;
      }

      // إنشاء بيانات الأدمن في Firestore
      final admin = models.User(
        id: firebaseUser.uid,
        name: name,
        phone: phone,
        email: email,
        role: models.UserRole.admin,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(admin.toMap());

      debugPrint('✅ تم إنشاء حساب الأدمن بنجاح: $name');
      return admin;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ خطأ Firebase Auth: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء حساب الأدمن: $e');
      rethrow;
    }
  }

  // ==================== تسجيل الخروج ====================

  /// تسجيل الخروج
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

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ تم إرسال رابط إعادة تعيين كلمة المرور');
    } catch (e) {
      debugPrint('❌ خطأ في إرسال رابط إعادة تعيين كلمة المرور: $e');
      rethrow;
    }
  }
}
