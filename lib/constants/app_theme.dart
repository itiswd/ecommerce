import 'package:flutter/material.dart';

import '../models/order.dart';

class AppColors {
  // ألوان مكنتي - Makanty Colors (مستوحاة من ماكينات الخياطة)
  // Primary: أزرق صناعي داكن (مثل ماكينات JUKI)
  static const Color primary = Color(0xFF1A365D); // أزرق صناعي داكن
  static const Color primaryLight = Color(0xFF2B4C7E); // أزرق فاتح
  static const Color primaryDark = Color(0xFF0D1B2A); // أزرق غامق جدًا

  // Secondary: ذهبي/برونزي (مثل إبر الماكينات والتطريز)
  static const Color secondary = Color(0xFFB8860B); // ذهبي داكن (DarkGoldenrod)
  static const Color secondaryLight = Color(0xFFDAA520); // ذهبي (Goldenrod)
  static const Color accent = Color(0xFFC9A227); // ذهبي لامع

  // ألوان إضافية صناعية
  static const Color industrial = Color(
    0xFF2F4F4F,
  ); // رمادي صناعي (DarkSlateGray)
  static const Color steel = Color(0xFF708090); // رمادي فولاذي (SlateGray)
  static const Color copper = Color(0xFFB87333); // نحاسي

  // ألوان الحالات
  static const Color error = Color(0xFFB91C1C);
  static const Color success = Color(0xFF047857);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0369A1);

  // Premium Gradient Colors
  static const Color gradientStart = Color(0xFF1A365D);
  static const Color gradientEnd = Color(0xFF2B4C7E);
  static const Color goldGradientStart = Color(0xFFB8860B);
  static const Color goldGradientEnd = Color(0xFFDAA520);

  // الألوان الرمادية
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // خلفيات الوضع الفاتح
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;

  // خلفيات الوضع الداكن
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);

  // النصوص
  static const Color textPrimary = Color(
    0xFF1F2937,
  ); // Dark Text (used in light mode)
  static const Color textSecondary = Color(
    0xFF6B7280,
  ); // Secondary Dark Text (used in light mode)
  static const Color textLight = Color(0xFF9CA3AF);

  // النصوص الداكنة
  static const Color darkTextPrimary = Color(
    0xFFF1F5F9,
  ); // Light Text (used in dark mode)
  static const Color darkTextSecondary = Color(
    0xFF94A3B8,
  ); // Secondary Light Text (used in dark mode)
  static const Color darkTextLight = Color(0xFF64748B);

  // الحدود
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF475569);
}

class AppTheme {
  // ===== Light Theme =====
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Cairo',
    useMaterial3: true,

    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.grey800),
      titleTextStyle: TextStyle(
        color: AppColors.grey800,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
      centerTitle: false,
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: AppColors.grey200,
      margin: EdgeInsets.zero,
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Cairo',
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.success;
        }
        return AppColors.grey400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.success.withAlpha(127);
        }
        return AppColors.grey300;
      }),
    ),

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.cardBackground,
      surfaceTint: Colors.transparent,
    ),
  );

  // ===== Dark Theme =====
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Cairo',
    useMaterial3: true,

    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
      centerTitle: false,
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withAlpha(77),
      margin: EdgeInsets.zero,
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      backgroundColor: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
        fontFamily: 'Cairo',
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.success;
        }
        return AppColors.grey600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.success.withAlpha(127);
        }
        return AppColors.darkSurface;
      }),
    ),

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.darkCard,
      surfaceTint: Colors.transparent,
      onSurface: AppColors.darkTextPrimary,
      onPrimary: Colors.white,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.darkTextPrimary),
      displayMedium: TextStyle(color: AppColors.darkTextPrimary),
      displaySmall: TextStyle(color: AppColors.darkTextPrimary),
      headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
      headlineMedium: TextStyle(color: AppColors.darkTextPrimary),
      headlineSmall: TextStyle(color: AppColors.darkTextPrimary),
      titleLarge: TextStyle(color: AppColors.darkTextPrimary),
      titleMedium: TextStyle(color: AppColors.darkTextPrimary),
      titleSmall: TextStyle(color: AppColors.darkTextSecondary),
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      bodySmall: TextStyle(color: AppColors.darkTextLight),
      labelLarge: TextStyle(color: AppColors.darkTextPrimary),
      labelMedium: TextStyle(color: AppColors.darkTextSecondary),
      labelSmall: TextStyle(color: AppColors.darkTextLight),
    ),

    // Icon Theme
    iconTheme: IconThemeData(color: AppColors.darkTextSecondary),
  );
}

// الأبعاد والمسافات
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// أحجام الخطوط
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Cairo',
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );
}

