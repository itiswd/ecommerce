class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final double shippingFee;
  final double totalCommission;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    this.shippingFee = 0,
    required this.totalCommission,
    this.status = OrderStatus.pending,
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    this.isPaid = false,
    required this.createdAt,
    this.deliveredAt,
  });

  double get grandTotal => totalAmount + shippingFee;

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      totalCommission: (map['totalCommission'] ?? 0).toDouble(),
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingFee': shippingFee,
      'totalCommission': totalCommission,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'isPaid': isPaid,
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double commission;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.commission,
  });

  double get subtotal => price * quantity;
  double get totalCommission => subtotal * commission;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      commission: (map['commission'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'commission': commission,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

enum PaymentMethod { cashOnDelivery, creditCard, mobileWallet, bankTransfer }

extension OrderStatusExtension on OrderStatus {
  String get arabicName {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.processing:
        return 'قيد المعالجة';
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
