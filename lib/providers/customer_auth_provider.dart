// lib/providers/customer_auth_provider.dart
import 'package:ecommerce_dashboard/models/user.dart' as models;
import 'package:ecommerce_dashboard/services/customer_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

/// Provider لإدارة مصادقة العملاء (تطبيق المستخدم)
class CustomerAuthProvider extends ChangeNotifier {
  final CustomerAuthService _authService = CustomerAuthService();

  models.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;

  // ==================== Getters ====================

  models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _isGuest;
  String? get userId => _currentUser?.id;
  String? get userName => _currentUser?.name;
  String? get userEmail => _currentUser?.email;

  // ==================== Constructor ====================

  CustomerAuthProvider() {
    _initAuth();
  }

  // ==================== Methods ====================

  /// تهيئة المصادقة
  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _authService.authStateChanges.listen((auth.User? firebaseUser) async {
        if (firebaseUser != null) {
          final userData = await _authService.getUserData(firebaseUser.uid);
          if (userData != null) {
            _currentUser = userData;
            _isGuest = userData.isGuest;
          }
        } else {
          _currentUser = null;
          _isGuest = false;
        }
        notifyListeners();
      });

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

  /// تسجيل الدخول كزائر
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

  /// إنشاء حساب عميل جديد
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.createCustomerAccount(
        email: email,
        password: password,
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

      _errorMessage = 'فشل إنشاء الحساب';
      _isLoading = false;
      notifyListeners();
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
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

  /// تسجيل الدخول بالإيميل والباسورد
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'فشل تسجيل الدخول';
      _isLoading = false;
      notifyListeners();
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
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

  /// إعادة إرسال إيميل التحقق
  Future<bool> resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail();
      return true;
    } catch (e) {
      _errorMessage = 'فشل إرسال إيميل التحقق';
      notifyListeners();
      return false;
    }
  }

  /// التحقق من تأكيد الإيميل
  Future<bool> checkEmailVerified() async {
    return await _authService.isEmailVerified();
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on auth.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'فشل إرسال الرابط';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
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
        phone: phone,
        photoUrl: photoUrl,
      );

      if (success) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          email: email,
          phone: phone,
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

  /// تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isGuest = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ترجمة أكواد أخطاء Firebase
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم إرسال عدد كبير من الطلبات. حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
