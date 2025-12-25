import 'dart:async';

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
    // انتظار 2 ثانية لعرض الـ splash
    await Future.delayed(const Duration(seconds: 2));

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اللوجو مع تأثير Shadow
                Image.asset('assets/icons/logo.png', width: 360, height: 360),

                // Loading Indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF9CA3AF),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