// Border Radius
class AppBorderRadius {
  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xlarge = BorderRadius.all(Radius.circular(24));
}

// Shadows
class AppShadows {
  static BoxShadow small = BoxShadow(
    color: Colors.black.withAlpha(13),
    spreadRadius: 1,
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static BoxShadow medium = BoxShadow(
    color: Colors.black.withAlpha(20),
    spreadRadius: 2,
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static BoxShadow large = BoxShadow(
    color: Colors.black.withAlpha(26),
    spreadRadius: 3,
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  // Premium shadows with gold tint
  static BoxShadow premium = BoxShadow(
    color: AppColors.secondary.withAlpha(30),
    spreadRadius: 2,
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}

// ============================================
// 🔥 Unified Order Status Helper - استخدمه في كل مكان
// ============================================
class OrderStatusHelper {
  // ألوان حالات الطلبات الموحدة
  static const Map<OrderStatus, Color> statusColors = {
    OrderStatus.pending: Color(0xFFF59E0B), // برتقالي/ذهبي
    OrderStatus.confirmed: Color(0xFF3B82F6), // أزرق
    OrderStatus.processing: Color(0xFF8B5CF6), // بنفسجي
    OrderStatus.shipped: Color(0xFF0EA5E9), // سماوي
    OrderStatus.delivered: Color(0xFF059669), // أخضر
    OrderStatus.cancelled: Color(0xFFDC2626), // أحمر
    OrderStatus.returned: Color(0xFF6B7280), // رمادي
  };

  // الأسماء العربية لحالات الطلبات
  static const Map<OrderStatus, String> statusArabicNames = {
    OrderStatus.pending: 'قيد الانتظار',
    OrderStatus.confirmed: 'مؤكد',
    OrderStatus.processing: 'قيد التجهيز',
    OrderStatus.shipped: 'قيد الشحن',
    OrderStatus.delivered: 'تم التوصيل',
    OrderStatus.cancelled: 'ملغي',
    OrderStatus.returned: 'مرتجع',
  };

  // أيقونات حالات الطلبات
  static const Map<OrderStatus, IconData> statusIcons = {
    OrderStatus.pending: Icons.hourglass_empty_rounded,
    OrderStatus.confirmed: Icons.check_circle_outline_rounded,
    OrderStatus.processing: Icons.inventory_2_outlined,
    OrderStatus.shipped: Icons.local_shipping_outlined,
    OrderStatus.delivered: Icons.task_alt_rounded,
    OrderStatus.cancelled: Icons.cancel_outlined,
    OrderStatus.returned: Icons.assignment_return_outlined,
  };

  // الحصول على لون الحالة
  static Color getStatusColor(OrderStatus status) {
    return statusColors[status] ?? AppColors.grey500;
  }

  // الحصول على الاسم العربي
  static String getStatusArabicName(OrderStatus status) {
    return statusArabicNames[status] ?? 'غير معروف';
  }

  // الحصول على الأيقونة
  static IconData getStatusIcon(OrderStatus status) {
    return statusIcons[status] ?? Icons.help_outline;
  }

  // الحصول على لون الخلفية الفاتح للحالة
  static Color getStatusBackgroundColor(OrderStatus status) {
    return getStatusColor(status).withAlpha(25);
  }

  // إنشاء Container للحالة (Badge)
  static Widget buildStatusBadge(
    OrderStatus status, {
    double fontSize = 12,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
  }) {
    final color = getStatusColor(status);
    final name = getStatusArabicName(status);
    final icon = getStatusIcon(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: color),
          SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  // إنشاء Chip للحالة
  static Widget buildStatusChip(OrderStatus status) {
    final color = getStatusColor(status);
    final name = getStatusArabicName(status);
    final icon = getStatusIcon(status);

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(name),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      backgroundColor: color.withAlpha(25),
      side: BorderSide(color: color.withAlpha(50)),
      padding: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ============================================
// 🔥 App Logo Widget - موحد في كل مكان
// ============================================
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withAlpha(40),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Image.asset(
              'assets/icons/logo.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.2),
                ),
                child: Icon(
                  Icons.store,
                  size: size * 0.5,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'مكنتي',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
            ),
          ),
          Text(
            'Makanty',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cairo',
              color: AppColors.secondary,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================
// 🔥 App Gradient - للاستخدام في كل مكان
// ============================================
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [AppColors.goldGradientStart, AppColors.goldGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premium = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF2D5A8A), Color(0xFF1E3A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient dark = LinearGradient(
    colors: [AppColors.darkBackground, AppColors.darkCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// التجاوبية (Responsiveness)
class AppResponsive {
  static const int mobileBreakpoint = 600;
  static const int tabletBreakpoint = 1000;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint &&
        MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
}
