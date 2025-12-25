// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ecommerce_dashboard/models/user.dart' as models;

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على المستخدم الحالي
  auth.User? get currentUser => _firebaseAuth.currentUser;

  // Stream للاستماع لتغييرات حالة المستخدم
  Stream<auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // تسجيل الدخول كزائر (Anonymous)
  Future<models.User?> signInAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        // إنشاء بيانات المستخدم في Firestore
        final guestUser = models.User(
          id: user.uid,
          name: 'زائر',
          phone: '',
          isGuest: true,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(
              guestUser.toMap(),
              SetOptions(merge: true),
            );

        debugPrint('✅ تم تسجيل الدخول كزائر: ${user.uid}');
        return guestUser;
      }

      return null;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول كزائر: $e');
      return null;
    }
  }

  // إرسال رمز التحقق OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(auth.PhoneAuthCredential credential)
        onVerificationCompleted,
    required Function(auth.FirebaseAuthException e) onVerificationFailed,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      // تأكد من أن رقم الهاتف بصيغة دولية
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+20$phoneNumber'; // +20 للأرقام المصرية
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );

      debugPrint('✅ تم إرسال رمز التحقق إلى: $formattedPhone');
    } catch (e) {
      debugPrint('❌ خطأ في إرسال رمز التحقق: $e');
      rethrow;
    }
  }

  // التحقق من رمز OTP وتسجيل الدخول
  Future<models.User?> signInWithOTP({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
  }) async {
    try {
      // إنشاء بيانات الاعتماد
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // تسجيل الدخول
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      // التحقق من وجود المستخدم في Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      models.User user;

      if (userDoc.exists) {
        // المستخدم موجود - تحديث آخر تسجيل دخول
        user = models.User.fromMap(userDoc.data()!, userDoc.id);
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLoginAt': DateTime.now(),
        });
      } else {
        // مستخدم جديد - إنشاء البيانات
        user = models.User(
          id: firebaseUser.uid,
          name: name,
          phone: phone,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(
              user.toMap(),
            );
      }

      debugPrint('✅ تم تسجيل الدخول بنجاح: ${user.name}');
      return user;
    } catch (e) {
      debugPrint('❌ خطأ في التحقق من رمز OTP: $e');
      return null;
    }
  }

  // تحويل حساب الزائر إلى حساب دائم
  Future<models.User?> linkGuestWithPhone({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
  }) async {
    try {
      final user = currentUser;
      if (user == null || !user.isAnonymous) {
        debugPrint('⚠️ المستخدم ليس زائراً');
        return null;
      }

      // إنشاء بيانات الاعتماد
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // ربط حساب الزائر برقم الهاتف
      final userCredential = await user.linkWithCredential(credential);
      final linkedUser = userCredential.user;

      if (linkedUser == null) return null;

      // تحديث بيانات المستخدم في Firestore
      final updatedUser = models.User(
        id: linkedUser.uid,
        name: name,
        phone: phone,
        isGuest: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(linkedUser.uid).set(
            updatedUser.toMap(),
            SetOptions(merge: true),
          );

      debugPrint('✅ تم تحويل الزائر إلى مستخدم دائم: $name');
      return updatedUser;
    } catch (e) {
      debugPrint('❌ خطأ في ربط حساب الزائر: $e');
      return null;
    }
  }

  // الحصول على بيانات المستخدم من Firestore
  Future<models.User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return models.User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  // تحديث بيانات المستخدم
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

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('✅ تم تسجيل الخروج');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
    }
  }

  // حذف الحساب
  Future<bool> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // حذف بيانات المستخدم من Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // حذف الحساب من Firebase Auth
      await user.delete();

      debugPrint('✅ تم حذف الحساب');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف الحساب: $e');
      return false;
    }
  }
}
