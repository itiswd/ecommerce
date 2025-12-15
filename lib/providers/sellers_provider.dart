// lib/providers/sellers_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/seller.dart';
import 'package:flutter/material.dart';

class SellersProvider extends ChangeNotifier {
  List<Seller> _sellers = [];
  bool _isLoading = false;
  String? _error;

  List<Seller> get sellers => _sellers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sellers';

  // Statistics
  int get totalSellers => _sellers.length;
  int get activeSellers => _sellers.where((s) => s.isActive).length;
  int get verifiedSellers => _sellers.where((s) => s.isVerified).length;

  double get totalRevenue =>
      _sellers.fold(0.0, (sum, seller) => sum + seller.totalRevenue);

  double get totalCommissionPaid =>
      _sellers.fold(0.0, (sum, seller) => sum + seller.totalCommissionPaid);

  double get pendingCommissions =>
      _sellers.fold(0.0, (sum, seller) => sum + seller.pendingCommission);

  // Initialize
  SellersProvider() {
    loadSellers();
  }

  // Load sellers from Firebase
  Future<void> loadSellers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('joinDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        await _addSampleData();
        final newSnapshot = await _firestore
            .collection(_collection)
            .orderBy('joinDate', descending: true)
            .get();
        _sellers = newSnapshot.docs
            .map((doc) => Seller.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        _sellers = snapshot.docs
            .map((doc) => Seller.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading sellers: $e');
      _loadLocalSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة بيانات تجريبية
  Future<void> _addSampleData() async {
    final sampleSellers = [
      Seller(
        id: '1',
        name: 'محمد أحمد علي',
        email: 'mohamed@seller.com',
        phone: '01012345678',
        address: 'شارع الحجاز، مصر الجديدة',
        city: 'القاهرة',
        joinDate: DateTime.now().subtract(Duration(days: 730)),
        totalProducts: 45,
        totalSales: 320,
        totalRevenue: 156000,
        commissionRate: 0.10,
        totalCommissionPaid: 12000,
        isActive: true,
        isVerified: true,
        storeName: 'متجر الإلكترونيات الحديثة',
        storeDescription: 'أحدث الأجهزة الإلكترونية بأفضل الأسعار',
      ),
      Seller(
        id: '2',
        name: 'سارة حسن محمود',
        email: 'sara@seller.com',
        phone: '01098765432',
        address: 'شارع التحرير، الدقي',
        city: 'الجيزة',
        joinDate: DateTime.now().subtract(Duration(days: 540)),
        totalProducts: 32,
        totalSales: 245,
        totalRevenue: 98000,
        commissionRate: 0.12,
        totalCommissionPaid: 9000,
        isActive: true,
        isVerified: true,
        storeName: 'متجر الأزياء العصرية',
        storeDescription: 'أحدث صيحات الموضة',
      ),
      Seller(
        id: '3',
        name: 'أحمد خالد حسن',
        email: 'ahmed@seller.com',
        phone: '01155556666',
        address: 'شارع الجيش، سموحة',
        city: 'الإسكندرية',
        joinDate: DateTime.now().subtract(Duration(days: 365)),
        totalProducts: 28,
        totalSales: 180,
        totalRevenue: 72000,
        commissionRate: 0.10,
        totalCommissionPaid: 6000,
        isActive: true,
        isVerified: true,
        storeName: 'مكتبة المعرفة',
        storeDescription: 'كتب في جميع المجالات',
      ),
      Seller(
        id: '4',
        name: 'فاطمة علي محمد',
        email: 'fatma@seller.com',
        phone: '01044443333',
        address: 'شارع الجمهورية',
        city: 'المنصورة',
        joinDate: DateTime.now().subtract(Duration(days: 180)),
        totalProducts: 15,
        totalSales: 85,
        totalRevenue: 34000,
        commissionRate: 0.15,
        totalCommissionPaid: 3500,
        isActive: true,
        isVerified: false,
        storeName: 'متجر الأثاث المنزلي',
        storeDescription: 'أثاث عملي وأنيق',
      ),
      Seller(
        id: '5',
        name: 'عمر سعيد أحمد',
        email: 'omar@seller.com',
        phone: '01233332222',
        address: 'شارع الهرم',
        city: 'الجيزة',
        joinDate: DateTime.now().subtract(Duration(days: 90)),
        totalProducts: 8,
        totalSales: 42,
        totalRevenue: 18000,
        commissionRate: 0.10,
        totalCommissionPaid: 1200,
        isActive: true,
        isVerified: false,
        storeName: 'متجر الرياضة',
        storeDescription: 'معدات رياضية احترافية',
      ),
    ];

    for (var seller in sampleSellers) {
      await _firestore
          .collection(_collection)
          .doc(seller.id)
          .set(seller.toMap());
    }
  }

  // بيانات محلية
  void _loadLocalSampleData() {
    _sellers = [
      Seller(
        id: '1',
        name: 'محمد أحمد علي',
        email: 'mohamed@seller.com',
        phone: '01012345678',
        address: 'شارع الحجاز، مصر الجديدة',
        city: 'القاهرة',
        joinDate: DateTime.now().subtract(Duration(days: 730)),
        totalProducts: 45,
        totalSales: 320,
        totalRevenue: 156000,
        isActive: true,
        isVerified: true,
      ),
    ];
  }

  // Add new seller
  Future<void> addSeller(Seller seller) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(seller.id)
          .set(seller.toMap());
      _sellers.insert(0, seller);
      notifyListeners();
    } catch (e) {
      print('Error adding seller: $e');
      rethrow;
    }
  }

  // Update seller
  Future<void> updateSeller(Seller seller) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(seller.id)
          .update(seller.toMap());

      final index = _sellers.indexWhere((s) => s.id == seller.id);
      if (index != -1) {
        _sellers[index] = seller;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating seller: $e');
      rethrow;
    }
  }

