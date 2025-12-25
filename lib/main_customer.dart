// lib/main_customer.dart
// نقطة الدخول لتطبيق العملاء

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_flavor.dart';
import 'config/customer_routes.dart';
import 'firebase_options.dart';
import 'providers/customer_auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تهيئة Flavor العميل
  FlavorConfig.initialize(
    flavor: AppFlavor.customer,
    appName: 'المتجر',
    appTitle: 'المتجر الإلكتروني',
  );

  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerAuthProvider()),
      ],
      child: MaterialApp(
        title: FlavorConfig.instance.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Cairo',
        ),
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: CustomerRoutes.splash,
        onGenerateRoute: CustomerRoutes.generateRoute,
      ),
    );
  }
}
