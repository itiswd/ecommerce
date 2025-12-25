// lib/main_dashboard.dart
// نقطة الدخول للوحة التحكم (الأدمن)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import 'config/app_flavor.dart';
import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/banners_provider.dart';
import 'providers/cashback_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/admin_register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_layout.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تهيئة التواريخ العربية
  await initializeDateFormatting('ar', null);
  Intl.defaultLocale = 'ar';

  // تهيئة Flavor الأدمن
  FlavorConfig.initialize(
    flavor: AppFlavor.dashboard,
    appName: 'لوحة التحكم',
    appTitle: 'لوحة تحكم المتجر',
  );

  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ جميع الـ Providers المطلوبة
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => BannersProvider()),
        ChangeNotifierProvider(create: (_) => CashbackProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: FlavorConfig.instance.appTitle,
            debugShowCheckedModeBanner: false,

            // ✅ Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            locale: const Locale('ar', 'EG'),
            supportedLocales: const [
              Locale('ar', 'EG'),
              Locale('ar', 'SA'),
              Locale('ar'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ✅ RTL Direction
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                ),
              );
            },

            // ✅ المسارات
            routes: {
              '/login': (context) => const LoginScreen(),
              '/admin-register': (context) => const AdminRegisterScreen(),
              '/dashboard': (context) => const MainLayout(),
            },

            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                // التحقق من حالة تحميل التطبيق
                if (authProvider.isLoading) {
                  return const SplashScreen();
                }

                // التحقق من تسجيل الدخول
                if (authProvider.isAuthenticated) {
                  return const MainLayout();
                }

                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
