// lib/providers/banners_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/banner.dart';
import 'package:flutter/material.dart';

class BannersProvider extends ChangeNotifier {
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'banners';

  // Statistics
  int get totalBanners => _banners.length;
  int get activeBanners => _banners.where((b) => b.isActive).length;
  int get currentlyActiveBanners =>
      _banners.where((b) => b.isCurrentlyActive).length;

  // Initialize
  BannersProvider() {
    loadBanners();
  }

  // Load banners from Firebase
  Future<void> loadBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        await _addSampleData();
        final newSnapshot = await _firestore
            .collection(_collection)
            .orderBy('order')
            .get();
        _banners = newSnapshot.docs
            .map((doc) => BannerModel.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        _banners = snapshot.docs
            .map((doc) => BannerModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading banners: $e');
      _loadLocalSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة بيانات تجريبية
  Future<void> _addSampleData() async {
    final sampleBanners = [
      BannerModel(
        id: '1',
        title: 'عرض خاص على اللابتوبات',
        description: 'خصم يصل إلى 30% على جميع اللابتوبات',
        imageUrl:
            'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=1200',
        type: BannerType.category,
        targetId: 'electronics',
        order: 1,
        isActive: true,
        createdAt: DateTime.now(),
        startDate: DateTime.now().subtract(Duration(days: 5)),
        endDate: DateTime.now().add(Duration(days: 25)),
      ),
      BannerModel(
        id: '2',
        title: 'أحدث هواتف آيفون',
        description: 'iPhone 15 Pro Max متاح الآن',
        imageUrl:
            'https://images.unsplash.com/photo-1592286927505-93fd55ce0c0f?w=1200',
        type: BannerType.product,
        targetId: '2',
        order: 2,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      BannerModel(
        id: '3',
        title: 'شحن مجاني',
        description: 'شحن مجاني على جميع الطلبات فوق 500 جنيه',
        imageUrl:
            'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1200',
        type: BannerType.general,
        order: 3,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var banner in sampleBanners) {
      await _firestore
          .collection(_collection)
          .doc(banner.id)
          .set(banner.toMap());
    }
  }

  // بيانات محلية
  void _loadLocalSampleData() {
    _banners = [
      BannerModel(
        id: '1',
        title: 'عرض خاص على اللابتوبات',
        description: 'خصم يصل إلى 30%',
        imageUrl:
            'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=1200',
        type: BannerType.general,
        order: 1,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Add new banner
  Future<void> addBanner(BannerModel banner) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(banner.id)
          .set(banner.toMap());
      _banners.add(banner);
      _sortBanners();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding banner: $e');
      rethrow;
    }
  }

  // Update banner
  Future<void> updateBanner(BannerModel banner) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(banner.id)
          .update(banner.toMap());

      final index = _banners.indexWhere((b) => b.id == banner.id);
      if (index != -1) {
        _banners[index] = banner;
        _sortBanners();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating banner: $e');
      rethrow;
    }
  }

  // Delete banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection(_collection).doc(bannerId).delete();
      _banners.removeWhere((b) => b.id == bannerId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting banner: $e');
      rethrow;
    }
  }

  // Toggle banner status
  Future<void> toggleBannerStatus(String bannerId) async {
    try {
      final index = _banners.indexWhere((b) => b.id == bannerId);
      if (index != -1) {
        final banner = _banners[index];
        final newStatus = !banner.isActive;

        await _firestore.collection(_collection).doc(bannerId).update({
          'isActive': newStatus,
        });

        _banners[index] = banner.copyWith(isActive: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling banner status: $e');
      rethrow;
    }
  }

  // Update banner order
  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    try {
      await _firestore.collection(_collection).doc(bannerId).update({
        'order': newOrder,
      });

      final index = _banners.indexWhere((b) => b.id == bannerId);
      if (index != -1) {
        _banners[index] = _banners[index].copyWith(order: newOrder);
        _sortBanners();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating banner order: $e');
      rethrow;
    }
  }

  // Sort banners by order
  void _sortBanners() {
    _banners.sort((a, b) => a.order.compareTo(b.order));
  }

  // Get active banners
  List<BannerModel> getActiveBanners() {
    return _banners.where((b) => b.isCurrentlyActive).toList();
  }

  // Get banners by type
  List<BannerModel> getBannersByType(BannerType type) {
    return _banners.where((b) => b.type == type).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadBanners();
  }
}
