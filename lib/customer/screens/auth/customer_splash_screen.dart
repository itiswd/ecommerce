// lib/customer/screens/auth/customer_splash_screen.dart
import 'package:ecommerce_dashboard/config/customer_routes.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/customer_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerSplashScreen extends StatefulWidget {
  const CustomerSplashScreen({super.key});

  @override
  State<CustomerSplashScreen> createState() => _CustomerSplashScreenState();
}

class _CustomerSplashScreenState extends State<CustomerSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // التحقق من عرض الـ Onboarding من قبل
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    // التحقق من حالة تسجيل الدخول
    final authProvider = Provider.of<CustomerAuthProvider>(
      context,
      listen: false,
    );

    if (!hasSeenOnboarding) {
      // عرض الـ Onboarding لأول مرة
      Navigator.of(context).pushReplacementNamed(CustomerRoutes.onboarding);
    } else if (authProvider.isAuthenticated) {
      // المستخدم مسجل دخول - الذهاب للرئيسية
      Navigator.of(context).pushReplacementNamed(CustomerRoutes.home);
    } else {
      // المستخدم غير مسجل - الذهاب لتسجيل الدخول
      Navigator.of(context).pushReplacementNamed(CustomerRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
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
                          errorBuilder: (_, _, _) => Icon(
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

                      // الشعار
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
                          'ماكينات خياطة بجودة عالمية',
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
              );
            },
          ),
        ),
      ),
    );
  }
}
