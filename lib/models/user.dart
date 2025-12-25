// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final double cashbackBalance;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isGuest;
  final List<String> savedAddressIds;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.cashbackBalance = 0.0,
    required this.createdAt,
    this.lastLoginAt,
    this.isGuest = false,
    this.savedAddressIds = const [],
  });

  // تحويل من Firestore
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      cashbackBalance: (map['cashbackBalance'] ?? 0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastLoginAt: map['lastLoginAt']?.toDate(),
      isGuest: map['isGuest'] ?? false,
      savedAddressIds: List<String>.from(map['savedAddressIds'] ?? []),
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'cashbackBalance': cashbackBalance,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isGuest': isGuest,
      'savedAddressIds': savedAddressIds,
    };
  }

  // نسخ مع تعديلات
  User copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    double? cashbackBalance,
    DateTime? lastLoginAt,
    bool? isGuest,
    List<String>? savedAddressIds,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isGuest: isGuest ?? this.isGuest,
      savedAddressIds: savedAddressIds ?? this.savedAddressIds,
    );
  }
}
