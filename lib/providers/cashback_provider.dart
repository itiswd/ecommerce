// lib/providers/cashback_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_dashboard/models/cashback.dart';
import 'package:flutter/material.dart';

class CashbackProvider extends ChangeNotifier {
  List<CashbackTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<CashbackTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cashback_transactions';

  // Statistics
  CashbackStats get stats {
    double totalEarned = 0;
    double totalUsed = 0;
    double totalExpired = 0;

    for (var transaction in _transactions) {
      switch (transaction.type) {
        case CashbackType.earned:
        case CashbackType.adjusted:
          if (transaction.amount > 0) {
            totalEarned += transaction.amount;
          } else {
            totalUsed += transaction.amount.abs();
          }
          break;
        case CashbackType.used:
          totalUsed += transaction.amount;
          break;
        case CashbackType.expired:
          totalExpired += transaction.amount;
          break;
      }
    }

    return CashbackStats(
      totalEarned: totalEarned,
      totalUsed: totalUsed,
      totalExpired: totalExpired,
      currentBalance: totalEarned - totalUsed - totalExpired,
      transactionCount: _transactions.length,
    );
  }

  // Initialize
  CashbackProvider() {
    loadTransactions();
  }

  // Load transactions from Firebase
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        await _addSampleData();
        final newSnapshot = await _firestore
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .get();
        _transactions = newSnapshot.docs
            .map((doc) => CashbackTransaction.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        _transactions = snapshot.docs
            .map((doc) => CashbackTransaction.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading cashback transactions: $e');
      _loadLocalSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة بيانات تجريبية
  Future<void> _addSampleData() async {
    final sampleTransactions = [
      CashbackTransaction(
        id: '1',
        customerId: 'customer_1',
        customerName: 'أحمد محمد',
        orderId: '1',
        amount: 450.0,
        type: CashbackType.earned,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        description: 'كاش باك من طلب #1',
      ),
      CashbackTransaction(
        id: '2',
        customerId: 'customer_2',
        customerName: 'سارة علي',
        orderId: '2',
        amount: 635.0,
        type: CashbackType.earned,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        description: 'كاش باك من طلب #2',
      ),
      CashbackTransaction(
        id: '3',
        customerId: 'customer_1',
        customerName: 'أحمد محمد',
        orderId: '5',
        amount: 200.0,
        type: CashbackType.used,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        description: 'استخدام كاش باك في طلب #5',
      ),
      CashbackTransaction(
        id: '4',
        customerId: 'customer_3',
        customerName: 'محمود حسن',
        amount: 100.0,
        type: CashbackType.expired,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        description: 'انتهاء صلاحية الكاش باك',
      ),
    ];

    for (var transaction in sampleTransactions) {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .set(transaction.toMap());
    }
  }

  // بيانات محلية
  void _loadLocalSampleData() {
    _transactions = [
      CashbackTransaction(
        id: '1',
        customerId: 'customer_1',
        customerName: 'أحمد محمد',
        orderId: '1',
        amount: 450.0,
        type: CashbackType.earned,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        description: 'كاش باك من طلب #1',
      ),
    ];
  }

  // Add new transaction
  Future<void> addTransaction(CashbackTransaction transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .set(transaction.toMap());
      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).delete();
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get transactions by customer
  List<CashbackTransaction> getTransactionsByCustomer(String customerId) {
    return _transactions.where((t) => t.customerId == customerId).toList();
  }

  // Get transactions by type
  List<CashbackTransaction> getTransactionsByType(CashbackType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Search transactions
  List<CashbackTransaction> search(String query) {
    if (query.isEmpty) return _transactions;

    final lowerQuery = query.toLowerCase();
    return _transactions.where((transaction) {
      return transaction.customerName.toLowerCase().contains(lowerQuery) ||
          transaction.id.toLowerCase().contains(lowerQuery) ||
          (transaction.orderId?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadTransactions();
  }
}
