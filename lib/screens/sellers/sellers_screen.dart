// lib/screens/sellers/sellers_screen.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/seller.dart';
import 'package:ecommerce_dashboard/providers/sellers_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTier = 'الكل';
  String _sortBy = 'الأحدث';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SellersProvider>(context, listen: false).loadSellers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellersProvider>(
      builder: (context, sellersProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(sellersProvider),
              SizedBox(height: 24),
              _buildStatsCards(sellersProvider),
              SizedBox(height: 24),
              _buildFiltersSection(),
              SizedBox(height: 24),
              _buildSellersTable(sellersProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(SellersProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البائعون', style: AppTextStyles.h2),
            SizedBox(height: 4),
            Text(
              'إدارة البائعين والعمولات',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
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

  Widget _buildStatsCards(SellersProvider provider) {
    final stats = [
      {
        'title': 'إجمالي البائعين',
        'value': '${provider.totalSellers}',
        'icon': Icons.store,
        'color': AppColors.primary,
      },
      {
        'title': 'البائعون النشطون',
        'value': '${provider.activeSellers}',
        'icon': Icons.check_circle,
        'color': AppColors.success,
      },
      {
        'title': 'البائعون الموثقون',
        'value': '${provider.verifiedSellers}',
        'icon': Icons.verified,
        'color': AppColors.info,
      },
      {
        'title': 'العمولات المعلقة',
        'value':
            '${NumberFormat('#,##0').format(provider.pendingCommissions)} ج',
        'icon': Icons.attach_money,
        'color': AppColors.warning,
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.medium,
              boxShadow: [AppShadows.medium],
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
                Text(stat['title'] as String, style: AppTextStyles.bodySmall),
                SizedBox(height: 4),
                Text(stat['value'] as String, style: AppTextStyles.h3),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن بائع...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTier,
              decoration: InputDecoration(labelText: 'التصنيف'),
              items: ['الكل', 'Platinum', 'Gold', 'Silver', 'Bronze']
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
              items: ['الأحدث', 'الأقدم', 'الأعلى مبيعات', 'الأكثر منتجات']
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

  Widget _buildSellersTable(SellersProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    var filteredSellers = provider.searchSellers(_searchController.text);

    if (_selectedTier != 'الكل') {
      filteredSellers = filteredSellers
          .where((s) => s.sellerTier == _selectedTier)
          .toList();
    }

    // Sort
    switch (_sortBy) {
      case 'الأقدم':
        filteredSellers.sort((a, b) => a.joinDate.compareTo(b.joinDate));
        break;
      case 'الأعلى مبيعات':
        filteredSellers.sort(
          (a, b) => b.totalRevenue.compareTo(a.totalRevenue),
        );
        break;
      case 'الأكثر منتجات':
        filteredSellers.sort(
          (a, b) => b.totalProducts.compareTo(a.totalProducts),
        );
        break;
      default:
        filteredSellers.sort((a, b) => b.joinDate.compareTo(a.joinDate));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة البائعين (${filteredSellers.length})',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          Divider(height: 1),
          SizedBox(
            height: 600,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 20,
              minWidth: 1400,
              headingRowColor: WidgetStateProperty.all(AppColors.grey50),
              columns: [
                DataColumn2(
                  label: Text(
                    'البائع',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'المتجر',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'المنتجات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'المبيعات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الإيرادات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'العمولة المعلقة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'التصنيف',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الحالة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الإجراءات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
              ],
              rows: filteredSellers.map((seller) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _getTierColor(seller.sellerTier),
                            child: Text(
                              seller.name[0],
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
                                Row(
                                  children: [
                                    Text(
                                      seller.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (seller.isVerified) ...[
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: AppColors.info,
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  seller.email,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        seller.storeName ?? 'غير محدد',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    DataCell(
                      Text(
                        '${seller.totalProducts}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${seller.totalSales}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(seller.totalRevenue)} ج',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
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
                            seller.sellerTier,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seller.sellerTier,
                          style: TextStyle(
                            color: _getTierColor(seller.sellerTier),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: seller.isActive,
                        onChanged: (value) {
                          provider.toggleSellerStatus(seller.id);
                        },
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, size: 18),
                            onPressed: () =>
                                _showSellerDetails(context, seller),
                            tooltip: 'عرض',
                            color: AppColors.info,
                          ),
                          if (!seller.isVerified)
                            IconButton(
                              icon: Icon(Icons.verified_user, size: 18),
                              onPressed: () =>
                                  provider.verifySeller(seller.id, true),
                              tooltip: 'توثيق',
                              color: AppColors.success,
                            ),
                          IconButton(
                            icon: Icon(Icons.attach_money, size: 18),
                            onPressed: () => _showPayCommissionDialog(
                              context,
                              seller,
                              provider,
                            ),
                            tooltip: 'دفع عمولة',
                            color: AppColors.warning,
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
      case 'Platinum':
        return Color(0xFF9333EA);
      case 'Gold':
        return AppColors.warning;
      case 'Silver':
        return AppColors.grey500;
      case 'Bronze':
        return Color(0xFFCD7F32);
      default:
        return AppColors.grey500;
    }
  }

  void _showSellerDetails(BuildContext context, Seller seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل البائع'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('الاسم', seller.name),
                _detailRow('البريد', seller.email),
                _detailRow('الهاتف', seller.phone),
                _detailRow('المدينة', seller.city),
                _detailRow('المتجر', seller.storeName ?? 'غير محدد'),
                _detailRow('التصنيف', seller.sellerTier),
                _detailRow('عدد المنتجات', '${seller.totalProducts}'),
                _detailRow('عدد المبيعات', '${seller.totalSales}'),
                _detailRow(
                  'إجمالي الإيرادات',
                  '${NumberFormat('#,##0').format(seller.totalRevenue)} ج',
                ),
                _detailRow(
                  'العمولة المدفوعة',
                  '${NumberFormat('#,##0').format(seller.totalCommissionPaid)} ج',
                ),
                _detailRow(
                  'العمولة المعلقة',
                  '${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
                ),
                _detailRow('مستوى النشاط', seller.activityLevel),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  void _showPayCommissionDialog(
    BuildContext context,
    Seller seller,
    SellersProvider provider,
  ) {
    final amountController = TextEditingController(
      text: seller.pendingCommission.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('دفع عمولة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'العمولة المعلقة: ${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ المراد دفعه',
                suffixText: 'جنيه',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                provider.payCommission(seller.id, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('تم دفع العمولة بنجاح')));
              }
            },
            child: Text('دفع'),
          ),
        ],
      ),
    );
  }
}
