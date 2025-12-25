// lib/config/customer_constants.dart
import 'package:flutter/material.dart';

class CustomerConstants {
  // App Info
  static const String appName = 'مكنتي';
  static const String appNameEnglish = 'Makanty';
  static const String appVersion = '1.0.0';

  // Cashback Settings
  static const double cashbackPercentage = 0.05; // 5% من قيمة الطلب
  static const double minimumOrderForCashback = 500.0; // الحد الأدنى للطلب لكسب كاش باك
  static const double minimumCashbackToUse = 10.0; // الحد الأدنى للكاش باك لاستخدامه

  // Shipping Settings
  static const double defaultShippingFee = 50.0;
  static const double freeShippingThreshold = 1000.0; // شحن مجاني فوق هذا المبلغ

  // Product Settings
  static const int productsPerPage = 20;
  static const int maxComparisonProducts = 3;

  // Categories
  static const List<String> productCategories = [
    'ماكينات صناعي',
    'ماكينات منزلي',
    'قطع غيار',
    'ماكينات تطريز',
  ];

  // Category Icons (mapping)
  static const Map<String, IconData> categoryIcons = {
    'ماكينات صناعي': Icons.precision_manufacturing,
    'ماكينات منزلي': Icons.home_work,
    'قطع غيار': Icons.build,
    'ماكينات تطريز': Icons.design_services,
  };

  // Order Status Colors
  static const Map<String, Color> orderStatusColors = {
    'pending': Color(0xFFFFA726), // برتقالي
    'confirmed': Color(0xFF42A5F5), // أزرق
    'processing': Color(0xFF66BB6A), // أخضر فاتح
    'shipped': Color(0xFF26C6DA), // سماوي
    'delivered': Color(0xFF4CAF50), // أخضر
    'cancelled': Color(0xFFEF5350), // أحمر
    'returned': Color(0xFF9E9E9E), // رمادي
  };

  // Filter Options
  static const List<String> sortOptions = [
    'الأحدث',
    'الأقدم',
    'الأرخص',
    'الأغلى',
    'الأكثر مبيعاً',
    'الأعلى تقييماً',
  ];

  static const List<String> priceRanges = [
    'أقل من 1000',
    '1000 - 5000',
    '5000 - 10000',
    '10000 - 20000',
    'أكثر من 20000',
  ];

  static const List<String> brands = [
    'Jack',
    'Juki',
    'Brother',
    'Singer',
    'Toyota',
    'Typical',
    'Pegasus',
  ];

  static const List<String> conditions = [
    'جديد',
    'كسر زيرو',
    'مستعمل',
  ];

  // Phone Validation
  static const String phoneRegex = r'^01[0-2,5]{1}[0-9]{8}$';

  // Error Messages
  static const String errorNetwork = 'تحقق من اتصالك بالإنترنت';
  static const String errorGeneric = 'حدث خطأ. حاول مرة أخرى';
  static const String errorNoProducts = 'لا توجد منتجات';
  static const String errorEmptyCart = 'السلة فارغة';
  static const String errorGuestCheckout = 'يجب تسجيل الدخول لإتمام الطلب';

  // Success Messages
  static const String successAddedToCart = 'تمت الإضافة إلى السلة';
  static const String successRemovedFromCart = 'تم الحذف من السلة';
  static const String successOrderPlaced = 'تم تأكيد الطلب بنجاح';
  static const String successAddedToComparison = 'تمت الإضافة للمقارنة';

  // Onboarding
  static const List<Map<String, String>> onboardingPages = [
    {
      'title': 'قارن المواصفات',
      'description': 'قارن بين ماكينات الخياطة المختلفة واختر الأفضل لك',
      'image': 'assets/icons/compare.png',
    },
    {
      'title': 'اشتري بسعر الوكيل',
      'description': 'جميع المنتجات بضمان الوكيل وبأفضل الأسعار',
      'image': 'assets/icons/price.png',
    },
    {
      'title': 'استرجع كاش باك',
      'description': 'احصل على 5% كاش باك من كل عملية شراء',
      'image': 'assets/icons/cashback.png',
    },
  ];
}
