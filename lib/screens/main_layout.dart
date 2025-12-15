import 'package:ecommerce_dashboard/screens/dashboard_screen.dart';
import 'package:ecommerce_dashboard/screens/products/products_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

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
    '/orders': OrdersScreen(),
    '/customers': CustomersScreen(),
    '/sellers': SellersScreen(),
    '/reports': ReportsScreen(),
    '/settings': SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.store, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text(
              'متجري الإلكتروني',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // البحث
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[700]),
            onPressed: () {
              // فتح صفحة البحث
            },
          ),

          // الإشعارات
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  // فتح الإشعارات
                },
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
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // الملف الشخصي
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: PopupMenuButton<dynamic>(
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
                  Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem<dynamic>(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('الملف الشخصي'),
                    dense: true,
                  ),
                  onTap: () {},
                ),
                PopupMenuItem<dynamic>(
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('الإعدادات'),
                    dense: true,
                  ),
                  onTap: () {},
                ),
                PopupMenuDivider(),
                PopupMenuItem<dynamic>(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                    dense: true,
                  ),
                  onTap: () {
                    // تسجيل الخروج
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: Colors.white,
        activeBackgroundColor: Colors.blue.withOpacity(0.1),
        activeIconColor: Colors.blue,
        activeTextStyle: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        iconColor: Colors.grey[600],
        textStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
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
            children: [
              AdminMenuItem(title: 'كل المنتجات', route: '/products'),
              AdminMenuItem(title: 'إضافة منتج', route: '/products/add'),
              AdminMenuItem(title: 'الفئات', route: '/products/categories'),
            ],
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
            children: [
              AdminMenuItem(title: 'تقرير المبيعات', route: '/reports/sales'),
              AdminMenuItem(
                title: 'تقرير العمولات',
                route: '/reports/commission',
              ),
              AdminMenuItem(
                title: 'تقرير المنتجات',
                route: '/reports/products',
              ),
            ],
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
        child: _screens[_selectedRoute] ?? DashboardScreen(),
      ),
    );
  }
}

// Placeholder Screens (سيتم تطويرها لاحقاً)
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('صفحة المنتجات - قيد التطوير'));
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('صفحة الطلبات - قيد التطوير'));
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('صفحة العملاء - قيد التطوير'));
  }
}

class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('صفحة البائعين - قيد التطوير'));
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('صفحة التقارير - قيد التطوير'));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('صفحة الإعدادات - قيد التطوير'));
  }
}
