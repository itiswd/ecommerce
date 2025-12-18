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

  // Initialize with sample data
  ProductsProvider() {
    loadProducts();
  }

  // Load products from Firebase
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collection).get();

      if (snapshot.docs.isEmpty) {
        await _addSampleData();
        final newSnapshot = await _firestore.collection(_collection).get();
        _products = newSnapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        _products = snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $e');
      _loadLocalSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة بيانات تجريبية لـ Firebase
  Future<void> _addSampleData() async {
    final sampleProducts = [
      Product(
        id: '1',
        name: 'لابتوب Dell XPS 15',
        description: 'لابتوب عالي الأداء مثالي للمصممين والمبرمجين',
        price: 45000,
        costPrice: 38000,
        originalPrice: 50000,
        category: 'إلكترونيات',
        images: [
          'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400',
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400',
        ],
        stock: 15,
        soldCount: 23,
        sellerId: 'seller_1',
        sellerName: 'بائع 1',
        commission: 0.10,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        isActive: true,
        isFeatured: true,
        specifications: {
          'المعالج': 'Intel Core i7-12700H',
          'الرام': '16GB DDR5',
          'التخزين': '512GB SSD',
          'الشاشة': '15.6 بوصة FHD',
          'كرت الشاشة': 'NVIDIA RTX 3050',
        },
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
        sellerId: 'seller_1',
        sellerName: 'بائع 1',
        commission: 0.12,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        isActive: true,
        isFeatured: true,
        specifications: {
          'المعالج': 'Apple A17 Pro',
          'الرام': '8GB',
          'التخزين': '256GB',
          'الشاشة': '6.7 بوصة Super Retina XDR',
          'الكاميرا': '48MP رئيسية + 12MP فائقة الاتساع',
        },
      ),
      Product(
        id: '3',
        name: 'سماعات Sony WH-1000XM5',
        description: 'سماعات بأفضل عزل للضوضاء',
        price: 8500,
        costPrice: 6800,
        originalPrice: 9500,
        category: 'إلكترونيات',
        images: [
          'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400',
        ],
        stock: 25,
        soldCount: 67,
        sellerId: 'seller_2',
        sellerName: 'بائع 2',
        commission: 0.15,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        isActive: true,
        specifications: {
          'النوع': 'سماعات فوق الأذن لاسلكية',
          'عزل الضوضاء': 'نشط (ANC)',
          'البطارية': 'حتى 30 ساعة',
          'البلوتوث': '5.3',
        },
      ),
      Product(
        id: '4',
        name: 'كتاب البرمجة بلغة Dart',
        description: 'دليلك الشامل لتعلم Dart و Flutter',
        price: 250,
        costPrice: 150,
        category: 'كتب',
        images: [
          'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400',
        ],
        stock: 0,
        soldCount: 120,
        sellerId: 'seller_3',
        sellerName: 'بائع 3',
        commission: 0.20,
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        isActive: true,
        specifications: {
          'المؤلف': 'أحمد محمد',
          'عدد الصفحات': '420',
          'الناشر': 'دار النشر العربية',
          'اللغة': 'العربية',
        },
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
        sellerName: 'بائع 2',
        commission: 0.10,
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        isActive: true,
        specifications: {
          'المادة': 'قماش شبكي مع قاعدة معدنية',
          'الارتفاع قابل للتعديل': 'نعم',
          'مسند الظهر': 'قابل للإمالة',
          'الوزن الأقصى': '120 كجم',
        },
      ),
    ];

    for (var product in sampleProducts) {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .set(product.toMap());
    }
  }

  // بيانات محلية في حالة فشل Firebase
  void _loadLocalSampleData() {
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
        ],
        stock: 15,
        soldCount: 23,
        sellerId: 'seller_1',
        sellerName: 'بائع 1',
        commission: 0.10,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        isActive: true,
        specifications: {'المعالج': 'Intel Core i7', 'الرام': '16GB'},
      ),
    ];
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .set(product.toMap());
      _products.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toMap());

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Toggle product active status
  Future<void> toggleProductStatus(String productId) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final product = _products[index];
        final newStatus = !product.isActive;

        await _firestore.collection(_collection).doc(productId).update({
          'isActive': newStatus,
        });

        _products[index] = product.copyWith(isActive: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling product status: $e');
      rethrow;
    }
  }

  // Update stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stock': newStock,
      });

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(stock: newStock);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating stock: $e');
      rethrow;
    }
  }

  // Export products to CSV
  Future<void> exportProducts() async {
    try {
      final csv = _productsToCSV();
      debugPrint('CSV Data: $csv');
    } catch (e) {
      debugPrint('Error exporting products: $e');
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
      'البائع',
      'العمولة',
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
        p.sellerName,
        '${(p.commission * 100).toInt()}%',
        p.isActive ? 'نشط' : 'غير نشط',
      ].join(',');
    }).toList();

    return [headers.join(','), ...rows].join('\n');
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

  // Refresh data
  Future<void> refresh() async {
    await loadProducts();
  }
}
