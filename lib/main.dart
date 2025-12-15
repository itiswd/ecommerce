import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/customers_provider.dart';
import 'package:ecommerce_dashboard/providers/dashboard_provider.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:ecommerce_dashboard/screens/main_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تهيئة التواريخ بالعربية
  await initializeDateFormatting('ar', null);
  Intl.defaultLocale = 'ar';

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => CustomersProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'متجري الإلكتروني - لوحة التحكم',
        debugShowCheckedModeBanner: false,

        // RTL Support
        locale: Locale('ar', 'EG'),
        supportedLocales: [Locale('ar', 'EG'), Locale('en', 'US')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // تطبيق الثيم من ملف app_theme.dart
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // RTL Layout
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.RTL,
            child: child!,
          );
        },

        home: AuthWrapper(),

        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => MainLayout(),
        },
      ),
    );
  }
}

// Auth Wrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MainLayout();
      },
    );
  }
}

// Auth Provider
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = true;
  String? _userId;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(Duration(seconds: 1));

      _isAuthenticated = true;
      _userId = '123';
      _userEmail = email;
      _userName = 'محمد أحمد';

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userName = null;

    notifyListeners();
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 450,
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.large,
            boxShadow: [AppShadows.large],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.store_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'مرحباً بك',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'سجل الدخول للمتابعة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'أدخل بريدك الإلكتروني',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppSpacing.md),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'أدخل كلمة المرور',
                ),
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_back, size: 20),
                          ],
                        ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'أو',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: AppSpacing.lg),

              // Demo Login Info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'نسخة تجريبية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اضغط على "تسجيل الدخول" مباشرة للدخول',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تسجيل الدخول'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
