// lib/customer/screens/auth/customer_register_screen.dart
import 'package:ecommerce_dashboard/config/customer_routes.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/customer_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// شاشة إنشاء حساب عميل جديد
class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // أيقونة
                Icon(
                  Icons.person_add_rounded,
                  size: 60,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // العنوان
                Text(
                  'إنشاء حساب جديد',
                  style: AppTextStyles.h3.copyWith(color: colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // حقل الاسم
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // حقل الإيميل
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
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
                ),
                const SizedBox(height: 16),

                // حقل رقم الهاتف (اختياري)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف (اختياري)',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '01xxxxxxxxx',
                  ),
                ),
                const SizedBox(height: 16),

                // حقل كلمة المرور
                TextFormField(
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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
                ),
                const SizedBox(height: 16),

                // تأكيد كلمة المرور
                TextFormField(
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
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (value != _passwordController.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // زر إنشاء الحساب
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('إنشاء حساب'),
                  ),
                ),
                const SizedBox(height: 16),

                // رابط تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لديك حساب بالفعل؟'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(CustomerRoutes.login);
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),

                // ملاحظة التحقق من الإيميل
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(0x19),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سيتم إرسال رابط تأكيد إلى بريدك الإلكتروني',
                          style: TextStyle(fontSize: 12, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<CustomerAuthProvider>();

    try {
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        // عرض رسالة تأكيد الإيميل
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('تم إنشاء الحساب'),
            content: const Text(
              'تم إرسال رابط تأكيد إلى بريدك الإلكتروني.\n'
              'الرجاء التحقق من البريد لتأكيد حسابك.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(CustomerRoutes.home);
                },
                child: const Text('متابعة'),
              ),
            ],
          ),
        );
      } else {
        _showError(authProvider.errorMessage ?? 'فشل إنشاء الحساب');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('حدث خطأ غير متوقع');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
