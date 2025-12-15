import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/customer.dart';
import 'package:flutter/material.dart';

class CustomersProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'customers';

  // Statistics
  int get totalCustomers => _customers.length;
  int get activeCustomers => _customers.where((c) => c.isActive).length;
  int get vipCustomers =>
      _customers.where((c) => c.customerTier == 'VIP').length;

  double get averageCustomerValue {
    if (_customers.isEmpty) return 0;
    double total = _customers.fold(0.0, (sum, c) => sum + c.totalSpent);
    return total / _customers.length;
  }

  // Initialize
  CustomersProvider() {
    loadCustomers();
  }

  // Load customers from Firebase
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('joinDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        // إضافة بيانات تجريبية
        await _addSampleData();
        final newSnapshot = await _firestore
            .collection(_collection)
            .orderBy('joinDate', descending: true)
            .get();
        _customers = newSnapshot.docs
            .map((doc) => Customer.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        _customers = snapshot.docs
            .map((doc) => Customer.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading customers: $e');
      _loadLocalSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة بيانات تجريبية
  Future<void> _addSampleData() async {
    final sampleCustomers = [
      Customer(
        id: '1',
        name: 'أحمد محمد علي',
        email: 'ahmed@example.com',
        phone: '01012345678',
        address: 'شارع الحجاز، مصر الجديدة',
        city: 'القاهرة',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 365)),
        totalOrders: 45,
        totalSpent: 67500,
        isActive: true,
      ),
      Customer(
        id: '2',
        name: 'سارة أحمد حسن',
        email: 'sara@example.com',
        phone: '01098765432',
        address: 'شارع التحرير، الدقي',
        city: 'الجيزة',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 180)),
        totalOrders: 32,
        totalSpent: 54200,
        isActive: true,
      ),
      Customer(
        id: '3',
        name: 'محمود حسن علي',
        email: 'mahmoud@example.com',
        phone: '01155556666',
        address: 'شارع الجيش، سموحة',
        city: 'الإسكندرية',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 90)),
        totalOrders: 18,
        totalSpent: 28900,
        isActive: true,
      ),
      Customer(
        id: '4',
        name: 'فاطمة أحمد محمد',
        email: 'fatma@example.com',
        phone: '01044443333',
        address: 'شارع الجمهورية',
        city: 'المنصورة',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 60)),
        totalOrders: 12,
        totalSpent: 15600,
        isActive: true,
      ),
      Customer(
        id: '5',
        name: 'عمر خالد حسن',
        email: 'omar@example.com',
        phone: '01233332222',
        address: 'شارع الهرم',
        city: 'الجيزة',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 45)),
        totalOrders: 8,
        totalSpent: 9800,
        isActive: true,
      ),
      Customer(
        id: '6',
        name: 'منى محمد سعيد',
        email: 'mona@example.com',
        phone: '01122221111',
        address: 'شارع الثورة',
        city: 'طنطا',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 30)),
        totalOrders: 5,
        totalSpent: 6200,
        isActive: true,
      ),
      Customer(
        id: '7',
        name: 'ياسر علي محمود',
        email: 'yasser@example.com',
        phone: '01566665555',
        address: 'شارع سعد زغلول',
        city: 'الإسماعيلية',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 20)),
        totalOrders: 3,
        totalSpent: 3500,
        isActive: false,
      ),
      Customer(
        id: '8',
        name: 'نورهان أحمد',
        email: 'nourhan@example.com',
        phone: '01477778888',
        address: 'شارع الجلاء',
        city: 'الزقازيق',
        country: 'مصر',
        joinDate: DateTime.now().subtract(Duration(days: 15)),
        totalOrders: 2,
        totalSpent: 2100,
        isActive: true,
      ),
    ];

    for (var customer in sampleCustomers) {
      await _firestore
          .collection(_collection)
          .doc(customer.id)
          .set(customer.toMap());
    }
  }

  // بيانات محلية
  void _loadLocalSampleData() {
    _customers = [
      Customer(
        id: '1',
        name: 'أحمد محمد علي',
        email: 'ahmed@example.com',
        phone: '01012345678',
        address: 'شارع الحجاز، مصر الجديدة',
        city: 'القاهرة',
        joinDate: DateTime.now().subtract(Duration(days: 365)),
        totalOrders: 45,
        totalSpent: 67500,
        isActive: true,
      ),
      Customer(
        id: '2',
        name: 'سارة أحمد حسن',
        email: 'sara@example.com',
        phone: '01098765432',
        address: 'شارع التحرير، الدقي',
        city: 'الجيزة',
        joinDate: DateTime.now().subtract(Duration(days: 180)),
        totalOrders: 32,
        totalSpent: 54200,
        isActive: true,
      ),
    ];
  }

  // Add new customer
  Future<void> addCustomer(Customer customer) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(customer.id)
          .set(customer.toMap());
      _customers.insert(0, customer);
      notifyListeners();
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(customer.id)
          .update(customer.toMap());

      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }

  // Toggle customer active status
  Future<void> toggleCustomerStatus(String customerId) async {
    try {
      final index = _customers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        final customer = _customers[index];
        final newStatus = !customer.isActive;

        await _firestore.collection(_collection).doc(customerId).update({
          'isActive': newStatus,
        });

        _customers[index] = customer.copyWith(isActive: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling customer status: $e');
      rethrow;
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection(_collection).doc(customerId).delete();
      _customers.removeWhere((c) => c.id == customerId);
      notifyListeners();
    } catch (e) {
      print('Error deleting customer: $e');
      rethrow;
    }
  }

  // Get customer by ID
  Customer? getCustomerById(String customerId) {
    try {
      return _customers.firstWhere((c) => c.id == customerId);
    } catch (e) {
      return null;
    }
  }

  // Get customers by tier
  List<Customer> getCustomersByTier(String tier) {
    return _customers.where((c) => c.customerTier == tier).toList();
  }

  // Get top customers
  List<Customer> getTopCustomers({int limit = 10}) {
    final sorted = List<Customer>.from(_customers)
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    return sorted.take(limit).toList();
  }

  // Search customers
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;

    final lowerQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          customer.email.toLowerCase().contains(lowerQuery) ||
          customer.phone.contains(query) ||
          customer.city.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadCustomers();
  }

  // Export customers to CSV
  Future<void> exportCustomers() async {
    try {
      final csv = _customersToCSV();
      print('CSV Data: $csv');
      // يمكن حفظ الملف أو مشاركته
    } catch (e) {
      print('Error exporting customers: $e');
      rethrow;
    }
  }

  String _customersToCSV() {
    final headers = [
      'الرقم',
      'الاسم',
      'البريد',
      'الهاتف',
      'المدينة',
      'عدد الطلبات',
      'إجمالي الإنفاق',
      'التصنيف',
      'الحالة',
    ];

    final rows = _customers.map((c) {
      return [
        c.id,
        c.name,
        c.email,
        c.phone,
        c.city,
        c.totalOrders,
        c.totalSpent,
        c.customerTier,
        c.isActive ? 'نشط' : 'غير نشط',
      ].join(',');
    }).toList();

    return [headers.join(','), ...rows].join('\n');
  }
}
