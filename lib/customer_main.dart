// lib/customer_main.dart
import 'package:ecommerce_dashboard/config/customer_routes.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/customer/screens/auth/customer_splash_screen.dart';
import 'package:ecommerce_dashboard/providers/banners_provider.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/cashback_provider.dart';
import 'package:ecommerce_dashboard/providers/comparison_provider.dart';
import 'package:ecommerce_dashboard/providers/customer_auth_provider.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:ecommerce_dashboard/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // تهيئة التواريخ
  try {
    await initializeDateFormatting('ar', null);
    Intl.defaultLocale = 'ar';
    debugPrint('✅ Arabic locale initialized successfully');
  } catch (e) {
    debugPrint('❌ Locale initialization error: $e');
  }

  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CustomerAuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => BannersProvider()),
        ChangeNotifierProvider(create: (_) => CashbackProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ComparisonProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'مكنتي - Makanty',
            debugShowCheckedModeBanner: false,

            // ===== RTL Support =====
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

            // ===== Theme Configuration =====
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // ===== Force RTL Direction =====
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

            // ===== Navigation =====
            home: const CustomerSplashScreen(),
            onGenerateRoute: CustomerRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
