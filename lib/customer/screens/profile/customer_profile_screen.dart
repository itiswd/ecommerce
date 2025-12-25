// lib/customer/screens/profile/customer_profile_screen.dart
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/customer/screens/auth/customer_phone_login_screen.dart';
import 'package:ecommerce_dashboard/providers/customer_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isGuest) {
          return _buildGuestView(context);
        }
        return _buildAuthenticatedView(context, authProvider);
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 100,
                color: colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'مرحباً زائر!',
                style: AppTextStyles.h2.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'سجل الدخول للاستفادة من جميع المميزات',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CustomerPhoneLoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '🎁 احصل على كاش باك من كل عملية شراء',
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    CustomerAuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'م',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'مستخدم',
                    style: AppTextStyles.h3.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user?.phone != null && user!.phone.isNotEmpty)
                    Text(
                      '+20${user.phone}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cashback Balance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رصيد الكاش باك',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user?.cashbackBalance.toStringAsFixed(2) ?? '0.00'} جنيه',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'طلباتي',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('صفحة الطلبات - قريباً')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'عناويني',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('صفحة العناوين - قريباً')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'تعديل الملف الشخصي',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تعديل الملف الشخصي - قريباً')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الإعدادات - قريباً')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'المساعدة والدعم',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('المساعدة - قريباً')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'عن التطبيق',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عن التطبيق - قريباً')),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              textColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context, authProvider);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? colorScheme.onSurface,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: textColor ?? colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    CustomerAuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                );
              }
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
