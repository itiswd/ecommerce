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
    (summ, product) => summ + (product.price * product.stock),
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
        name: 'ماكينة خياطة صناعية Jack A4',
        description: 'ماكينة خياطة صناعية عالية الجودة مثالية للإنتاج الكثيف',
        price: 8500,
        costPrice: 7000,
        originalPrice: 9500,
        category: 'ماكينات صناعي',
        images: [
          'https://images.unsplash.com/photo-1597740985671-2a8a3b3b3b3b?w=400',
        ],
        stock: 15,
        soldCount: 23,
        sellerId: 'seller_1',
        sellerName: 'المؤسسة المصرية',
        commission: 0.10,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        isActive: true,
        isFeatured: true,
        specifications: {
          'السرعة': '5000 غرزة/دقيقة',
          'نوع الموتور': 'موتور سيرفو',
          'توفير الكهرباء': '70%',
          'بلد المنشأ': 'الصين',
          'الضمان': 'سنة',
        },
      ),
      Product(
        id: '2',
        name: 'ماكينة خياطة منزلية Juki HZL-F600',
        description: 'ماكينة خياطة منزلية متعددة الاستخدامات',
        price: 12000,
        costPrice: 10000,
        category: 'ماكينات منزلي',
        images: [
          'https://images.unsplash.com/photo-1526045612212-70caf35c14df?w=400',
        ],
        stock: 8,
        soldCount: 45,
        sellerId: 'seller_1',
        sellerName: 'المؤسسة المصرية',
        commission: 0.12,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        isActive: true,
        isFeatured: true,
        specifications: {
          'عدد الغرز': '225 غرزة',
          'السرعة': '900 غرزة/دقيقة',
          'الشاشة': 'LCD',
          'الإضاءة': 'LED',
          'الوزن': '9 كجم',
        },
      ),
      Product(
        id: '3',
        name: 'قدم الزيبر الصناعي',
        description: 'قدم زيبر عالي الجودة للماكينات الصناعية',
        price: 250,
        costPrice: 180,
        originalPrice: 300,
        category: 'قطع غيار',
        images: [
          'https://images.unsplash.com/photo-1565688534245-05d6b5be184a?w=400',
        ],
        stock: 50,
        soldCount: 120,
        sellerId: 'seller_2',
        sellerName: 'بائع 2',
        commission: 0.15,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        isActive: true,
        specifications: {
          'النوع': 'قدم زيبر',
          'التوافق': 'جميع الماكينات الصناعية',
          'المادة': 'معدن',
        },
      ),
      Product(
        id: '4',
        name: 'ماكينة تطريز Brother PR1050X',
        description: 'ماكينة تطريز احترافية 10 إبرة',
        price: 95000,
        costPrice: 85000,
        category: 'ماكينات تطريز',
        images: [
          'https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?w=400',
        ],
        stock: 3,
        soldCount: 8,
        sellerId: 'seller_3',
        sellerName: 'بائع 3',
        commission: 0.10,
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        isActive: true,
        isFeatured: true,
        specifications: {
          'عدد الإبر': '10 إبرة',
          'مساحة التطريز': '360 x 200 مم',
          'السرعة': '1000 غرزة/دقيقة',
          'الذاكرة': '4 جيجابايت',
        },
      ),
      Product(
        id: '5',
        name: 'بكرة خيط صناعي - أبيض',
        description: 'بكرة خيط عالي الجودة 5000 ياردة',
        price: 85,
        costPrice: 60,
        category: 'قطع غيار',
        images: [
          'https://images.unsplash.com/photo-1576169430570-2f5f356cd73d?w=400',
        ],
        stock: 200,
        soldCount: 350,
        sellerId: 'seller_2',
        sellerName: 'بائع 2',
        commission: 0.20,
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        isActive: true,
        specifications: {
          'الطول': '5000 ياردة',
          'اللون': 'أبيض',
          'المادة': 'بوليستر',
          'السُمك': '40/2',
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
        name: 'ماكينة خياطة صناعية Jack A4',
        description: 'ماكينة خياطة صناعية عالية الجودة',
        price: 8500,
        costPrice: 7000,
        category: 'ماكينات صناعي',
        images: [
          'https://images.unsplash.com/photo-1597740985671-2a8a3b3b3b3b?w=400',
        ],
        stock: 15,
        soldCount: 23,
        sellerId: 'seller_1',
        sellerName: 'المؤسسة المصرية',
        commission: 0.10,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        isActive: true,
        specifications: {
          'السرعة': '5000 غرزة/دقيقة',
          'نوع الموتور': 'موتور سيرفو',
        },
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
