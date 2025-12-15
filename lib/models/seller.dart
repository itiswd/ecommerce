// lib/models/seller.dart
class Seller {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final DateTime joinDate;
  final int totalProducts;
  final int totalSales;
  final double totalRevenue;
  final double commissionRate;
  final double totalCommissionPaid;
  final bool isActive;
  final bool isVerified;
  final String? profileImage;
  final String? storeName;
  final String? storeDescription;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.country = 'مصر',
    required this.joinDate,
    this.totalProducts = 0,
    this.totalSales = 0,
    this.totalRevenue = 0,
    this.commissionRate = 0.10,
    this.totalCommissionPaid = 0,
    this.isActive = true,
    this.isVerified = false,
    this.profileImage,
    this.storeName,
    this.storeDescription,
  });

  // حساب العمولة المستحقة
  double get pendingCommission =>
      totalRevenue * commissionRate - totalCommissionPaid;

  // متوسط قيمة البيع
  double get averageSaleValue => totalSales > 0 ? totalRevenue / totalSales : 0;

  // تصنيف البائع
  String get sellerTier {
    if (totalRevenue >= 100000) return 'Platinum';
    if (totalRevenue >= 50000) return 'Gold';
    if (totalRevenue >= 20000) return 'Silver';
    return 'Bronze';
  }

  // معدل النشاط
  String get activityLevel {
    if (totalProducts >= 50 && totalSales >= 100) return 'نشط جداً';
    if (totalProducts >= 20 && totalSales >= 50) return 'نشط';
    if (totalProducts >= 10 && totalSales >= 20) return 'متوسط';
    return 'منخفض';
  }

  factory Seller.fromMap(Map<String, dynamic> map, String id) {
    return Seller(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? 'مصر',
      joinDate: map['joinDate']?.toDate() ?? DateTime.now(),
      totalProducts: map['totalProducts'] ?? 0,
      totalSales: map['totalSales'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      commissionRate: (map['commissionRate'] ?? 0.10).toDouble(),
      totalCommissionPaid: (map['totalCommissionPaid'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      profileImage: map['profileImage'],
      storeName: map['storeName'],
      storeDescription: map['storeDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'joinDate': joinDate,
      'totalProducts': totalProducts,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'commissionRate': commissionRate,
      'totalCommissionPaid': totalCommissionPaid,
      'isActive': isActive,
      'isVerified': isVerified,
      'profileImage': profileImage,
      'storeName': storeName,
      'storeDescription': storeDescription,
    };
  }

  Seller copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    int? totalProducts,
    int? totalSales,
    double? totalRevenue,
    double? commissionRate,
    double? totalCommissionPaid,
    bool? isActive,
    bool? isVerified,
    String? profileImage,
    String? storeName,
    String? storeDescription,
  }) {
    return Seller(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      joinDate: joinDate,
      totalProducts: totalProducts ?? this.totalProducts,
      totalSales: totalSales ?? this.totalSales,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      commissionRate: commissionRate ?? this.commissionRate,
      totalCommissionPaid: totalCommissionPaid ?? this.totalCommissionPaid,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      profileImage: profileImage ?? this.profileImage,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
    );
  }
}