  // Toggle seller status
  Future<void> toggleSellerStatus(String sellerId) async {
    try {
      final index = _sellers.indexWhere((s) => s.id == sellerId);
      if (index != -1) {
        final seller = _sellers[index];
        final newStatus = !seller.isActive;

        await _firestore.collection(_collection).doc(sellerId).update({
          'isActive': newStatus,
        });

        _sellers[index] = seller.copyWith(isActive: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling seller status: $e');
      rethrow;
    }
  }

  // Verify seller
  Future<void> verifySeller(String sellerId, bool verified) async {
    try {
      await _firestore.collection(_collection).doc(sellerId).update({
        'isVerified': verified,
      });

      final index = _sellers.indexWhere((s) => s.id == sellerId);
      if (index != -1) {
        _sellers[index] = _sellers[index].copyWith(isVerified: verified);
        notifyListeners();
      }
    } catch (e) {
      print('Error verifying seller: $e');
      rethrow;
    }
  }

  // Pay commission
  Future<void> payCommission(String sellerId, double amount) async {
    try {
      final index = _sellers.indexWhere((s) => s.id == sellerId);
      if (index != -1) {
        final seller = _sellers[index];
        final newTotal = seller.totalCommissionPaid + amount;

        await _firestore.collection(_collection).doc(sellerId).update({
          'totalCommissionPaid': newTotal,
        });

        _sellers[index] = seller.copyWith(totalCommissionPaid: newTotal);
        notifyListeners();
      }
    } catch (e) {
      print('Error paying commission: $e');
      rethrow;
    }
  }

  // Delete seller
  Future<void> deleteSeller(String sellerId) async {
    try {
      await _firestore.collection(_collection).doc(sellerId).delete();
      _sellers.removeWhere((s) => s.id == sellerId);
      notifyListeners();
    } catch (e) {
      print('Error deleting seller: $e');
      rethrow;
    }
  }

  // Get seller by ID
  Seller? getSellerById(String sellerId) {
    try {
      return _sellers.firstWhere((s) => s.id == sellerId);
    } catch (e) {
      return null;
    }
  }

  // Get top sellers
  List<Seller> getTopSellers({int limit = 10}) {
    final sorted = List<Seller>.from(_sellers)
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return sorted.take(limit).toList();
  }

  // Search sellers
  List<Seller> searchSellers(String query) {
    if (query.isEmpty) return _sellers;

    final lowerQuery = query.toLowerCase();
    return _sellers.where((seller) {
      return seller.name.toLowerCase().contains(lowerQuery) ||
          seller.email.toLowerCase().contains(lowerQuery) ||
          seller.phone.contains(query) ||
          (seller.storeName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadSellers();
  }
}
