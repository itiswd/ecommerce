// lib/models/customer.dart
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String? profileImage;
  final DateTime joinDate;
  final int totalOrders;
  final double totalSpent;
  final double cashbackBalance; // رصيد الكاش باك
  final bool isActive;
  final List<Address> addresses; // عناوين التوصيل

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.country = 'مصر',
    this.profileImage,
    required this.joinDate,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.cashbackBalance = 0,
    this.isActive = true,
    this.addresses = const [],
  });

  // حساب متوسط قيمة الطلب
  double get averageOrderValue =>
      totalOrders > 0 ? totalSpent / totalOrders : 0;

  // تصنيف العميل بناءً على الإنفاق
  String get customerTier {
    if (totalSpent >= 50000) return 'VIP';
    if (totalSpent >= 20000) return 'Gold';
    if (totalSpent >= 10000) return 'Silver';
    return 'Bronze';
  }

  // تحويل من Firestore
  factory Customer.fromMap(Map<String, dynamic> map, String id) {
    return Customer(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? 'مصر',
      profileImage: map['profileImage'],
      joinDate: map['joinDate']?.toDate() ?? DateTime.now(),
      totalOrders: map['totalOrders'] ?? 0,
      totalSpent: (map['totalSpent'] ?? 0).toDouble(),
      cashbackBalance: (map['cashbackBalance'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      addresses: map['addresses'] != null
          ? (map['addresses'] as List)
                .map((addr) => Address.fromMap(addr))
                .toList()
          : [],
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'profileImage': profileImage,
      'joinDate': joinDate,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'cashbackBalance': cashbackBalance,
      'isActive': isActive,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
    };
  }

  // نسخ مع تعديلات
  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? profileImage,
    int? totalOrders,
    double? totalSpent,
    double? cashbackBalance,
    bool? isActive,
    List<Address>? addresses,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      profileImage: profileImage ?? this.profileImage,
      joinDate: joinDate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      isActive: isActive ?? this.isActive,
      addresses: addresses ?? this.addresses,
    );
  }
}

// عنوان التوصيل
class Address {
  final String id;
  final String label; // مثل: "المنزل"، "العمل"
  final String fullAddress;
  final String city;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? landmark; // علامة مميزة
  final bool isDefault; // العنوان الافتراضي

  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      city: map['city'] ?? '',
      building: map['building'],
      floor: map['floor'],
      apartment: map['apartment'],
      landmark: map['landmark'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }
}
