// lib/screens/auth/admin_register_screen.dart
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// شاشة إنشاء حساب أدمن جديد
class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = AppResponsive.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Container(
            width: isMobile ? double.infinity : 500,
            constraints: const BoxConstraints(maxWidth: 550),
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // أيقونة
                  _buildAppIcon(colorScheme),
                  SizedBox(height: AppSpacing.md),

                  // العنوان
                  buildheader(colorScheme, theme.textTheme),
                  const SizedBox(height: AppSpacing.md),

                  // رسالة الخطأ
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withAlpha(77)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // الحقول
                  _buildNameField(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildEmailField(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPhoneField(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPasswordField(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: AppSpacing.md),

                  // زر الإنشاء
                  _buildRegisterButton(colorScheme),
                  const SizedBox(height: AppSpacing.md),
                  // رابط تسجيل الدخول
                  _buildLoginLink(),
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

  Widget buildheader(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      'إنشاء حساب أدمن جديد',
      style: AppTextStyles.bodyMedium.copyWith(
        color: textTheme.bodyMedium?.color,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'الاسم الكامل',
        prefixIcon: Icon(Icons.person_outline),
        hintText: 'أدخل اسمك الكامل',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال الاسم';
        }
        if (value.trim().length < 3) {
          return 'الاسم يجب أن يكون 3 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: const InputDecoration(
        labelText: 'البريد الإلكتروني',
        prefixIcon: Icon(Icons.email_outlined),
        hintText: 'admin@example.com',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'البريد الإلكتروني غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'رقم الهاتف',
        prefixIcon: Icon(Icons.phone_outlined),
        hintText: '01xxxxxxxxx',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال رقم الهاتف';
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

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء تأكيد كلمة المرور';
        }
        if (value != _passwordController.text) {
          return 'كلمة المرور غير متطابقة';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                children: [
                  Text(
                    'إنشاء الحساب',
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Handlers ====================

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'فشل إنشاء الحساب';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
