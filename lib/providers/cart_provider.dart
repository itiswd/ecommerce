// lib/providers/cart_provider.dart
import 'dart:convert';

import 'package:ecommerce_dashboard/models/cart_item.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  double _shippingFee = 50.0; // رسوم شحن افتراضية

  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  double get shippingFee => _shippingFee;

  // حساب الإجمالي قبل الشحن
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // حساب الإجمالي بعد الشحن
  double get total => subtotal + shippingFee;

  // حساب الإجمالي بعد استخدام الكاش باك
  double getTotalWithCashback(double cashbackUsed) {
    final totalWithCashback = total - cashbackUsed;
    return totalWithCashback > 0 ? totalWithCashback : 0;
  }

  // حساب إجمالي الوفورات (الخصومات)
  double get totalSavings {
    return _items.fold(0.0, (sum, item) {
      if (item.hasDiscount) {
        return sum + ((item.originalPrice! - item.price) * item.quantity);
      }
      return sum;
    });
  }

  CartProvider() {
    _loadCart();
  }

  // تحميل السلة من التخزين المحلي
  Future<void> _loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');

      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        _items = cartList.map((item) => CartItem.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل السلة: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // حفظ السلة في التخزين المحلي
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toMap()).toList());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      debugPrint('❌ خطأ في حفظ السلة: $e');
    }
  }

  // إضافة منتج إلى السلة
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // المنتج موجود - زيادة الكمية
      _items[existingIndex].quantity += quantity;
    } else {
      // منتج جديد - إضافته
      _items.add(CartItem.fromProduct(product, quantity: quantity));
    }

    _saveCart();
    notifyListeners();
  }

  // تحديث كمية منتج
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      _saveCart();
      notifyListeners();
    }
  }

  // زيادة الكمية
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  // تقليل الكمية
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _saveCart();
        notifyListeners();
      } else {
        removeFromCart(productId);
      }
    }
  }

  // إزالة منتج من السلة
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveCart();
    notifyListeners();
  }

  // مسح السلة بالكامل
  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // التحقق من وجود منتج في السلة
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // الحصول على كمية منتج معين
  int getProductQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        productId: '',
        productName: '',
        productImage: '',
        price: 0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // تحديث رسوم الشحن
  void updateShippingFee(double fee) {
    _shippingFee = fee;
    notifyListeners();
  }

  // حساب رسوم الشحن حسب المحافظة
  void calculateShippingFee(String governorate) {
    // رسوم الشحن حسب المحافظة (مثال)
    final fees = {
      'القاهرة': 30.0,
      'الجيزة': 30.0,
      'الإسكندرية': 50.0,
      'الدقهلية': 60.0,
      'الشرقية': 60.0,
      'المنوفية': 50.0,
      'القليوبية': 40.0,
      'البحيرة': 60.0,
    };

    _shippingFee = fees[governorate] ?? 70.0; // 70 جنيه للمحافظات الأخرى
    notifyListeners();
  }
}
