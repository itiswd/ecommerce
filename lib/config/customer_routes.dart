// lib/config/customer_routes.dart
import 'package:flutter/material.dart';

class CustomerRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String productListing = '/products';
  static const String productDetails = '/product-details';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String comparison = '/comparison';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String cashbackWallet = '/cashback';
  static const String addresses = '/addresses';
  static const String addEditAddress = '/address/edit';
  static const String settings = '/settings';

  // Generate routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Add routes here when screens are created
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('الصفحة غير موجودة: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
