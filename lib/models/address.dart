// lib/models/address.dart
class Address {
  final String id;
  final String userId;
  final String label; // مثل: "المنزل"، "العمل"، إلخ
  final String governorate; // المحافظة
  final String city; // المدينة
  final String street; // الشارع
  final String buildingNumber; // رقم المبنى
  final String? floor; // الطابق (اختياري)
  final String? apartment; // الشقة (اختياري)
  final String? landmark; // علامة مميزة (اختياري)
  final String phone;
  final bool isDefault; // العنوان الافتراضي
  final DateTime createdAt;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.governorate,
    required this.city,
    required this.street,
    required this.buildingNumber,
    this.floor,
    this.apartment,
    this.landmark,
    required this.phone,
    this.isDefault = false,
    required this.createdAt,
  });

  // العنوان الكامل
  String get fullAddress {
    final parts = [
      buildingNumber,
      street,
      if (floor != null) 'الطابق $floor',
      if (apartment != null) 'شقة $apartment',
      city,
      governorate,
    ];
    return parts.join('، ');
  }

  // تحويل من Firestore
  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      userId: map['userId'] ?? '',
      label: map['label'] ?? '',
      governorate: map['governorate'] ?? '',
      city: map['city'] ?? '',
      street: map['street'] ?? '',
      buildingNumber: map['buildingNumber'] ?? '',
      floor: map['floor'],
      apartment: map['apartment'],
      landmark: map['landmark'],
      phone: map['phone'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'label': label,
      'governorate': governorate,
      'city': city,
      'street': street,
      'buildingNumber': buildingNumber,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
      'phone': phone,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }

  // نسخ مع تعديلات
  Address copyWith({
    String? label,
    String? governorate,
    String? city,
    String? street,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? landmark,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      userId: userId,
      label: label ?? this.label,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      street: street ?? this.street,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}

// المحافظات المصرية
class EgyptGovernorates {
  static const List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'المنوفية',
    'القليوبية',
    'البحيرة',
    'الغربية',
    'كفر الشيخ',
    'دمياط',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'شمال سيناء',
    'جنوب سيناء',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
    'مطروح',
  ];

  // المدن حسب المحافظة (مثال مبسط - يمكن توسيعه)
  static Map<String, List<String>> cities = {
    'القاهرة': [
      'مدينة نصر',
      'المعادي',
      'حلوان',
      'مصر الجديدة',
      'الزمالك',
      'الدقي',
      'المهندسين',
      'شبرا',
      'الزيتون',
      'عين شمس',
      'التجمع الخامس',
      'مدينتي',
    ],
    'الجيزة': [
      'الهرم',
      '6 أكتوبر',
      'الشيخ زايد',
      'فيصل',
      'الدقي',
      'المهندسين',
      'العمرانية',
      'البدرشين',
    ],
    'الإسكندرية': [
      'المنتزه',
      'محرم بك',
      'سيدي جابر',
      'ميامي',
      'سموحة',
      'العصافرة',
      'أبو قير',
      'العامرية',
    ],
    // يمكن إضافة باقي المحافظات والمدن
  };

  static List<String> getCities(String governorate) {
    return cities[governorate] ?? ['المركز'];
  }
}
