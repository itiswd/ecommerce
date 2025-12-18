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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ordersProvider, isDark),
              const SizedBox(height: 24),
              _buildStatsCards(ordersProvider, isDark),
              const SizedBox(height: 24),
              _buildFiltersSection(isDark),
              const SizedBox(height: 24),
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
            const SizedBox(height: 4),
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
              icon: const Icon(Icons.filter_alt),
              label: const Text('فلترة متقدمة'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(OrdersProvider provider, bool isDark) {
    // 0.1 * 255 = 25 (0x19)
    const int alpha10 = 0x19;

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
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // 0.1 * 255 = 25 (0x19)
                  color: (isDark ? Colors.black : Colors.grey).withAlpha(
                    alpha10,
                  ),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // استخدام withAlpha
                    color: (stat['color'] as Color).withAlpha(alpha10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  stat['title'] as String,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
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
    const int alpha10 = 0x19;

    return Container(
      padding: const EdgeInsets.all(16), // زيادة الـ padding قليلاً
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withAlpha(alpha10),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // 1. حقل البحث
              Expanded(
                // flex: 2 في التخطيط الواسع، و flex: 1 في الضيق لتأخذ العرض كاملاً
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن طلب...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),

              // 2. حقل حالة الطلب
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: DropdownButtonFormField<OrderStatus?>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'حالة الطلب',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...OrderStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.arabicName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    isExpanded: true,
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value),
                  ),
                ),
              ),

              // 3. حقل الترتيب
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'ترتيب حسب',
                    isDense: true,
                  ),
                  items: const ['الأحدث', 'الأقدم', 'الأعلى قيمة', 'الأقل قيمة']
                      .map(
                        (sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(sort, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  isExpanded: true,
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersTable(OrdersProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // منطق الفلترة والترتيب
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

    // 0.1 * 255 = 25 (0x19)
    const int alpha10 = 0x19;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // استخدام withAlpha
            color: (isDark ? Colors.black : Colors.grey).withAlpha(alpha10),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
              columns: const [
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'رقم الطلب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'العميل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المنتجات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المبلغ الإجمالي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'طريقة الدفع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
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
                    // Order ID
                    DataCell(Center(child: Text('#${order.id}'))),
                    // Customer Info
                    DataCell(
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                    ),
                    // Number of Items
                    DataCell(Center(child: Text('${order.items.length} منتج'))),
                    // Grand Total
                    DataCell(
                      Center(
                        child: Text(
                          '${NumberFormat('#,##0').format(order.grandTotal)} ج',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Payment Method
                    DataCell(
                      Center(
                        child: Text(
                          _getPaymentMethodArabic(order.paymentMethod),
                        ),
                      ),
                    ),
                    // Order Date
                    DataCell(
                      Center(
                        child: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                            'ar',
                          ).format(order.createdAt),
                        ),
                      ),
                    ),
                    // Order Status with PopupMenu
                    DataCell(
                      Center(
                        child: PopupMenuButton<OrderStatus>(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              // استخدام withAlpha
                              color: _getStatusColor(
                                order.status,
                              ).withAlpha(alpha10),
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
                          onSelected: (newStatus) {
                            // 1. استخراج الـ provider قبل الـ await/async gap
                            final providerInstance =
                                Provider.of<OrdersProvider>(
                                  context,
                                  listen: false,
                                );
                            // 2. التحقق من mounted قبل استخدام أي BuildContext (خاصة بعد تحديث الـ UI)
                            if (!mounted) return;

                            providerInstance.updateOrderStatus(
                              order.id,
                              newStatus,
                            );
                          },
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
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () =>
                                _showOrderDetails(context, order, isDark),
                            child: Icon(
                              Icons.visibility,
                              size: 18,
                              color: Colors.blue,
                            ),
                          ),

                          InkWell(
                            onTap: () => _confirmDelete(context, order),
                            child: Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('الهاتف: ${order.customerPhone}'),
                Text('العنوان: ${order.customerAddress}'),
                const Divider(),
                const Text(
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
                const Divider(),
                Text(
                  'المجموع: ${NumberFormat('#,##0').format(order.totalAmount)} ج',
                ),
                Text(
                  'الشحن: ${NumberFormat('#,##0').format(order.shippingFee)} ج',
                ),
                Text(
                  'الإجمالي: ${NumberFormat('#,##0').format(order.grandTotal)} ج',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الطلب #${order.id}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // فصل الـ Provider عن السياق قبل إغلاق الـ Dialog/العودة منه
              final provider = Provider.of<OrdersProvider>(
                context,
                listen: false,
              );

              Navigator.pop(context);
              provider.deleteOrder(order.id);

              // التحقق من mounted قبل ScaffoldMessenger
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الطلب بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
