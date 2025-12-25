// lib/models/cart_item.dart
import 'package:ecommerce_dashboard/models/product.dart';

class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double? originalPrice;
  int quantity;
  final Map<String, String> specifications;
  final double commission;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.originalPrice,
    this.quantity = 1,
    this.specifications = const {},
    this.commission = 0.10,
  });

  // الإجمالي لهذا العنصر
  double get subtotal => price * quantity;

  // هل لديه خصم؟
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // نسبة الخصم
  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  // إنشاء من Product
  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      productName: product.name,
      productImage: product.images.isNotEmpty ? product.images.first : '',
      price: product.price,
      originalPrice: product.originalPrice,
      quantity: quantity,
      specifications: product.specifications,
      commission: product.commission,
    );
  }

  // تحويل من Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      quantity: map['quantity'] ?? 1,
      specifications: Map<String, String>.from(map['specifications'] ?? {}),
      commission: (map['commission'] ?? 0.10).toDouble(),
    );
  }

  // تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'specifications': specifications,
      'commission': commission,
    };
  }

  // نسخ مع تعديلات
  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      originalPrice: originalPrice,
      quantity: quantity ?? this.quantity,
      specifications: specifications,
      commission: commission,
    );
  }
}
