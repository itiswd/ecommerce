// lib/models/comparison.dart
import 'package:ecommerce_dashboard/models/product.dart';

class Comparison {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime createdAt;
  final String? name; // اسم المقارنة (اختياري)

  Comparison({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.createdAt,
    this.name,
  });

  // تحويل من Firestore
  factory Comparison.fromMap(Map<String, dynamic> map, String id) {
    return Comparison(
      id: id,
      userId: map['userId'] ?? '',
      productIds: List<String>.from(map['productIds'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      name: map['name'],
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productIds': productIds,
      'createdAt': createdAt,
      'name': name,
    };
  }
}

// نتيجة المقارنة لخاصية معينة
class ComparisonResult {
  final String key; // مفتاح الخاصية
  final String label; // اسم الخاصية بالعربية
  final List<ComparisonValue> values; // القيم لكل منتج
  final String? bestProductId; // المنتج الأفضل في هذه الخاصية

  ComparisonResult({
    required this.key,
    required this.label,
    required this.values,
    this.bestProductId,
  });
}

// قيمة المقارنة لمنتج معين
class ComparisonValue {
  final String productId;
  final String value;
  final bool isBest;

  ComparisonValue({
    required this.productId,
    required this.value,
    this.isBest = false,
  });
}

// مساعد لتحديد الأفضل في المقارنة
class ComparisonHelper {
  // تحديد المنتج الأفضل في السعر (الأقل)
  static String? getBestPrice(List<Product> products) {
    if (products.isEmpty) return null;
    final sorted = [...products]..sort((a, b) => a.price.compareTo(b.price));
    return sorted.first.id;
  }

  // تحديد المنتج الأفضل في خاصية رقمية (الأعلى)
  static String? getBestNumericValue(
    List<Product> products,
    String specKey, {
    bool higherIsBetter = true,
  }) {
    if (products.isEmpty) return null;

    Product? best;
    double? bestValue;

    for (final product in products) {
      final valueStr = product.specifications[specKey];
      if (valueStr == null) continue;

      // محاولة استخراج الرقم من النص
      final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(valueStr);
      if (numMatch == null) continue;

      final value = double.tryParse(numMatch.group(1)!);
      if (value == null) continue;

      if (bestValue == null ||
          (higherIsBetter && value > bestValue) ||
          (!higherIsBetter && value < bestValue)) {
        bestValue = value;
        best = product;
      }
    }

    return best?.id;
  }

  // مقارنة المواصفات الشائعة
  static List<ComparisonResult> compareProducts(List<Product> products) {
    if (products.isEmpty) return [];

    final results = <ComparisonResult>[];

    // مقارنة السعر
    results.add(ComparisonResult(
      key: 'price',
      label: 'السعر',
      values: products
          .map((p) => ComparisonValue(
                productId: p.id,
                value: '${p.price} جنيه',
                isBest: p.id == getBestPrice(products),
              ))
          .toList(),
      bestProductId: getBestPrice(products),
    ));

    // الحصول على جميع المواصفات المشتركة
    final allSpecKeys = <String>{};
    for (final product in products) {
      allSpecKeys.addAll(product.specifications.keys);
    }

    // المواصفات التي نريد مقارنتها (بترتيب محدد)
    final importantSpecs = [
      'السرعة',
      'نوع الموتور',
      'استهلاك الكهرباء',
      'بلد المنشأ',
      'الوزن',
      'الضمان',
    ];

    for (final specKey in importantSpecs) {
      if (!allSpecKeys.contains(specKey)) continue;

      // تحديد الأفضل حسب نوع المواصفة
      String? bestId;
      if (specKey == 'السرعة') {
        bestId = getBestNumericValue(products, specKey, higherIsBetter: true);
      } else if (specKey == 'استهلاك الكهرباء') {
        bestId = getBestNumericValue(products, specKey, higherIsBetter: false);
      } else if (specKey == 'الضمان') {
        bestId = getBestNumericValue(products, specKey, higherIsBetter: true);
      }

      results.add(ComparisonResult(
        key: specKey,
        label: specKey,
        values: products
            .map((p) => ComparisonValue(
                  productId: p.id,
                  value: p.specifications[specKey] ?? '-',
                  isBest: bestId != null && p.id == bestId,
                ))
            .toList(),
        bestProductId: bestId,
      ));
    }

    // إضافة باقي المواصفات
    for (final specKey in allSpecKeys) {
      if (importantSpecs.contains(specKey) || specKey == 'price') continue;

      results.add(ComparisonResult(
        key: specKey,
        label: specKey,
        values: products
            .map((p) => ComparisonValue(
                  productId: p.id,
                  value: p.specifications[specKey] ?? '-',
                ))
            .toList(),
      ));
    }

    return results;
  }
}
