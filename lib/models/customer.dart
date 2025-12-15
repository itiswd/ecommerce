// lib/models/customer.dart
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final DateTime joinDate;
  final int totalOrders;
  final double totalSpent;
  final bool isActive;
  final String? profileImage;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.country = 'مصر',
    required this.joinDate,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.isActive = true,
    this.profileImage,
  });

  // حساب متوسط قيمة الطلب
  double get averageOrderValue =>
      totalOrders > 0 ? totalSpent / totalOrders : 0;

  // تصنيف العميل
  String get customerTier {
    if (totalSpent >= 50000) return 'VIP';
    if (totalSpent >= 20000) return 'Gold';
    if (totalSpent >= 5000) return 'Silver';
    return 'Bronze';
  }

  factory Customer.fromMap(Map<String, dynamic> map, String id) {
    return Customer(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? 'مصر',
      joinDate: map['joinDate']?.toDate() ?? DateTime.now(),
      totalOrders: map['totalOrders'] ?? 0,
      totalSpent: (map['totalSpent'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      profileImage: map['profileImage'],
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
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'isActive': isActive,
      'profileImage': profileImage,
    };
  }

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    int? totalOrders,
    double? totalSpent,
    bool? isActive,
    String? profileImage,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      joinDate: joinDate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
