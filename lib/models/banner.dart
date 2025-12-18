// lib/models/banner.dart
class BannerModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final BannerType type;
  final String? targetId; // معرف المنتج أو القسم المستهدف
  final int order; // ترتيب العرض
  final bool isActive;
  final DateTime createdAt;
  final DateTime? startDate; // تاريخ بداية العرض
  final DateTime? endDate; // تاريخ نهاية العرض

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.type = BannerType.general,
    this.targetId,
    this.order = 0,
    this.isActive = true,
    required this.createdAt,
    this.startDate,
    this.endDate,
  });

  // هل البانر نشط حالياً؟
  bool get isCurrentlyActive {
    if (!isActive) return false;

    final now = DateTime.now();

    // تحقق من تاريخ البداية
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }

    // تحقق من تاريخ النهاية
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }

    return true;
  }

  // تحويل من Firestore
  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'] ?? '',
      type: BannerType.values.firstWhere(
        (e) => e.toString() == 'BannerType.${map['type']}',
        orElse: () => BannerType.general,
      ),
      targetId: map['targetId'],
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      startDate: map['startDate']?.toDate(),
      endDate: map['endDate']?.toDate(),
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'targetId': targetId,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // نسخ مع تعديلات
  BannerModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    BannerType? type,
    String? targetId,
    int? order,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BannerModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// أنواع البانرات
enum BannerType {
  general, // عام (بدون رابط)
  product, // يوجه لمنتج معين
  category, // يوجه لقسم معين
  url, // يوجه لرابط خارجي
}

// ترجمة أنواع البانرات
extension BannerTypeExtension on BannerType {
  String get arabicName {
    switch (this) {
      case BannerType.general:
        return 'عام';
      case BannerType.product:
        return 'منتج';
      case BannerType.category:
        return 'قسم';
      case BannerType.url:
        return 'رابط خارجي';
    }
  }
}
