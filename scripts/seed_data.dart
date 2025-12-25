// scripts/seed_data.dart
// Script لإضافة بيانات تجريبية للمشروع
// يمكن تشغيله من خلال: dart run scripts/seed_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  debugPrint('🌱 بدء إضافة البيانات التجريبية...\n');

  // تهيئة Firebase
  // ملاحظة: تأكد من إعداد Firebase قبل تشغيل هذا السكريبت
  try {
    await Firebase.initializeApp();
    debugPrint('✅ تم تهيئة Firebase بنجاح\n');
  } catch (e) {
    debugPrint('❌ خطأ في تهيئة Firebase: $e');
    return;
  }

  final firestore = FirebaseFirestore.instance;

  // 1. إضافة منتجات
  await _seedProducts(firestore);

  // 2. إضافة بانرات
  await _seedBanners(firestore);

  debugPrint('\n✅ تم إضافة جميع البيانات التجريبية بنجاح!');
  debugPrint(
    '📝 ملاحظة: لا تنسى إضافة مستخدم Admin يدوياً من Firebase Console',
  );
}

Future<void> _seedProducts(FirebaseFirestore firestore) async {
  debugPrint('📦 إضافة المنتجات...');

  final products = [
    // ماكينات صناعي
    {
      'id': 'prod_001',
      'name': 'ماكينة خياطة جاك صناعي A5',
      'nameEn': 'Jack Industrial A5',
      'description': 'ماكينة خياطة صناعية عالية الأداء للإنتاج الكثيف',
      'category': 'ماكينات صناعي',
      'brand': 'Jack',
      'condition': 'جديد',
      'price': 15000.0,
      'discount': 10.0,
      'finalPrice': 13500.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample.jpg',
      ],
      'specifications': {
        'السرعة': '5000 غرزة/دقيقة',
        'القدرة': '550 واط',
        'الوزن': '35 كجم',
        'الضمان': 'سنتان',
      },
      'isActive': true,
      'stock': 10,
      'sold': 5,
      'rating': 4.5,
      'reviewsCount': 12,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'prod_002',
      'name': 'ماكينة خياطة جوكي JK-8720',
      'nameEn': 'Juki JK-8720',
      'description': 'ماكينة صناعية من جوكي للخياطة الثقيلة',
      'category': 'ماكينات صناعي',
      'brand': 'Juki',
      'condition': 'جديد',
      'price': 18000.0,
      'discount': 15.0,
      'finalPrice': 15300.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample2.jpg',
      ],
      'specifications': {
        'السرعة': '5500 غرزة/دقيقة',
        'القدرة': '600 واط',
        'الوزن': '38 كجم',
        'الضمان': '3 سنوات',
      },
      'isActive': true,
      'stock': 8,
      'sold': 3,
      'rating': 4.8,
      'reviewsCount': 8,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // ماكينات منزلي
    {
      'id': 'prod_003',
      'name': 'ماكينة خياطة برذر CS6000i',
      'nameEn': 'Brother CS6000i',
      'description': 'ماكينة منزلية متعددة الوظائف مع 60 غرزة مختلفة',
      'category': 'ماكينات منزلي',
      'brand': 'Brother',
      'condition': 'جديد',
      'price': 4500.0,
      'discount': 20.0,
      'finalPrice': 3600.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample3.jpg',
      ],
      'specifications': {
        'عدد الغرز': '60 غرزة',
        'القدرة': '50 واط',
        'الوزن': '8 كجم',
        'الضمان': 'سنة',
      },
      'isActive': true,
      'stock': 15,
      'sold': 20,
      'rating': 4.3,
      'reviewsCount': 35,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'prod_004',
      'name': 'ماكينة خياطة سنجر 4423',
      'nameEn': 'Singer 4423',
      'description': 'ماكينة منزلية قوية للخياطة الثقيلة',
      'category': 'ماكينات منزلي',
      'brand': 'Singer',
      'condition': 'جديد',
      'price': 3800.0,
      'discount': 0.0,
      'finalPrice': 3800.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample4.jpg',
      ],
      'specifications': {
        'السرعة': '1100 غرزة/دقيقة',
        'عدد الغرز': '23 غرزة',
        'الوزن': '7.5 كجم',
        'الضمان': 'سنة',
      },
      'isActive': true,
      'stock': 12,
      'sold': 15,
      'rating': 4.6,
      'reviewsCount': 28,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // قطع غيار
    {
      'id': 'prod_005',
      'name': 'إبر خياطة صناعي - عبوة 100 حبة',
      'nameEn': 'Industrial Needles Pack',
      'description': 'إبر خياطة صناعية عالية الجودة مقاس 14',
      'category': 'قطع غيار',
      'brand': 'Generic',
      'condition': 'جديد',
      'price': 200.0,
      'discount': 0.0,
      'finalPrice': 200.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample5.jpg',
      ],
      'specifications': {'المقاس': '14', 'الكمية': '100 حبة'},
      'isActive': true,
      'stock': 50,
      'sold': 80,
      'rating': 4.4,
      'reviewsCount': 45,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'prod_006',
      'name': 'بكرة خيط - مجموعة ألوان',
      'nameEn': 'Thread Spools Set',
      'description': 'مجموعة بكر خيط متعددة الألوان - 50 لون',
      'category': 'قطع غيار',
      'brand': 'Generic',
      'condition': 'جديد',
      'price': 350.0,
      'discount': 10.0,
      'finalPrice': 315.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample6.jpg',
      ],
      'specifications': {'عدد الألوان': '50 لون', 'الطول': '1000 متر لكل بكرة'},
      'isActive': true,
      'stock': 30,
      'sold': 45,
      'rating': 4.7,
      'reviewsCount': 56,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // ماكينات تطريز
    {
      'id': 'prod_007',
      'name': 'ماكينة تطريز برذر PE800',
      'nameEn': 'Brother PE800 Embroidery',
      'description': 'ماكينة تطريز متقدمة مع شاشة لمس LCD',
      'category': 'ماكينات تطريز',
      'brand': 'Brother',
      'condition': 'جديد',
      'price': 12000.0,
      'discount': 5.0,
      'finalPrice': 11400.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample7.jpg',
      ],
      'specifications': {
        'مساحة التطريز': '5×7 بوصة',
        'عدد التصاميم': '138 تصميم مدمج',
        'الشاشة': '3.2 بوصة LCD',
        'الضمان': 'سنتان',
      },
      'isActive': true,
      'stock': 5,
      'sold': 2,
      'rating': 4.9,
      'reviewsCount': 15,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'prod_008',
      'name': 'ماكينة تطريز تويوتا ESP9400',
      'nameEn': 'Toyota ESP9400',
      'description': 'ماكينة تطريز احترافية مع تقنية USB',
      'category': 'ماكينات تطريز',
      'brand': 'Toyota',
      'condition': 'كسر زيرو',
      'price': 10000.0,
      'discount': 15.0,
      'finalPrice': 8500.0,
      'images': [
        'https://res.cloudinary.com/demo/image/upload/v1234/sample8.jpg',
      ],
      'specifications': {
        'مساحة التطريز': '4×4 بوصة',
        'السرعة': '800 غرزة/دقيقة',
        'الذاكرة': '1.5 MB',
        'الضمان': 'سنة',
      },
      'isActive': true,
      'stock': 3,
      'sold': 1,
      'rating': 4.6,
      'reviewsCount': 8,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  try {
    for (var product in products) {
      await firestore
          .collection('products')
          .doc(product['id'] as String)
          .set(product);
      debugPrint('  ✓ تمت إضافة: ${product['name']}');
    }
    debugPrint('✅ تمت إضافة ${products.length} منتج\n');
  } catch (e) {
    debugPrint('❌ خطأ في إضافة المنتجات: $e\n');
  }
}

