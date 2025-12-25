// lib/providers/customer_auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:ecommerce_dashboard/models/user.dart' as models;
import 'package:ecommerce_dashboard/services/auth_service.dart';

class CustomerAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  models.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;
  String? _verificationId;

  // Getters
  models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _isGuest;
  String? get userId => _currentUser?.id;

  CustomerAuthProvider() {
    _initAuth();
  }

  // تهيئة المصادقة
  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // الاستماع لتغييرات حالة المستخدم
      _authService.authStateChanges.listen((auth.User? firebaseUser) async {
        if (firebaseUser != null) {
          // المستخدم مسجل دخول
          final userData = await _authService.getUserData(firebaseUser.uid);
          if (userData != null) {
            _currentUser = userData;
            _isGuest = userData.isGuest;
          }
        } else {
          // المستخدم غير مسجل دخول
          _currentUser = null;
          _isGuest = false;
        }
        notifyListeners();
      });

      // التحقق من المستخدم الحالي
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final userData = await _authService.getUserData(firebaseUser.uid);
        if (userData != null) {
          _currentUser = userData;
          _isGuest = userData.isGuest;
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة المصادقة: $e');
      _errorMessage = 'حدث خطأ في التحقق من حالة تسجيل الدخول';
    }

    _isLoading = false;
    notifyListeners();
  }

  // تسجيل الدخول كزائر
  Future<bool> signInAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInAsGuest();
      if (user != null) {
        _currentUser = user;
        _isGuest = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'فشل تسجيل الدخول كزائر';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // إرسال رمز التحقق
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        onVerificationCompleted: (auth.PhoneAuthCredential credential) async {
          // التحقق تم تلقائياً (Android only)
          debugPrint('✅ تم التحقق تلقائياً');
          _isLoading = false;
          notifyListeners();
        },
        onVerificationFailed: (auth.FirebaseAuthException e) {
          _errorMessage = _getErrorMessage(e.code);
          _isLoading = false;
          notifyListeners();
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إرسال الرمز: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // التحقق من رمز OTP وتسجيل الدخول
  Future<bool> verifyOTP({
    required String otp,
    required String name,
    required String phone,
  }) async {
    if (_verificationId == null) {
      _errorMessage = 'لم يتم إرسال رمز التحقق';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: otp,
        name: name,
        phone: phone,
      );

      if (user != null) {
        _currentUser = user;
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'رمز التحقق غير صحيح';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ في التحقق من الرمز: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // تحويل الزائر إلى مستخدم دائم
  Future<bool> linkGuestAccount({
    required String name,
    required String phone,
  }) async {
    if (!_isGuest || _verificationId == null) {
      _errorMessage = 'عملية غير صالحة';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // يجب إرسال OTP أولاً
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // تحديث بيانات المستخدم
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.updateUserData(
        userId: _currentUser!.id,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );

      if (success) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          email: email,
          photoUrl: photoUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'فشل تحديث البيانات';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // تحديث رصيد الكاش باك
  void updateCashbackBalance(double newBalance) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(cashbackBalance: newBalance);
      notifyListeners();
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isGuest = false;
      _verificationId = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج';
    }

    _isLoading = false;
    notifyListeners();
  }

  // مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // الحصول على رسالة الخطأ المناسبة
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'too-many-requests':
        return 'تم إرسال عدد كبير من الطلبات. حاول لاحقاً';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      default:
        return 'حدث خطأ. حاول مرة أخرى';
    }
  }
}
