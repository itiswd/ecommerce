// lib/models/cashback.dart
class CashbackTransaction {
  final String id;
  final String customerId;
  final String customerName;
  final String? orderId;
  final double amount;
  final CashbackType type;
  final DateTime createdAt;
  final String? description;

  CashbackTransaction({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.orderId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.description,
  });

  // تحويل من Firestore
  factory CashbackTransaction.fromMap(Map<String, dynamic> map, String id) {
    return CashbackTransaction(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      orderId: map['orderId'],
      amount: (map['amount'] ?? 0).toDouble(),
      type: CashbackType.values.firstWhere(
        (e) => e.toString() == 'CashbackType.${map['type']}',
        orElse: () => CashbackType.earned,
      ),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      description: map['description'],
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'orderId': orderId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'createdAt': createdAt,
      'description': description,
    };
  }
}

// أنواع معاملات الكاش باك
enum CashbackType {
  earned, // مكتسب من طلب
  used, // مستخدم في طلب
  expired, // منتهي الصلاحية
  adjusted, // تعديل يدوي
}

// ترجمة أنواع الكاش باك
extension CashbackTypeExtension on CashbackType {
  String get arabicName {
    switch (this) {
      case CashbackType.earned:
        return 'مكتسب';
      case CashbackType.used:
        return 'مستخدم';
      case CashbackType.expired:
        return 'منتهي';
      case CashbackType.adjusted:
        return 'تعديل';
    }
  }
}

// إحصائيات الكاش باك
class CashbackStats {
  final double totalEarned;
  final double totalUsed;
  final double totalExpired;
  final double currentBalance;
  final int transactionCount;

  CashbackStats({
    required this.totalEarned,
    required this.totalUsed,
    required this.totalExpired,
    required this.currentBalance,
    required this.transactionCount,
  });
}
