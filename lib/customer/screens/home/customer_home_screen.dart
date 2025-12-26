// lib/customer/screens/home/customer_home_screen.dart
import 'package:ecommerce_dashboard/customer/screens/cart/customer_cart_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/comparison/customer_comparison_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/home/customer_main_tab.dart';
import 'package:ecommerce_dashboard/customer/screens/profile/customer_profile_screen.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/comparison_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CustomerMainTab(),
    CustomerComparisonScreen(),
    CustomerCartScreen(),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withAlpha(128),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Consumer<ComparisonProvider>(
                builder: (context, comparison, child) {
                  return _BadgedIcon(
                    icon: Icons.compare_arrows_outlined,
                    count: comparison.count,
                  );
                },
              ),
              activeIcon: Consumer<ComparisonProvider>(
                builder: (context, comparison, child) {
                  return _BadgedIcon(
                    icon: Icons.compare_arrows,
                    count: comparison.count,
                  );
                },
              ),
              label: 'المقارنة',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return _BadgedIcon(
                    icon: Icons.shopping_cart_outlined,
                    count: cart.itemCount,
                  );
                },
              ),
              activeIcon: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return _BadgedIcon(
                    icon: Icons.shopping_cart,
                    count: cart.itemCount,
                  );
                },
              ),
              label: 'السلة',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _BadgedIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            left: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: TextStyle(
                  color: colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
