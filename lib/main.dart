import 'package:ecommerce_dashboard/models/order.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/screens/dashboard_screen.dart';
import 'package:ecommerce_dashboard/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase (اختياري للبداية)
  // await Firebase.initializeApp();

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'متجري الإلكتروني - لوحة التحكم',
        debugShowCheckedModeBanner: false,

        // الثيم الرئيسي
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo', // يجب إضافة خط Cairo للمشروع
          // AppBar Theme
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.grey[800]),
            titleTextStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Card Theme
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),

          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Colors
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
            error: Colors.red,
            surface: Color(0xFFF5F7FA),
          ),
        ),

        // Dark Theme (اختياري)
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
        ),

        // الصفحة الرئيسية
        home: AuthWrapper(),

        // Routes
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => MainLayout(),
        },
      ),
    );
  }
}

// Auth Wrapper - للتحقق من تسجيل الدخول
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // للتبسيط، نبدأ مباشرة بالـ Dashboard
        // في الإنتاج، تحقق من حالة تسجيل الدخول
        return MainLayout();

        // الكود الحقيقي سيكون:
        // if (authProvider.isAuthenticated) {
        //   return MainLayout();
        // } else {
        //   return LoginScreen();
        // }
      },
    );
  }
}

// Auth Provider (مبسط)
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
      // محاكاة تسجيل الدخول
      await Future.delayed(Duration(seconds: 1));

      // في الإنتاج: استخدم Firebase Auth
      // final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );

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

// Products Provider (مبسط)
class ProductsProvider extends ChangeNotifier {
  final List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    // جلب المنتجات من Firebase
    await Future.delayed(Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    // إضافة منتج إلى Firebase
    _products.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    // تحديث منتج في Firebase
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    // حذف منتج من Firebase
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}

// Orders Provider (مبسط)
class OrdersProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    // جلب الطلبات من Firebase
    await Future.delayed(Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // تحديث حالة الطلب في Firebase
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // تحديث الحالة
      notifyListeners();
    }
  }
}

// Login Screen (مبسط)
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
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('تسجيل الدخول'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تسجيل الدخول')));
    }
  }
}
