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
    '/sellers': SellersScreen(), // ✅ تم إضافة صفحة البائعين
    '/reports': ReportsScreen(),
    '/settings': SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AdminScaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.store, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text(
              'متجري الإلكتروني',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button - زر تبديل الثيم
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.amber : Colors.grey[700],
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
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
          ),

          // Search Button
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
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
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                onPressed: () {
                  _showNotifications(context);
                },
                tooltip: 'الإشعارات',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: PopupMenuButton<String>(
              offset: Offset(0, 50),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('م', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محمد أحمد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'مدير',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('الملف الشخصي'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('الإعدادات'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
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
        backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
        activeBackgroundColor: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
        activeIconColor: Colors.blue,
        activeTextStyle: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        iconColor: isDark ? Colors.white70 : Colors.grey[600],
        textStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[700],
          fontSize: 14,
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
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, color: Colors.white, size: 40),
                SizedBox(height: 8),
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
          color: Colors.grey[100],
          child: Center(
            child: Text(
              'الإصدار 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.blue),
            SizedBox(width: 8),
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
                Colors.green,
              ),
              _notificationItem(
                'مخزون منخفض',
                'المنتج "لابتوب Dell" أوشك على النفاذ',
                Icons.warning,
                Colors.orange,
              ),
              _notificationItem(
                'عميل جديد',
                'انضم أحمد محمد إلى المتجر',
                Icons.person_add,
                Colors.blue,
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
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                'م',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'محمد أحمد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'mohamed@admin.com',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Chip(
              label: Text('مدير'),
              backgroundColor: Colors.blue.withOpacity(0.1),
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
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