Future<void> _seedBanners(FirebaseFirestore firestore) async {
  debugPrint('🎨 إضافة البانرات...');

  final banners = [
    {
      'id': 'banner_001',
      'title': 'عرض خاص - خصم 20%',
      'titleEn': 'Special Offer - 20% OFF',
      'description': 'خصم 20% على جميع ماكينات الخياطة المنزلية',
      'imageUrl':
          'https://res.cloudinary.com/demo/image/upload/v1234/banner1.jpg',
      'type': 'offer',
      'targetType': 'category',
      'targetId': 'ماكينات منزلي',
      'isActive': true,
      'order': 1,
      'startDate': Timestamp.now(),
      'endDate': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'banner_002',
      'title': 'وصل حديثاً',
      'titleEn': 'New Arrival',
      'description': 'ماكينات تطريز حديثة من برذر',
      'imageUrl':
          'https://res.cloudinary.com/demo/image/upload/v1234/banner2.jpg',
      'type': 'new_arrival',
      'targetType': 'category',
      'targetId': 'ماكينات تطريز',
      'isActive': true,
      'order': 2,
      'startDate': Timestamp.now(),
      'endDate': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 60)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'banner_003',
      'title': 'احصل على 5% كاش باك',
      'titleEn': 'Get 5% Cashback',
      'description': 'من كل عملية شراء',
      'imageUrl':
          'https://res.cloudinary.com/demo/image/upload/v1234/banner3.jpg',
      'type': 'info',
      'targetType': 'none',
      'targetId': '',
      'isActive': true,
      'order': 3,
      'startDate': Timestamp.now(),
      'endDate': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 365)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  try {
    for (var banner in banners) {
      await firestore
          .collection('banners')
          .doc(banner['id'] as String)
          .set(banner);
      debugPrint('  ✓ تمت إضافة: ${banner['title']}');
    }
    debugPrint('✅ تمت إضافة ${banners.length} بانر\n');
  } catch (e) {
    debugPrint('❌ خطأ في إضافة البانرات: $e\n');
  }
}
