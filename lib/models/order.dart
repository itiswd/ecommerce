// lib/models/order.dart
class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String city;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final double cashbackEarned; // الكاش باك المكتسب
  final double cashbackUsed; // الكاش باك المستخدم
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.city,
    required this.items,
    required this.subtotal,
    this.shippingFee = 0,
    required this.totalAmount,
    this.cashbackEarned = 0,
    this.cashbackUsed = 0,
    this.status = OrderStatus.pending,
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    this.isPaid = false,
    required this.createdAt,
    this.deliveredAt,
    this.notes,
  });

  // عدد المنتجات
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  // المجموع النهائي بعد الكاش باك
  double get grandTotal => subtotal + shippingFee - cashbackUsed;

  // تحويل من Firestore
  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      city: map['city'] ?? '',
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      cashbackEarned: (map['cashbackEarned'] ?? 0).toDouble(),
      cashbackUsed: (map['cashbackUsed'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      isPaid: map['isPaid'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      deliveredAt: map['deliveredAt']?.toDate(),
      notes: map['notes'],
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'city': city,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'cashbackEarned': cashbackEarned,
      'cashbackUsed': cashbackUsed,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'isPaid': isPaid,
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
      'notes': notes,
    };
  }
}

// عنصر في الطلب
class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final Map<String, String>? selectedOptions;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedOptions,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      selectedOptions: map['selectedOptions'] != null
          ? Map<String, String>.from(map['selectedOptions'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
    };
  }
}

// حالات الطلب
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

// طرق الدفع
enum PaymentMethod { cashOnDelivery, creditCard, mobileWallet, bankTransfer }

// ترجمة حالات الطلب
extension OrderStatusExtension on OrderStatus {
  String get arabicName {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.processing:
        return 'قيد التجهيز';
      case OrderStatus.shipped:
        return 'قيد الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.returned:
        return 'مرتجع';
    }
  }
}

// ترجمة طرق الدفع
extension PaymentMethodExtension on PaymentMethod {
  String get arabicName {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمان';
      case PaymentMethod.mobileWallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
    }
  }
}
