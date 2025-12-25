// lib/config/app_flavor.dart

/// أنواع التطبيقات المتاحة
enum AppFlavor {
  dashboard, // لوحة تحكم الأدمن
  customer, // تطبيق المستخدم
}

/// إعدادات كل Flavor
class FlavorConfig {
  final AppFlavor flavor;
  final String appName;
  final String appTitle;

  static FlavorConfig? _instance;

  FlavorConfig._internal({
    required this.flavor,
    required this.appName,
    required this.appTitle,
  });

  /// تهيئة الـ Flavor
  static void initialize({
    required AppFlavor flavor,
    required String appName,
    required String appTitle,
  }) {
    _instance = FlavorConfig._internal(
      flavor: flavor,
      appName: appName,
      appTitle: appTitle,
    );
  }

  /// الحصول على الـ instance الحالي
  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception('FlavorConfig not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// هل هذا تطبيق الأدمن؟
  static bool get isDashboard => _instance?.flavor == AppFlavor.dashboard;

  /// هل هذا تطبيق المستخدم؟
  static bool get isCustomer => _instance?.flavor == AppFlavor.customer;
}
