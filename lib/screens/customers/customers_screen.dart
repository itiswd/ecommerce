import 'package:data_table_2/data_table_2.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/customer.dart';
import 'package:ecommerce_dashboard/providers/customers_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTier = 'الكل';
  String _sortBy = 'الأحدث';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CustomersProvider>(
        context,
        listen: false,
      ).loadCustomers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CustomersProvider>(
      builder: (context, customersProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(customersProvider, isDark),
              const SizedBox(height: 24),
              _buildStatsCards(customersProvider, isDark),
              const SizedBox(height: 24),
              _buildFiltersSection(isDark),
              const SizedBox(height: 24),
              _buildCustomersTable(customersProvider, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(CustomersProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العملاء',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'إدارة عملاء المتجر',
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
              icon: const Icon(Icons.file_download),
              label: const Text('تصدير'),
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

  Widget _buildStatsCards(CustomersProvider provider, bool isDark) {
    // 0.1 * 255 = 25 (0x19)
    const int alpha10 = 0x19;

    final stats = [
      {
        'title': 'إجمالي العملاء',
        'value': '${provider.totalCustomers}',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'العملاء النشطين',
        'value': '${provider.activeCustomers}',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'عملاء VIP',
        'value': '${provider.vipCustomers}',
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'title': 'متوسط قيمة العميل',
        'value':
            '${NumberFormat('#,##0').format(provider.averageCustomerValue)} ج',
        'icon': Icons.attach_money,
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
                  // استخدام withAlpha
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // استخدام withAlpha
            color: (isDark ? Colors.black : Colors.grey).withAlpha(alpha10),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // حل الـ overflow باستخدام LayoutBuilder
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // 1. حقل البحث
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن عميل...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),
              // 2. حقل تصنيف العميل
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedTier,
                    decoration: const InputDecoration(
                      labelText: 'تصنيف العميل',
                      isDense: true,
                    ),
                    items: ['الكل', 'VIP', 'Gold', 'Silver', 'Bronze']
                        .map(
                          (tier) => DropdownMenuItem(
                            value: tier,
                            child: Text(tier, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    isExpanded: true,
                    onChanged: (value) =>
                        setState(() => _selectedTier = value!),
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
                  items:
                      const [
                            'الأحدث',
                            'الأقدم',
                            'الأعلى إنفاقاً',
                            'الأكثر طلبات',
                          ]
                          .map(
                            (sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(
                                sort,
                                overflow: TextOverflow.ellipsis,
                              ),
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

  Widget _buildCustomersTable(CustomersProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    var filteredCustomers = provider.searchCustomers(_searchController.text);

    if (_selectedTier != 'الكل') {
      filteredCustomers = filteredCustomers
          .where((c) => c.customerTier == _selectedTier)
          .toList();
    }

    switch (_sortBy) {
      case 'الأقدم':
        filteredCustomers.sort((a, b) => a.joinDate.compareTo(b.joinDate));
        break;
      case 'الأعلى إنفاقاً':
        filteredCustomers.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        break;
      case 'الأكثر طلبات':
        filteredCustomers.sort(
          (a, b) => b.totalOrders.compareTo(a.totalOrders),
        );
        break;
      default:
        filteredCustomers.sort((a, b) => b.joinDate.compareTo(a.joinDate));
    }

    const int alpha10 = 0x19;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
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
                  'قائمة العملاء (${filteredCustomers.length})',
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
                    'العميل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'البريد',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الهاتف',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المدينة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الطلبات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الإنفاق',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'التصنيف',
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
              rows: filteredCustomers.map((customer) {
                final tierColor = _getTierColor(customer.customerTier);
                return DataRow(
                  cells: [
                    // Customer Cell
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: tierColor,
                            child: Text(
                              customer.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'منذ ${_getTimeSinceJoin(customer.joinDate)}',
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
                        ],
                      ),
                    ),
                    // Email Cell
                    DataCell(
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          customer.email,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Phone Cell
                    DataCell(Center(child: Text(customer.phone))),
                    // City Cell
                    DataCell(Center(child: Text(customer.city))),
                    // Total Orders Cell
                    DataCell(
                      Center(
                        child: Text(
                          '${customer.totalOrders}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Total Spent Cell
                    DataCell(
                      Center(
                        child: Text(
                          '${NumberFormat('#,##0').format(customer.totalSpent)} ج',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    // Customer Tier Cell
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // 0.1 * 255 = 25 (0x19)
                            color: tierColor.withAlpha(alpha10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTierIcon(customer.customerTier),
                                size: 14,
                                color: tierColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.customerTier,
                                style: TextStyle(
                                  color: tierColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Active Status Cell
                    DataCell(
                      Center(
                        child: Switch(
                          value: customer.isActive,
                          onChanged: (value) =>
                              provider.toggleCustomerStatus(customer.id),
                        ),
                      ),
                    ),
                    // Actions Cell
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            onPressed: () =>
                                _showCustomerDetails(context, customer, isDark),
                            tooltip: 'عرض',
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () =>
                                _confirmDelete(context, customer, provider),
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

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'VIP':
        return Colors.purple;
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      case 'Bronze':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier) {
      case 'VIP':
        return Icons.workspace_premium;
      case 'Gold':
        return Icons.star;
      case 'Silver':
        return Icons.star_half;
      case 'Bronze':
        return Icons.star_border;
      default:
        return Icons.person;
    }
  }

  String _getTimeSinceJoin(DateTime joinDate) {
    final difference = DateTime.now().difference(joinDate);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} شهر';
    } else {
      return '${difference.inDays} يوم';
    }
  }

  void _showCustomerDetails(
    BuildContext context,
    Customer customer,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: const Text('تفاصيل العميل'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('الاسم', customer.name, isDark),
              _detailRow('البريد', customer.email, isDark),
              _detailRow('الهاتف', customer.phone, isDark),
              _detailRow('العنوان', customer.address, isDark),
              _detailRow('المدينة', customer.city, isDark),
              _detailRow('التصنيف', customer.customerTier, isDark),
              _detailRow('عدد الطلبات', '${customer.totalOrders}', isDark),
              _detailRow(
                'إجمالي الإنفاق',
                '${NumberFormat('#,##0').format(customer.totalSpent)} ج',
                isDark,
              ),
              _detailRow(
                'متوسط الطلب',
                '${NumberFormat('#,##0').format(customer.averageOrderValue)} ج',
                isDark,
              ),
            ],
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

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Customer customer,
    CustomersProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العميل "${customer.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // فصل الـ Provider عن السياق قبل إغلاق الـ Dialog/العودة منه
              provider.deleteCustomer(customer.id);
              Navigator.pop(context);

              // التحقق من mounted قبل ScaffoldMessenger
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف العميل بنجاح')),
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
