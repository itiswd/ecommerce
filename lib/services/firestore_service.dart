// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== Generic Methods =====

  // إضافة مستند
  Future<String?> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final doc = await _firestore.collection(collection).add(data);
      debugPrint('✅ تم إضافة مستند في $collection: ${doc.id}');
      return doc.id;
    } catch (e) {
      debugPrint('❌ خطأ في إضافة مستند في $collection: $e');
      return null;
    }
  }

  // تحديث مستند
  Future<bool> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      debugPrint('✅ تم تحديث مستند في $collection: $docId');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تحديث مستند في $collection: $e');
      return false;
    }
  }

  // حذف مستند
  Future<bool> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      debugPrint('✅ تم حذف مستند من $collection: $docId');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف مستند من $collection: $e');
      return false;
    }
  }

  // الحصول على مستند
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ في جلب مستند من $collection: $e');
      return null;
    }
  }

  // الحصول على مستندات مع استعلام
  Future<List<QueryDocumentSnapshot>> getDocuments(
    String collection, {
    Query Function(Query)? queryBuilder,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب مستندات من $collection: $e');
      return [];
    }
  }

  // Stream للمستندات
  Stream<QuerySnapshot> streamDocuments(
    String collection, {
    Query Function(Query)? queryBuilder,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  // ===== Specific Methods for Customer App =====

  // الحصول على المنتجات مع Pagination
  Future<List<QueryDocumentSnapshot>> getProducts({
    String? category,
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب المنتجات: $e');
      return [];
    }
  }

  // البحث عن المنتجات
  Future<List<QueryDocumentSnapshot>> searchProducts(String searchTerm) async {
    try {
      // Firestore لا يدعم البحث النصي الكامل بشكل افتراضي
      // نستخدم حل بديل: البحث يبدأ بـ searchTerm
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .startAt([searchTerm])
          .endAt(['$searchTerm\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في البحث عن المنتجات: $e');
      return [];
    }
  }

  // الحصول على البانرات النشطة
  Future<List<QueryDocumentSnapshot>> getActiveBanners() async {
    try {
      final snapshot = await _firestore
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب البانرات: $e');
      return [];
    }
  }

  // الحصول على طلبات المستخدم
  Future<List<QueryDocumentSnapshot>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب الطلبات: $e');
      return [];
    }
  }

  // الحصول على معاملات الكاش باك للمستخدم
  Future<List<QueryDocumentSnapshot>> getUserCashbackTransactions(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('cashback_transactions')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب معاملات الكاش باك: $e');
      return [];
    }
  }

  // الحصول على عناوين المستخدم
  Future<List<QueryDocumentSnapshot>> getUserAddresses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_addresses')
          .where('userId', isEqualTo: userId)
          .orderBy('isDefault', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب العناوين: $e');
      return [];
    }
  }

  // الحصول على المقارنات المحفوظة للمستخدم
  Future<List<QueryDocumentSnapshot>> getUserComparisons(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comparisons')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ خطأ في جلب المقارنات: $e');
      return [];
    }
  }

  // تحديث رصيد الكاش باك
  Future<bool> updateCashbackBalance(
    String userId,
    double newBalance,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'cashbackBalance': newBalance,
      });
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تحديث رصيد الكاش باك: $e');
      return false;
    }
  }

  // إنشاء طلب جديد
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final orderId = await addDocument('orders', orderData);

      if (orderId != null) {
        // تحديث عدد المبيعات لكل منتج
        final items = orderData['items'] as List;
        for (final item in items) {
          final productId = item['productId'];
          final quantity = item['quantity'];

          await _firestore.collection('products').doc(productId).update({
            'soldCount': FieldValue.increment(quantity),
            'stock': FieldValue.increment(-quantity),
          });
        }
      }

      return orderId;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الطلب: $e');
      return null;
    }
  }
}
