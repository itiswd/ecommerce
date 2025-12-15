import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:flutter/material.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Statistics
  int get totalProducts => _products.length;
  int get activeProducts => _products.where((p) => p.isActive).length;
  int get lowStockProducts =>
      _products.where((p) => p.stock < 10 && p.stock > 0).length;
  int get outOfStockProducts => _products.where((p) => p.stock == 0).length;

  double get totalInventoryValue => _products.fold(
    0.0,
    (sum, product) => sum + (product.price * product.stock),
  );

  double get totalCommissionEarned =>
      _products.fold(0.0, (sum, product) => sum + product.totalCommission);

  // Initialize with sample data
  ProductsProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _products = [
      Product(
        id: '1',
        name: 'لابتوب Dell XPS 15',
        description: 'لابتوب عالي الأداء مثالي للمصممين والمبرمجين',
        price: 45000,
        costPrice: 38000,
        category: 'إلكترونيات',
        images: [
          'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400',
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400',
        ],
        stock: 15,
        soldCount: 23,
        sellerId: 'seller_1',
        sellerName: 'محمد أحمد',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        isActive: true,
        commission: 0.10,
      ),
      Product(
        id: '2',
        name: 'iPhone 15 Pro Max',
        description: 'أحدث هواتف آبل بكاميرا احترافية',
        price: 55000,
        costPrice: 48000,
        category: 'إلكترونيات',
        images: [
          'https://images.unsplash.com/photo-1592286927505-93fd55ce0c0f?w=400',
        ],
        stock: 8,
        soldCount: 45,
        sellerId: 'seller_2',
        sellerName: 'سارة علي',
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        isActive: true,
        commission: 0.12,
      ),
      Product(
        id: '3',
        name: 'سماعات Sony WH-1000XM5',
        description: 'سماعات بأفضل عزل للضوضاء',
        price: 8500,
        costPrice: 6800,
        category: 'إلكترونيات',
        images: [
          'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400',
        ],
        stock: 25,
        soldCount: 67,
        sellerId: 'seller_1',
        sellerName: 'محمد أحمد',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        isActive: true,
        commission: 0.15,
      ),
      Product(
        id: '4',
        name: 'كتاب البرمجة بلغة Dart',
        description: 'دليلك الشامل لتعلم Dart و Flutter',
        price: 250,
        costPrice: 180,
        category: 'كتب',
        images: [
          'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400',
        ],
        stock: 0,
        soldCount: 120,
        sellerId: 'seller_3',
        sellerName: 'أحمد حسن',
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        isActive: true,
        commission: 0.20,
      ),
      Product(
        id: '5',
        name: 'كرسي مكتب ergonomic',
        description: 'كرسي مريح للعمل الطويل',
        price: 3500,
        costPrice: 2800,
        category: 'أثاث',
        images: [
          'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400',
        ],
        stock: 12,
        soldCount: 34,
        sellerId: 'seller_2',
        sellerName: 'سارة علي',
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        isActive: true,
        commission: 0.10,
      ),
    ];
    notifyListeners();
  }

  // Load products from Firebase
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // في التطبيق الحقيقي، استخدم Firebase
      // final snapshot = await _firestore.collection(_collection).get();
      // _products = snapshot.docs
      //     .map((doc) => Product.fromMap(doc.data(), doc.id))
      //     .toList();

      // محاكاة التأخير
      await Future.delayed(Duration(milliseconds: 500));

      // البيانات التجريبية موجودة بالفعل من _initializeSampleData
    } catch (e) {
      _error = e.toString();
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    try {
      // في التطبيق الحقيقي:
      // await _firestore.collection(_collection).doc(product.id).set(product.toMap());

      _products.add(product);
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      // في التطبيق الحقيقي:
      // await _firestore.collection(_collection).doc(product.id).update(product.toMap());

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      // في التطبيق الحقيقي:
      // await _firestore.collection(_collection).doc(productId).delete();

      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Toggle product active status
  Future<void> toggleProductStatus(String productId) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final product = _products[index];
        _products[index] = product.copyWith(isActive: !product.isActive);

        // في التطبيق الحقيقي:
        // await _firestore.collection(_collection).doc(productId).update({
        //   'isActive': _products[index].isActive,
        // });

        notifyListeners();
      }
    } catch (e) {
      print('Error toggling product status: $e');
      rethrow;
    }
  }

  // Update stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(stock: newStock);

        // في التطبيق الحقيقي:
        // await _firestore.collection(_collection).doc(productId).update({
        //   'stock': newStock,
        // });

        notifyListeners();
      }
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }

  // Bulk update stocks
  Future<void> bulkUpdateStocks(Map<String, int> updates) async {
    try {
      for (var entry in updates.entries) {
        await updateStock(entry.key, entry.value);
      }
    } catch (e) {
      print('Error bulk updating stocks: $e');
      rethrow;
    }
  }

  // Get product by ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Get products by seller
  List<Product> getProductsBySeller(String sellerId) {
    return _products.where((p) => p.sellerId == sellerId).toList();
  }

  // Get low stock products
  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products.where((p) => p.stock < threshold && p.stock > 0).toList();
  }

  // Get out of stock products
  List<Product> getOutOfStockProducts() {
    return _products.where((p) => p.stock == 0).toList();
  }

  // Get top selling products
  List<Product> getTopSellingProducts({int limit = 10}) {
    final sorted = List<Product>.from(_products)
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return sorted.take(limit).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Export products to CSV
  Future<void> exportProducts() async {
    try {
      // في التطبيق الحقيقي، استخدم package للتصدير
      final csv = _productsToCSV();
      print('CSV Data: $csv');
      // يمكن حفظ الملف أو مشاركته
    } catch (e) {
      print('Error exporting products: $e');
      rethrow;
    }
  }

  String _productsToCSV() {
    final headers = [
      'الرقم',
      'الاسم',
      'الفئة',
      'السعر',
      'التكلفة',
      'المخزون',
      'المبيعات',
      'العمولة',
      'البائع',
      'الحالة',
    ];

    final rows = _products.map((p) {
      return [
        p.id,
        p.name,
        p.category,
        p.price,
        p.costPrice,
        p.stock,
        p.soldCount,
        '${(p.commission * 100).toInt()}%',
        p.sellerName,
        p.isActive ? 'نشط' : 'غير نشط',
      ].join(',');
    }).toList();

    return [headers.join(','), ...rows].join('\n');
  }

  // Import products from CSV
  Future<void> importProducts(String csvData) async {
    try {
      // تحليل CSV وإضافة المنتجات
      // هذه وظيفة متقدمة يمكن إضافتها لاحقاً
    } catch (e) {
      print('Error importing products: $e');
      rethrow;
    }
  }

  // Get category statistics
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (var product in _products) {
      stats[product.category] = (stats[product.category] ?? 0) + 1;
    }
    return stats;
  }

  // Get seller statistics
  Map<String, Map<String, dynamic>> getSellerStats() {
    final stats = <String, Map<String, dynamic>>{};

    for (var product in _products) {
      if (!stats.containsKey(product.sellerId)) {
        stats[product.sellerId] = {
          'name': product.sellerName,
          'products': 0,
          'sales': 0,
          'commission': 0.0,
        };
      }

      stats[product.sellerId]!['products'] += 1;
      stats[product.sellerId]!['sales'] += product.soldCount;
      stats[product.sellerId]!['commission'] += product.totalCommission;
    }

    return stats;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadProducts();
  }
}
