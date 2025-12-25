import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isMobile = AppResponsive.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Container(
            width: isMobile ? double.infinity : 450,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppBorderRadius.large,
              boxShadow: [AppShadows.large],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // أيقونة التطبيق
                  _buildAppIcon(colorScheme),
                  SizedBox(height: AppSpacing.md),

                  // العنوان
                  _buildHeader(colorScheme, textTheme),
                  SizedBox(height: AppSpacing.md),

                  // حقل الإيميل
                  _buildEmailField(),
                  SizedBox(height: AppSpacing.sm),

                  // حقل كلمة المرور
                  _buildPasswordField(),
                  SizedBox(height: AppSpacing.sm),

                  // نسيت كلمة المرور
                  _buildForgotPassword(),
                  SizedBox(height: AppSpacing.md),

                  // زر تسجيل الدخول
                  _buildLoginButton(colorScheme),
                  SizedBox(height: AppSpacing.md),

                  // معلومات إضافية
                  _buildInfoBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(ColorScheme colorScheme) {
    return Center(
      child: Image.asset(
        'assets/icons/logo.png',
        width: 200,
        height: 200,
        fit: BoxFit.fill,
        errorBuilder: (_, _, _) => Icon(
          Icons.admin_panel_settings_rounded,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      'سجل الدخول للمتابعة',
      style: AppTextStyles.bodyMedium.copyWith(
        color: textTheme.bodyMedium?.color,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: const InputDecoration(
        labelText: 'البريد الإلكتروني',
        hintText: 'admin@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'البريد الإلكتروني غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: _handleForgotPassword,
        child: const Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Column(
      children: [
        // رابط إنشاء حساب جديد
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'ليس لديك حساب؟',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(width: AppSpacing.sm),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/admin-register');
              },
              child: const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withAlpha(0x19),
            borderRadius: AppBorderRadius.medium,
            border: Border.all(color: AppColors.info.withAlpha(0x4D)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'يمكنك إنشاء حساب أدمن جديد أو التواصل مع مدير النظام',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== Handlers ====================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('مرحباً ${authProvider.userName ?? ''}!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        _showError(authProvider.errorMessage ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(authProvider.errorMessage ?? 'حدث خطأ غير متوقع');
    }
  }

  void _handleForgotPassword() {
    // TODO: Implement password reset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يرجى التواصل مع مدير النظام لإعادة تعيين كلمة المرور'),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
