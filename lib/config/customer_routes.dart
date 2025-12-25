// lib/config/customer_routes.dart
import 'package:ecommerce_dashboard/customer/screens/auth/customer_login_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/auth/customer_onboarding_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/auth/customer_register_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/auth/customer_splash_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/cart/customer_cart_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/comparison/customer_comparison_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/home/customer_home_screen.dart';
import 'package:ecommerce_dashboard/customer/screens/profile/customer_profile_screen.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:flutter/material.dart';

class CustomerRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
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
      case splash:
        return MaterialPageRoute(builder: (_) => const CustomerSplashScreen());
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const CustomerOnboardingScreen(),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const CustomerLoginScreen());
      case register:
        return MaterialPageRoute(
          builder: (_) => const CustomerRegisterScreen(),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CustomerCartScreen());
      case comparison:
        return MaterialPageRoute(
          builder: (_) => const CustomerComparisonScreen(),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());
      case productDetails:
        final product = settings.arguments as Product?;
        return MaterialPageRoute(
          builder: (_) => CustomerProductDetailsScreen(product: product),
        );
      case productListing:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CustomerProductListingScreen(
            category: args?['category'] as String?,
            searchQuery: args?['searchQuery'] as String?,
          ),
        );
      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CustomerCheckoutScreen(),
        );
      case orderSuccess:
        final orderId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CustomerOrderSuccessScreen(orderId: orderId ?? ''),
        );
      case orders:
        return MaterialPageRoute(builder: (_) => const CustomerOrdersScreen());
      case cashbackWallet:
        return MaterialPageRoute(
          builder: (_) => const CustomerCashbackScreen(),
        );
      case search:
        return MaterialPageRoute(builder: (_) => const CustomerSearchScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'الصفحة غير موجودة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('${settings.name}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(home),
                    child: const Text('العودة للرئيسية'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

// ==================== شاشة تفاصيل المنتج ====================
class CustomerProductDetailsScreen extends StatelessWidget {
  final Product? product;

  const CustomerProductDetailsScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: const Center(child: Text('المنتج غير موجود')),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(product!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('المشاركة - قريباً')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: product!.images.isNotEmpty
                  ? Image.network(
                      product!.images.first,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported, size: 64),
                    )
                  : const Icon(Icons.image, size: 64),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج
                  Text(
                    product!.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // السعر
                  Row(
                    children: [
                      Text(
                        '${product!.price.toStringAsFixed(0)} جنيه',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product!.hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${product!.originalPrice!.toStringAsFixed(0)} جنيه',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product!.discountPercentage!.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // البائع
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.store, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'مباع بواسطة: ${product!.sellerName}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الوصف
                  Text(
                    'الوصف',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product!.description),
                  const SizedBox(height: 16),

                  // المواصفات
                  if (product!.specifications.isNotEmpty) ...[
                    Text(
                      'المواصفات الفنية',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...product!.specifications.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(flex: 3, child: Text(e.value)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت الإضافة للمقارنة')),
                    );
                  },
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('قارن'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت الإضافة للسلة')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('أضف للسلة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== شاشة قائمة المنتجات ====================
class CustomerProductListingScreen extends StatelessWidget {
  final String? category;
  final String? searchQuery;

  const CustomerProductListingScreen({
    super.key,
    this.category,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category ?? searchQuery ?? 'المنتجات')),
      body: const Center(child: Text('قائمة المنتجات - قيد التطوير')),
    );
  }
}

// ==================== شاشة إتمام الطلب ====================
class CustomerCheckoutScreen extends StatelessWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: const Center(child: Text('شاشة إتمام الطلب - قيد التطوير')),
    );
  }
}

// ==================== شاشة نجاح الطلب ====================
class CustomerOrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const CustomerOrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: colorScheme.primary),
              const SizedBox(height: 24),
              const Text(
                'تم تأكيد طلبك بنجاح!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('رقم الطلب: $orderId'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    CustomerRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== شاشة طلباتي ====================
class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: const Center(child: Text('شاشة الطلبات - قيد التطوير')),
    );
  }
}

// ==================== شاشة محفظة الكاش باك ====================
class CustomerCashbackScreen extends StatelessWidget {
  const CustomerCashbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محفظة الكاش باك')),
      body: const Center(child: Text('شاشة الكاش باك - قيد التطوير')),
    );
  }
}

// ==================== شاشة البحث ====================
class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث عن منتج...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) {
            // TODO: تنفيذ البحث
          },
        ),
      ),
      body: const Center(child: Text('ابدأ البحث عن المنتجات')),
    );
  }
}
