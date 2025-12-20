import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:ecommerce_dashboard/models/order.dart';
import 'package:flutter/material.dart';

class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Statistics
  int get totalOrders => _orders.length;
  int get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).length;
  int get confirmedOrders =>
      _orders.where((o) => o.status == OrderStatus.confirmed).length;
  int get shippedOrders =>
      _orders.where((o) => o.status == OrderStatus.shipped).length;
  int get deliveredOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  double get totalRevenue => _orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (summ, order) => summ + order.grandTotal);

  double get totalCommission => _orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (summ, order) => summ + order.totalCommission);
  // Initialize
  OrdersProvider() {
    loadOrders();
  }

  // Load orders from Firebase
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        // إضافة بيانات تجريبية
        await _addSampleData();
        final newSnapshot = await _firestore
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .get();
        _orders = newSnapshot.docs
            .map((doc) => Order.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        _orders = snapshot.docs
            .map((doc) => Order.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading orders: $e');
      _loadLocalSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة بيانات تجريبية
  Future<void> _addSampleData() async {
    final sampleOrders = [
      Order(
        id: '1',
        customerId: 'customer_1',
        customerName: 'أحمد محمد',
        customerPhone: '01012345678',
        customerAddress: 'القاهرة، مصر الجديدة، شارع الحجاز',
        city: 'القاهرة',
        items: [
          OrderItem(
            productId: '1',
            productName: 'لابتوب Dell XPS 15',
            productImage:
                'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400',
            price: 45000,
            quantity: 1,
            commission: 0.10,
          ),
        ],
        subtotal: 45000,
        shippingFee: 50,
        totalAmount: 45050,
        cashbackEarned: 450,
        cashbackUsed: 0,
        status: OrderStatus.delivered,
        paymentMethod: PaymentMethod.cashOnDelivery,
        isPaid: true,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        deliveredAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Order(
        id: '2',
        customerId: 'customer_2',
        customerName: 'سارة علي',
        customerPhone: '01098765432',
        customerAddress: 'الجيزة، الدقي، شارع التحرير',
        city: 'الجيزة',
        items: [
          OrderItem(
            productId: '2',
            productName: 'iPhone 15 Pro Max',
            productImage:
                'https://images.unsplash.com/photo-1592286927505-93fd55ce0c0f?w=400',
            price: 55000,
            quantity: 1,
            commission: 0.12,
          ),
          OrderItem(
            productId: '3',
            productName: 'سماعات Sony WH-1000XM5',
            productImage:
                'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400',
            price: 8500,
            quantity: 1,
            commission: 0.15,
          ),
        ],
        subtotal: 63500,
        shippingFee: 50,
        totalAmount: 63550,
        cashbackEarned: 635,
        cashbackUsed: 0,
        status: OrderStatus.shipped,
        paymentMethod: PaymentMethod.creditCard,
        isPaid: true,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      Order(
        id: '3',
        customerId: 'customer_3',
        customerName: 'محمود حسن',
        customerPhone: '01155556666',
        customerAddress: 'الإسكندرية، سموحة، شارع الجيش',
        city: 'الإسكندرية',
        items: [
          OrderItem(
            productId: '4',
            productName: 'كتاب البرمجة بلغة Dart',
            productImage:
                'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400',
            price: 250,
            quantity: 2,
            commission: 0.20,
          ),
        ],
        subtotal: 500,
        shippingFee: 30,
        totalAmount: 530,
        cashbackEarned: 5,
        cashbackUsed: 0,
        status: OrderStatus.confirmed,
        paymentMethod: PaymentMethod.mobileWallet,
        isPaid: true,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Order(
        id: '4',
        customerId: 'customer_4',
        customerName: 'فاطمة أحمد',
        customerPhone: '01044443333',
        customerAddress: 'المنصورة، شارع الجمهورية',
        city: 'المنصورة',
        items: [
          OrderItem(
            productId: '5',
            productName: 'كرسي مكتب ergonomic',
            productImage:
                'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400',
            price: 3500,
            quantity: 1,
            commission: 0.10,
          ),
        ],
        subtotal: 3500,
        shippingFee: 80,
        totalAmount: 3580,
        cashbackEarned: 35,
        cashbackUsed: 0,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.cashOnDelivery,
        isPaid: false,
        createdAt: DateTime.now(),
      ),
      Order(
        id: '5',
        customerId: 'customer_1',
        customerName: 'أحمد محمد',
        customerPhone: '01012345678',
        customerAddress: 'القاهرة، مصر الجديدة، شارع الحجاز',
        city: 'القاهرة',
        items: [
          OrderItem(
            productId: '3',
            productName: 'سماعات Sony WH-1000XM5',
            productImage:
                'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400',
            price: 8500,
            quantity: 1,
            commission: 0.15,
          ),
        ],
        subtotal: 8500,
        shippingFee: 50,
        totalAmount: 8350,
        cashbackEarned: 85,
        cashbackUsed: 200,
        status: OrderStatus.processing,
        paymentMethod: PaymentMethod.cashOnDelivery,
        isPaid: false,
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
      ),
    ];

    for (var order in sampleOrders) {
      await _firestore.collection(_collection).doc(order.id).set(order.toMap());
    }
  }

  // بيانات محلية
  void _loadLocalSampleData() {
    _orders = [
      Order(
        id: '1',
        customerId: 'customer_1',
        customerName: 'أحمد محمد',
        customerPhone: '01012345678',
        customerAddress: 'القاهرة، مصر الجديدة',
        city: 'القاهرة',
        items: [
          OrderItem(
            productId: '1',
            productName: 'لابتوب Dell XPS 15',
            productImage: '',
            price: 45000,
            quantity: 1,
            commission: 0.10,
          ),
        ],
        subtotal: 45000,
        shippingFee: 50,
        totalAmount: 45050,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];
  }

  // Add new order
  Future<void> addOrder(Order order) async {
    try {
      await _firestore.collection(_collection).doc(order.id).set(order.toMap());
      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding order: $e');
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updateData = {'status': newStatus.toString().split('.').last};

      // إذا كانت الحالة "تم التوصيل"، نضيف تاريخ التوصيل
      if (newStatus == OrderStatus.delivered) {
        updateData['deliveredAt'] = DateTime.now() as String;
      }

      await _firestore.collection(_collection).doc(orderId).update(updateData);

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final oldOrder = _orders[index];
        _orders[index] = Order(
          id: oldOrder.id,
          customerId: oldOrder.customerId,
          customerName: oldOrder.customerName,
          customerPhone: oldOrder.customerPhone,
          customerAddress: oldOrder.customerAddress,
          city: oldOrder.city,
          items: oldOrder.items,
          subtotal: oldOrder.subtotal,
          shippingFee: oldOrder.shippingFee,
          totalAmount: oldOrder.totalAmount,
          cashbackEarned: oldOrder.cashbackEarned,
          cashbackUsed: oldOrder.cashbackUsed,
          status: newStatus,
          paymentMethod: oldOrder.paymentMethod,
          isPaid: oldOrder.isPaid,
          createdAt: oldOrder.createdAt,
          deliveredAt: newStatus == OrderStatus.delivered
              ? DateTime.now()
              : oldOrder.deliveredAt,
          notes: oldOrder.notes,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).delete();
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting order: $e');
      rethrow;
    }
  }

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // Get orders by customer
  List<Order> getOrdersByCustomer(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  // Get orders by city
  List<Order> getOrdersByCity(String city) {
    return _orders.where((o) => o.city == city).toList();
  }

  // Search orders
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.customerName.toLowerCase().contains(lowerQuery) ||
          order.customerPhone.contains(query) ||
          order.id.toLowerCase().contains(lowerQuery) ||
          order.city.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get today's orders
  List<Order> getTodayOrders() {
    final today = DateTime.now();
    return _orders.where((order) {
      return order.createdAt.year == today.year &&
          order.createdAt.month == today.month &&
          order.createdAt.day == today.day;
    }).toList();
  }

  // Get this week's orders
  List<Order> getWeekOrders() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return _orders.where((order) {
      return order.createdAt.isAfter(weekAgo);
    }).toList();
  }

  // Get this month's orders
  List<Order> getMonthOrders() {
    final now = DateTime.now();
    return _orders.where((order) {
      return order.createdAt.year == now.year &&
          order.createdAt.month == now.month;
    }).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadOrders();
  }
}
