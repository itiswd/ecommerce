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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<SellersProvider>(
      builder: (context, sellersProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(sellersProvider, theme, textTheme),
              SizedBox(height: AppSpacing.lg),
              _buildStatsCards(sellersProvider, colorScheme),
              SizedBox(height: AppSpacing.lg),
              _buildFiltersSection(colorScheme),
              SizedBox(height: AppSpacing.lg),
              _buildSellersTable(sellersProvider, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    SellersProvider provider,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البائعون', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.xs),
            Text(
              'إدارة البائعين والعمولات',
              style: AppTextStyles.bodyMedium.copyWith(
                color: textTheme.bodyMedium?.color,
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
            SizedBox(width: AppSpacing.md),
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

  Widget _buildStatsCards(SellersProvider provider, ColorScheme colorScheme) {
    // 0.1 * 255 = 25 (0x19)
    const int alpha10 = 0x19;

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
            margin: EdgeInsets.only(left: AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppBorderRadius.medium,
              boxShadow: [AppShadows.medium],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    // استخدام withAlpha
                    color: (stat['color'] as Color).withAlpha(alpha10),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(stat['title'] as String, style: AppTextStyles.bodySmall),
                SizedBox(height: AppSpacing.xs),
                Text(stat['value'] as String, style: AppTextStyles.h3),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFiltersSection(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return
          // 1. حقل البحث
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن بائع...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),

              // 2. حقل التصنيف
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedTier,
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                      isDense: true,
                    ),
                    items: ['الكل', 'Platinum', 'Gold', 'Silver', 'Bronze']
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
                  items: ['الأحدث', 'الأقدم', 'الأعلى مبيعات', 'الأكثر منتجات']
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

  Widget _buildSellersTable(SellersProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    var filteredSellers = provider.searchSellers(_searchController.text);

    if (_selectedTier != 'الكل') {
      filteredSellers = filteredSellers
          .where((s) => s.sellerTier == _selectedTier)
          .toList();
    }

    // Sort logic (unchanged)
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

    // 0.15 * 255 ≈ 38 (0x26)
    const int alpha15 = 0x26;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
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
          Divider(height: 1, color: theme.dividerColor.withAlpha(128)),
          SizedBox(
            height: 600,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 20,
              minWidth: 1400,
              headingRowColor: WidgetStateProperty.all(
                theme.brightness == Brightness.light
                    ? AppColors.grey50
                    : AppColors.darkSurface,
              ),
              columns: [
                // Seller Name
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'البائع',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  size: ColumnSize.L,
                ),
                // Store Name
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المتجر',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Total Products
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المنتجات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Total Sales
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المبيعات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Total Revenue
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الإيرادات',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Pending Commission
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'العمولة المعلقة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Seller Tier
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'التصنيف',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Status
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الحالة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Actions
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
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
                final tierColor = _getTierColor(seller.sellerTier);
                return DataRow(
                  cells: [
                    // Seller Info
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: tierColor,
                            child: Text(
                              seller.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (seller.isVerified) ...[
                                      SizedBox(width: AppSpacing.xs),
                                      const Icon(
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
                    // Store Name
                    DataCell(
                      Center(
                        child: Text(
                          seller.storeName ?? 'غير محدد',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),
                    // Total Products
                    DataCell(
                      Center(
                        child: Text(
                          '${seller.totalProducts}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Total Sales
                    DataCell(
                      Center(
                        child: Text(
                          '${seller.totalSales}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Total Revenue
                    DataCell(
                      Center(
                        child: Text(
                          '${NumberFormat('#,##0').format(seller.totalRevenue)} ج',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    // Pending Commission
                    DataCell(
                      Center(
                        child: Text(
                          '${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ),
                    // Seller Tier
                    DataCell(
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            // استخدام withAlpha
                            color: tierColor.withAlpha(alpha15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            seller.sellerTier,
                            style: TextStyle(
                              color: tierColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Status
                    DataCell(
                      Center(
                        child: Switch(
                          value: seller.isActive,
                          onChanged: (value) {
                            provider.toggleSellerStatus(seller.id);
                          },
                        ),
                      ),
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            onPressed: () =>
                                _showSellerDetails(context, seller),
                            tooltip: 'عرض',
                            color: AppColors.info,
                          ),
                          if (!seller.isVerified)
                            IconButton(
                              icon: const Icon(Icons.verified_user, size: 18),
                              onPressed: () =>
                                  provider.verifySeller(seller.id, true),
                              tooltip: 'توثيق',
                              color: AppColors.success,
                            ),
                          IconButton(
                            icon: const Icon(Icons.attach_money, size: 18),
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

  // تم الاحتفاظ بألوان التصنيفات الثابتة لأنها ألوان دلالية محددة
  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Platinum':
        return const Color(0xFF9333EA);
      case 'Gold':
        return AppColors.warning;
      case 'Silver':
        return AppColors.grey600;
      case 'Bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.grey500;
    }
  }

  void _showSellerDetails(BuildContext context, Seller seller) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل البائع'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('الاسم', seller.name, textTheme),
                _detailRow('البريد', seller.email, textTheme),
                _detailRow('الهاتف', seller.phone, textTheme),
                _detailRow('المدينة', seller.city, textTheme),
                _detailRow('المتجر', seller.storeName ?? 'غير محدد', textTheme),
                _detailRow('التصنيف', seller.sellerTier, textTheme),
                _detailRow(
                  'عدد المنتجات',
                  '${seller.totalProducts}',
                  textTheme,
                ),
                _detailRow('عدد المبيعات', '${seller.totalSales}', textTheme),
                _detailRow(
                  'إجمالي الإيرادات',
                  '${NumberFormat('#,##0').format(seller.totalRevenue)} ج',
                  textTheme,
                ),
                _detailRow(
                  'العمولة المدفوعة',
                  '${NumberFormat('#,##0').format(seller.totalCommissionPaid)} ج',
                  textTheme,
                ),
                _detailRow(
                  'العمولة المعلقة',
                  '${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
                  textTheme,
                ),
                _detailRow('مستوى النشاط', seller.activityLevel, textTheme),
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

  Widget _detailRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
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

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دفع عمولة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'العمولة المعلقة: ${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ المراد دفعه',
                suffixText: 'جنيه',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                provider.payCommission(seller.id, amount);
                Navigator.pop(context);
                if (!mounted) return; // فحص mounted
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم دفع العمولة بنجاح'),
                    backgroundColor: colorScheme.secondary,
                  ),
                );
              }
            },
            child: const Text('دفع'),
          ),
        ],
      ),
    );
  }
}
