// lib/providers/auth_provider.dart
import 'package:ecommerce_dashboard/models/user.dart' as models;
import 'package:ecommerce_dashboard/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

/// Provider لإدارة مصادقة الأدمن
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  models.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ==================== Getters ====================

  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  models.User? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.name;

  // ==================== Constructor ====================

  AuthProvider() {
    _initAuth();
  }

  // ==================== Methods ====================

  /// تهيئة المصادقة - التحقق من الحالة عند بدء التطبيق
  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.checkAdminAuthStatus();
      debugPrint(
        _currentUser != null
            ? '✅ أدمن مسجل دخول: ${_currentUser!.name}'
            : '⚠️ لا يوجد أدمن مسجل دخول',
      );
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة المصادقة: $e');
      _errorMessage = 'حدث خطأ في التحقق من حالة تسجيل الدخول';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تسجيل دخول الأدمن
  Future<bool> login(String email, String password) async {
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
        _isLoading = false;
        notifyListeners();
        debugPrint('✅ تم تسجيل دخول الأدمن: ${user.name}');
        return true;
      }

      _errorMessage = 'فشل تسجيل الدخول. تأكد من أنك أدمن.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Login error: $e');
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      debugPrint('✅ تم تسجيل الخروج');
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج';
      debugPrint('❌ Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// التحقق من حالة المصادقة
  Future<void> checkAuthStatus() async {
    _currentUser = await _authService.checkAdminAuthStatus();
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ترجمة أكواد أخطاء Firebase للعربية
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم إرسال عدد كبير من الطلبات. حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      default:
        return 'حدث خطأ في تسجيل الدخول';
    }
  }
}
