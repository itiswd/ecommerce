// lib/services/admin_setup_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/user.dart' as models;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

/// خدمة إعداد حساب الأدمن (لمرة واحدة فقط)
class AdminSetupService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// التحقق من وجود حساب أدمن
  Future<bool> hasAdminAccount() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ خطأ في التحقق من وجود أدمن: $e');
      return false;
    }
  }

  /// التحقق من إعدادات النظام
  Future<bool> isSetupComplete() async {
    try {
      final doc = await _firestore.collection('settings').doc('setup').get();
      if (doc.exists) {
        return doc.data()?['adminCreated'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ خطأ في التحقق من إعدادات النظام: $e');
      return false;
    }
  }

  /// إنشاء حساب أدمن جديد (لمرة واحدة فقط)
  Future<models.User?> createAdminAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // التحقق من عدم وجود أدمن سابق
      final hasAdmin = await hasAdminAccount();
      if (hasAdmin) {
        debugPrint('⚠️ يوجد حساب أدمن بالفعل');
        throw Exception('يوجد حساب أدمن بالفعل. لا يمكن إنشاء حساب آخر.');
      }

      // إنشاء حساب Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('فشل في إنشاء حساب Firebase');
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

      // تحديث إعدادات النظام
      await _firestore.collection('settings').doc('setup').set({
        'adminCreated': true,
        'adminId': firebaseUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

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

  /// إنشاء إعدادات النظام الافتراضية
  Future<void> initializeSystemSettings() async {
    try {
      final settingsDoc = await _firestore
          .collection('settings')
          .doc('general')
          .get();

      if (!settingsDoc.exists) {
        await _firestore.collection('settings').doc('general').set({
          'appName': 'مكنتي',
          'appNameEn': 'Makanty',
          'currency': 'جنيه',
          'defaultShippingFee': 50.0,
          'freeShippingThreshold': 1000.0,
          'cashbackPercentage': 0.05,
          'minimumOrderForCashback': 500.0,
          'minimumCashbackToUse': 10.0,
          'whatsappNumber': '01000000000',
          'supportEmail': 'support@makanty.com',
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ تم إنشاء إعدادات النظام الافتراضية');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء إعدادات النظام: $e');
    }
  }

  /// إنشاء الفئات الافتراضية
  Future<void> initializeDefaultCategories() async {
    try {
      final categoriesSnapshot = await _firestore
          .collection('categories')
          .limit(1)
          .get();

      if (categoriesSnapshot.docs.isEmpty) {
        final categories = [
          {
            'name': 'ماكينات صناعي',
            'icon': 'precision_manufacturing',
            'order': 1,
          },
          {'name': 'ماكينات منزلي', 'icon': 'home_work', 'order': 2},
          {'name': 'قطع غيار', 'icon': 'build', 'order': 3},
          {'name': 'ماكينات تطريز', 'icon': 'design_services', 'order': 4},
        ];

        for (final category in categories) {
          await _firestore.collection('categories').add({
            ...category,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        debugPrint('✅ تم إنشاء الفئات الافتراضية');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الفئات: $e');
    }
  }
}
