import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/theme_provider.dart';
import 'package:ecommerce_dashboard/screens/customers/customers_screen.dart';
import 'package:ecommerce_dashboard/screens/dashboard_screen.dart';
import 'package:ecommerce_dashboard/screens/orders/orders_list_screen.dart';
import 'package:ecommerce_dashboard/screens/products/products_list_screen.dart';
import 'package:ecommerce_dashboard/screens/reports/reports_screen.dart';
import 'package:ecommerce_dashboard/screens/sellers/sellers_screen.dart';
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
    '/customers': CustomersScreen(),
    '/sellers': SellersScreen(),
    '/reports': ReportsScreen(),
    '/settings': SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;
    final colorScheme = theme.colorScheme;
    final iconTheme = theme.iconTheme;
    final textTheme = theme.textTheme;

    // تحديد خلفية الشريط الجانبي
    final sideBarBackgroundColor = isDark
        ? AppColors.darkCard
        : AppColors.cardBackground;

    return AdminScaffold(
      // 1. خلفية الشاشة الرئيسية
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // استخدام خصائص الثيم لضمان التناسق (خاصة لون أيقونة الدرج)
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme, // لضمان لون أيقونة الدرج/الرجوع
        title: Row(
          children: [
            Icon(Icons.store, color: colorScheme.primary, size: 28),
            SizedBox(width: AppSpacing.md),
            Text(
              'متجري الإلكتروني',
              // الاعتماد على style الـ AppBarTheme لتجنب التكرار
              style: theme.appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button - زر تبديل الثيم
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.warning : AppColors.grey700,
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
                  backgroundColor: colorScheme.secondary,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
          ),

          // Search Button (لون الأيقونة يتبع IconTheme)
          IconButton(
            icon: Icon(Icons.search, color: iconTheme.color),
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
                  color: iconTheme.color,
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
                    color: AppColors.error, // لون دلالي ثابت
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '5',
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
                    backgroundColor: colorScheme.primary,
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
                          color: textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'مدير',
                        style: AppTextStyles.caption.copyWith(
                          color: textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down, color: iconTheme.color),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  // ListTile Text color will follow theme's text color
                  child: ListTile(
                    leading: Icon(Icons.person, color: iconTheme.color),
                    title: Text('الملف الشخصي', style: textTheme.bodyMedium),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings, color: iconTheme.color),
                    title: Text('الإعدادات', style: textTheme.bodyMedium),
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
      sideBar: SideBar(
        // 4. تعيين خلفية الشريط الجانبي بشكل صريح (لضمان تطابق الدرج/السيرفيس)
        backgroundColor: sideBarBackgroundColor,
        // لون الخلفية النشط من Primary
        activeBackgroundColor: colorScheme.primary.withOpacity(0.15),
        activeIconColor: colorScheme.primary,
        // تعيين لون النص النشط بشكل صريح (صحيح)
        activeTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        // لون الأيقونات العادي يتبع IconTheme (صحيح)
        iconColor: iconTheme.color,
        // تعيين لون النص العادي بشكل صريح (صحيح)
        textStyle: TextStyle(
          color: textTheme.bodyMedium?.color,
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
            title: 'العملاء',
            route: '/customers',
            icon: Icons.people_outline,
          ),
          AdminMenuItem(
            title: 'البائعون',
            route: '/sellers',
            icon: Icons.store_outlined,
          ),
          AdminMenuItem(
            title: 'التقارير',
            route: '/reports',
            icon: Icons.analytics_outlined,
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
            // Gradient الهيدر ديناميكي (يعتمد على Primary)
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
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
          // 5. خلفية الفوتر (تتبع لون السطح الداكن/الفاتح)
          color: isDark ? AppColors.darkSurface : AppColors.grey100,
          child: Center(
            child: Text('الإصدار 1.0.0', style: textTheme.bodySmall),
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
            hintText: 'ابحث عن منتج، طلب، أو عميل...',
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
                'عميل جديد',
                'انضم أحمد محمد إلى المتجر',
                Icons.person_add,
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
        color: color.withOpacity(0.05),
        borderRadius: AppBorderRadius.small,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
              backgroundColor: colorScheme.primary.withOpacity(0.1),
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
    final colorScheme = Theme.of(context).colorScheme;

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
