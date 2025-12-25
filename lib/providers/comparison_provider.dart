// lib/providers/comparison_provider.dart
import 'dart:convert';

import 'package:ecommerce_dashboard/models/comparison.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComparisonProvider extends ChangeNotifier {
  List<String> _productIds = [];
  final Map<String, Product> _products = {};
  bool _isLoading = false;
  static const int maxProducts = 3; // الحد الأقصى للمنتجات في المقارنة

  // Getters
  List<String> get productIds => _productIds;
  Map<String, Product> get products => _products;
  bool get isLoading => _isLoading;
  int get count => _productIds.length;
  bool get isFull => _productIds.length >= maxProducts;
  bool get isEmpty => _productIds.isEmpty;

  // الحصول على المنتجات كقائمة
  List<Product> get productsList {
    return _productIds.map((id) => _products[id]).whereType<Product>().toList();
  }

  ComparisonProvider() {
    _loadComparison();
  }

  // تحميل المقارنة من التخزين المحلي
  Future<void> _loadComparison() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final idsJson = prefs.getString('comparison_ids');

      if (idsJson != null) {
        _productIds = List<String>.from(json.decode(idsJson));
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل المقارنة: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // حفظ المقارنة في التخزين المحلي
  Future<void> _saveComparison() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('comparison_ids', json.encode(_productIds));
    } catch (e) {
      debugPrint('❌ خطأ في حفظ المقارنة: $e');
    }
  }

  // إضافة منتج للمقارنة
  bool addProduct(Product product) {
    if (isFull) {
      debugPrint('⚠️ تم الوصول للحد الأقصى للمنتجات في المقارنة');
      return false;
    }

    if (_productIds.contains(product.id)) {
      debugPrint('⚠️ المنتج موجود بالفعل في المقارنة');
      return false;
    }

    _productIds.add(product.id);
    _products[product.id] = product;
    _saveComparison();
    notifyListeners();
    return true;
  }

  // إزالة منتج من المقارنة
  void removeProduct(String productId) {
    _productIds.remove(productId);
    _products.remove(productId);
    _saveComparison();
    notifyListeners();
  }

  // مسح المقارنة بالكامل
  void clearComparison() {
    _productIds.clear();
    _products.clear();
    _saveComparison();
    notifyListeners();
  }

  // التحقق من وجود منتج في المقارنة
  bool contains(String productId) {
    return _productIds.contains(productId);
  }

  // استبدال منتج بآخر
  void replaceProduct(String oldProductId, Product newProduct) {
    final index = _productIds.indexOf(oldProductId);
    if (index >= 0) {
      _productIds[index] = newProduct.id;
      _products.remove(oldProductId);
      _products[newProduct.id] = newProduct;
      _saveComparison();
      notifyListeners();
    }
  }

  // تحميل بيانات المنتجات (في حالة عدم توفرها)
  void loadProduct(Product product) {
    if (!_products.containsKey(product.id) &&
        _productIds.contains(product.id)) {
      _products[product.id] = product;
      notifyListeners();
    }
  }

  // الحصول على نتائج المقارنة
  List<ComparisonResult> getComparisonResults() {
    final products = productsList;
    if (products.isEmpty) return [];

    return ComparisonHelper.compareProducts(products);
  }

  // الحصول على ملخص المقارنة كنص (للمشاركة)
  String getComparisonSummary() {
    final results = getComparisonResults();
    if (results.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('📊 مقارنة المنتجات - مكنتي');
    buffer.writeln('');

    // أسماء المنتجات
    final products = productsList;
    for (int i = 0; i < products.length; i++) {
      buffer.writeln('${i + 1}. ${products[i].name}');
    }
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');

    // النتائج
    for (final result in results) {
      buffer.writeln('📌 ${result.label}:');
      for (int i = 0; i < result.values.length; i++) {
        final value = result.values[i];
        final marker = value.isBest ? '✅' : '  ';
        buffer.writeln('$marker ${i + 1}. ${value.value}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  // تحديد الأفضل حسب معيار معين
  String? getBestByPrice() {
    final products = productsList;
    if (products.isEmpty) return null;
    return ComparisonHelper.getBestPrice(products);
  }
}
