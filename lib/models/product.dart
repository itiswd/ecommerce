// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // السعر قبل الخصم (اختياري)
  final String category;
  final List<String> images;
  final int stock;
  final int soldCount;
  final DateTime createdAt;
  final bool isActive;
  final bool isFeatured; // منتج مميز (يظهر في الأكثر مبيعاً)
  final Map<String, String> specifications; // المواصفات التفصيلية

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.images,
    required this.stock,
    this.soldCount = 0,
    required this.createdAt,
    this.isActive = true,
    this.isFeatured = false,
    this.specifications = const {},
  });

  // حساب نسبة الخصم
  double? get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  // هل المنتج متوفر؟
  bool get isAvailable => isActive && stock > 0;

  // هل المنتج في حالة خصم؟
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // إجمالي الإيرادات من هذا المنتج
  double get totalRevenue => price * soldCount;

  // تحويل من Firestore
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      stock: map['stock'] ?? 0,
      soldCount: map['soldCount'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      specifications: Map<String, String>.from(map['specifications'] ?? {}),
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'images': images,
      'stock': stock,
      'soldCount': soldCount,
      'createdAt': createdAt,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'specifications': specifications,
    };
  }

  // نسخ المنتج مع تعديلات
  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    List<String>? images,
    int? stock,
    int? soldCount,
    bool? isActive,
    bool? isFeatured,
    Map<String, String>? specifications,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      soldCount: soldCount ?? this.soldCount,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      specifications: specifications ?? this.specifications,
    );
  }
}
