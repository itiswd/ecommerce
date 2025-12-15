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
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(customersProvider, isDark),
              SizedBox(height: 24),
              _buildStatsCards(customersProvider, isDark),
              SizedBox(height: 24),
              _buildFiltersSection(isDark),
              SizedBox(height: 24),
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
            SizedBox(height: 4),
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
              icon: Icon(Icons.file_download),
              label: Text('تصدير'),
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

  Widget _buildStatsCards(CustomersProvider provider, bool isDark) {
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
                hintText: 'ابحث عن عميل...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTier,
              decoration: InputDecoration(labelText: 'تصنيف العميل'),
              items: ['الكل', 'VIP', 'Gold', 'Silver', 'Bronze']
                  .map(
                    (tier) => DropdownMenuItem(value: tier, child: Text(tier)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedTier = value!),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: InputDecoration(labelText: 'ترتيب حسب'),
              items: ['الأحدث', 'الأقدم', 'الأعلى إنفاقاً', 'الأكثر طلبات']
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

  Widget _buildCustomersTable(CustomersProvider provider, bool isDark) {
    if (provider.isLoading) {
      return Center(
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
              columns: [
                DataColumn2(
                  label: Text(
                    'العميل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'البريد',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الهاتف',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'المدينة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الطلبات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الإنفاق',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'التصنيف',
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
              rows: filteredCustomers.map((customer) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _getTierColor(
                              customer.customerTier,
                            ),
                            child: Text(
                              customer.name[0],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  customer.name,
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                    DataCell(
                      Text(customer.email, style: TextStyle(fontSize: 13)),
                    ),
                    DataCell(Text(customer.phone)),
                    DataCell(Text(customer.city)),
                    DataCell(
                      Text(
                        '${customer.totalOrders}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(customer.totalSpent)} ج',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTierColor(
                            customer.customerTier,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTierIcon(customer.customerTier),
                              size: 14,
                              color: _getTierColor(customer.customerTier),
                            ),
                            SizedBox(width: 4),
                            Text(
                              customer.customerTier,
                              style: TextStyle(
                                color: _getTierColor(customer.customerTier),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: customer.isActive,
                        onChanged: (value) =>
                            provider.toggleCustomerStatus(customer.id),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, size: 18),
                            onPressed: () =>
                                _showCustomerDetails(context, customer, isDark),
                            tooltip: 'عرض',
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18),
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
        title: Text('تفاصيل العميل'),
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
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
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
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العميل "${customer.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCustomer(customer.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم حذف العميل بنجاح')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
