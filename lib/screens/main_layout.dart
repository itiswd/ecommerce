import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/theme_provider.dart';
import 'package:ecommerce_dashboard/screens/cashback/cashback_screen.dart';
import 'package:ecommerce_dashboard/screens/dashboard_screen.dart';
import 'package:ecommerce_dashboard/screens/orders/orders_list_screen.dart';
import 'package:ecommerce_dashboard/screens/products/products_list_screen.dart';
import 'package:ecommerce_dashboard/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _selectedRoute = '/';

  final Map<String, Widget> _screens = {
    '/': DashboardScreen(),
    '/products': ProductsListScreen(),
    '/orders': OrdersListScreen(),
    // '/banners': BannersScreen(),
    '/cashback': CashbackScreen(),
    '/settings': SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final appBarBackgroundColor = isDark
        ? AppColors.darkCard
        : AppColors.cardBackground;
    final sideBarBackgroundColor = isDark
        ? AppColors.darkCard
        : AppColors.cardBackground;
    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return AdminScaffold(
      key: ValueKey('admin_scaffold_${isDark ? 'dark' : 'light'}'),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: appBarBackgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: IconThemeData(color: primaryTextColor),
        title: Row(
          children: [
            Text(
              'متجري الإلكتروني',
              style: theme.appBarTheme.titleTextStyle?.copyWith(
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: primaryTextColor,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isDark
                        ? 'تم التبديل للوضع الفاتح'
                        : 'تم التبديل للوضع الداكن',
                  ),
                  backgroundColor: secondaryColor,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
          ),

          // Search Button
          IconButton(
            icon: Icon(Icons.search, color: primaryTextColor),
            onPressed: () {
              _showSearchDialog(context);
            },
            tooltip: 'بحث',
          ),

          // Notifications
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: primaryTextColor,
                ),
                onPressed: () {
                  _showNotifications(context);
                },
                tooltip: 'الإشعارات',
              ),
              Positioned(
                right: AppSpacing.sm,
                top: AppSpacing.sm,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // User Menu
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: PopupMenuButton<String>(
              offset: Offset(0, 50),
              icon: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Text('م', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محمد أحمد',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        'مدير',
                        style: AppTextStyles.caption.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down, color: primaryTextColor),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person, color: primaryTextColor),
                    title: Text(
                      'الملف الشخصي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primaryTextColor,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings, color: primaryTextColor),
                    title: Text(
                      'الإعدادات',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primaryTextColor,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: AppColors.error),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _showProfile(context);
                    break;
                  case 'settings':
                    setState(() => _selectedRoute = '/settings');
                    break;
                  case 'logout':
                    _confirmLogout(context);
                    break;
                }
              },
            ),
          ),
        ],
      ),
      // sideBar
      sideBar: SideBar(
        backgroundColor: sideBarBackgroundColor,
        activeBackgroundColor: primaryColor.withAlpha(0x26),
        activeIconColor: primaryColor,
        activeTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        borderColor: secondaryTextColor.withAlpha(64),
        iconColor: primaryTextColor,
        textStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
          fontFamily: 'Cairo',
        ),
        items: [
          AdminMenuItem(
            title: 'الرئيسية',
            route: '/',
            icon: Icons.dashboard_rounded,
          ),
          AdminMenuItem(
            title: 'المنتجات',
            route: '/products',
            icon: Icons.inventory_2_outlined,
          ),
          AdminMenuItem(
            title: 'الطلبات',
            route: '/orders',
            icon: Icons.shopping_cart_outlined,
          ),
          AdminMenuItem(
            title: 'البانرات',
            route: '/banners',
            icon: Icons.image_outlined,
          ),
          AdminMenuItem(
            title: 'الكاش باك',
            route: '/cashback',
            icon: Icons.account_balance_wallet_outlined,
          ),
          AdminMenuItem(
            title: 'الإعدادات',
            route: '/settings',
            icon: Icons.settings_outlined,
          ),
        ],
        selectedRoute: _selectedRoute,
        onSelected: (item) {
          setState(() {
            _selectedRoute = item.route!;
          });
        },
        header: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withAlpha(0xCC)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, color: Colors.white, size: 40),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: sideBarBackgroundColor.withAlpha(128),
          child: Center(
            child: Text(
              'الإصدار 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<String>(_selectedRoute),
          child: _screens[_selectedRoute] ?? DashboardScreen(),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('البحث'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج أو طلب...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('جاري البحث...')));
            },
            child: Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: colorScheme.primary),
            SizedBox(width: AppSpacing.sm),
            Text('الإشعارات'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _notificationItem(
                'طلب جديد',
                'طلب رقم #123 تم استلامه',
                Icons.shopping_cart,
                AppColors.success,
                textTheme,
              ),
              _notificationItem(
                'مخزون منخفض',
                'المنتج "لابتوب Dell" أوشك على النفاذ',
                Icons.warning,
                AppColors.warning,
                textTheme,
              ),
              _notificationItem(
                'بانر جديد',
                'تم إضافة بانر جديد للعروض',
                Icons.image,
                AppColors.primary,
                textTheme,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('عرض الكل'),
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
    TextTheme textTheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(0x0C),
        borderRadius: AppBorderRadius.small,
        border: Border.all(color: color.withAlpha(0x33)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(0x19),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primary,
              child: Text(
                'م',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text('محمد أحمد', style: AppTextStyles.h4),
            Text(
              'mohamed@admin.com',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Chip(
              label: Text('مدير'),
              backgroundColor: colorScheme.primary.withAlpha(0x19),
              labelStyle: TextStyle(color: colorScheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('قريباً...')));
            },
            child: Text('تعديل'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('تسجيل الخروج'),
          ],
        ),
        content: Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
