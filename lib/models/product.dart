class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double costPrice;
  final String category;
  final List<String> images;
  final int stock;
  final int soldCount;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final bool isActive;
  final double commission; // نسبة العمولة (مثال: 0.15 = 15%)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.costPrice,
    required this.category,
    required this.images,
    required this.stock,
    this.soldCount = 0,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.isActive = true,
    this.commission = 0.10,
  });

  // حساب الربح من المنتج
  double get profit => (price - costPrice) * soldCount;

  // حساب العمولة الكلية
  double get totalCommission => price * soldCount * commission;

  // تحويل من/إلى Firestore
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      stock: map['stock'] ?? 0,
      soldCount: map['soldCount'] ?? 0,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      commission: (map['commission'] ?? 0.10).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'costPrice': costPrice,
      'category': category,
      'images': images,
      'stock': stock,
      'soldCount': soldCount,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': createdAt,
      'isActive': isActive,
      'commission': commission,
    };
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? costPrice,
    String? category,
    List<String>? images,
    int? stock,
    int? soldCount,
    bool? isActive,
    double? commission,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      category: category ?? this.category,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      soldCount: soldCount ?? this.soldCount,
      sellerId: sellerId,
      sellerName: sellerName,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      commission: commission ?? this.commission,
    );
  }
}
