import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/order.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedStatus;
  String _sortBy = 'الأحدث';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<OrdersProvider>(context, listen: false).loadOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ordersProvider, isDark),
              SizedBox(height: 24),
              _buildStatsCards(ordersProvider, isDark),
              SizedBox(height: 24),
              _buildFiltersSection(isDark),
              SizedBox(height: 24),
              _buildOrdersTable(ordersProvider, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(OrdersProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الطلبات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'إدارة طلبات العملاء',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.filter_alt),
              label: Text('فلترة متقدمة'),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: Icon(Icons.refresh),
              label: Text('تحديث'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(OrdersProvider provider, bool isDark) {
    final stats = [
      {
        'title': 'إجمالي الطلبات',
        'value': '${provider.totalOrders}',
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
      {
        'title': 'قيد الانتظار',
        'value': '${provider.pendingOrders}',
        'icon': Icons.pending,
        'color': Colors.orange,
      },
      {
        'title': 'تم التوصيل',
        'value': '${provider.deliveredOrders}',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'إجمالي الإيرادات',
        'value': '${NumberFormat('#,##0').format(provider.totalRevenue)} ج',
        'icon': Icons.monetization_on,
        'color': Colors.purple,
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  stat['title'] as String,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFiltersSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن طلب...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<OrderStatus?>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(labelText: 'حالة الطلب'),
              items: [
                DropdownMenuItem(value: null, child: Text('الكل')),
                ...OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.arabicName),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: InputDecoration(labelText: 'ترتيب حسب'),
              items: ['الأحدث', 'الأقدم', 'الأعلى قيمة', 'الأقل قيمة']
                  .map(
                    (sort) => DropdownMenuItem(value: sort, child: Text(sort)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _sortBy = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(OrdersProvider provider, bool isDark) {
    if (provider.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    var filteredOrders = provider.orders.where((order) {
      bool matchesSearch =
          _searchController.text.isEmpty ||
          order.customerName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          order.id.toLowerCase().contains(_searchController.text.toLowerCase());
      bool matchesStatus =
          _selectedStatus == null || order.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    switch (_sortBy) {
      case 'الأقدم':
        filteredOrders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'الأعلى قيمة':
        filteredOrders.sort((a, b) => b.grandTotal.compareTo(a.grandTotal));
        break;
      case 'الأقل قيمة':
        filteredOrders.sort((a, b) => a.grandTotal.compareTo(b.grandTotal));
        break;
      default:
        filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة الطلبات (${filteredOrders.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          SizedBox(
            height: 600,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 20,
              minWidth: 1200,
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkSurface : Colors.grey[50],
              ),
              dataRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkCard : Colors.white,
              ),
              columns: [
                DataColumn2(
                  label: Text(
                    'رقم الطلب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'العميل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'المنتجات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'المبلغ الإجمالي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'طريقة الدفع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الإجراءات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.S,
                ),
              ],
              rows: filteredOrders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text('#${order.id}')),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            order.customerPhone,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text('${order.items.length} منتج')),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(order.grandTotal)} ج',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(_getPaymentMethodArabic(order.paymentMethod)),
                    ),
                    DataCell(
                      Text(
                        DateFormat('dd/MM/yyyy', 'ar').format(order.createdAt),
                      ),
                    ),
                    DataCell(
                      PopupMenuButton<OrderStatus>(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                order.status.arabicName,
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: _getStatusColor(order.status),
                              ),
                            ],
                          ),
                        ),
                        onSelected: (newStatus) =>
                            provider.updateOrderStatus(order.id, newStatus),
                        itemBuilder: (context) => OrderStatus.values
                            .map(
                              (status) => PopupMenuItem(
                                value: status,
                                child: Text(status.arabicName),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, size: 18),
                            onPressed: () =>
                                _showOrderDetails(context, order, isDark),
                            tooltip: 'عرض',
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18),
                            onPressed: () => _confirmDelete(context, order),
                            tooltip: 'حذف',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodArabic(PaymentMethod method) {
    switch (method) {
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.indigo;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.brown;
    }
  }

  void _showOrderDetails(BuildContext context, Order order, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('تفاصيل الطلب #${order.id}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'العميل: ${order.customerName}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('الهاتف: ${order.customerPhone}'),
                Text('العنوان: ${order.customerAddress}'),
                Divider(),
                Text(
                  'المنتجات:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...order.items.map(
                  (item) => ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: item.productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.productName),
                    subtitle: Text('الكمية: ${item.quantity}'),
                    trailing: Text(
                      '${NumberFormat('#,##0').format(item.subtotal)} ج',
                    ),
                  ),
                ),
                Divider(),
                Text(
                  'المجموع: ${NumberFormat('#,##0').format(order.totalAmount)} ج',
                ),
                Text(
                  'الشحن: ${NumberFormat('#,##0').format(order.shippingFee)} ج',
                ),
                Text(
                  'الإجمالي: ${NumberFormat('#,##0').format(order.grandTotal)} ج',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الطلب #${order.id}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<OrdersProvider>(
                context,
                listen: false,
              ).deleteOrder(order.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم حذف الطلب بنجاح')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
