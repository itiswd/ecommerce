import 'dart:async';

import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/services/admin_setup_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AdminSetupService _adminSetupService = AdminSetupService();

  @override
  void initState() {
    super.initState();

    // إعداد الـ Animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // بدء الـ Animation
    _animationController.forward();

    // التحقق من الإعداد والتوجيه
    _checkSetupAndNavigate();
  }

  Future<void> _checkSetupAndNavigate() async {
    // انتظار 3 ثانية لعرض الـ splash
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      // التحقق من وجود حساب أدمن
      final hasAdmin = await _adminSetupService.hasAdminAccount();

      if (!mounted) return;

      if (!hasAdmin) {
        // لا يوجد أدمن - توجيه لصفحة الإعداد
        Navigator.pushReplacementNamed(context, '/admin-setup');
      } else {
        // يوجد أدمن - توجيه لصفحة تسجيل الدخول
        Navigator.pushReplacementNamed(context, '/wrapper');
      }
    } catch (e) {
      // في حالة الخطأ، توجيه للإعداد
      debugPrint('❌ خطأ في التحقق من الإعداد: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/wrapper');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkCard]
                : [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اللوجو
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.precision_manufacturing,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // اسم التطبيق
                  Text(
                    'مكنتي',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // الاسم الإنجليزي
                  Text(
                    'MAKANTY',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.secondaryLight,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // لوحة التحكم
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'لوحة التحكم - Admin Panel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(220),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // مؤشر التحميل
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondaryLight,
                      ),
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'جاري التحميل...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(180),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
