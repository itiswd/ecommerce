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
    // 1. استخراج خصائص الثيم الأساسية لسهولة الاستخدام الديناميكي
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
            // TextStyles بدون لون محدد ترث لون النص الأساسي من الثيم
            Text('البائعون', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.xs),
            Text(
              'إدارة البائعين والعمولات',
              style: AppTextStyles.bodyMedium.copyWith(
                // استخدام لون النص الثانوي الديناميكي
                color: textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // الأزرار تستخدم ثيمات ElevatedButtonThemeData و OutlinedButtonThemeData
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.file_download),
              label: Text('تصدير'),
            ),
            SizedBox(width: AppSpacing.md),
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

  Widget _buildStatsCards(SellersProvider provider, ColorScheme colorScheme) {
    // ألوان الحالة (Status Colors) تبقى ثابتة من AppColors لأنها ذات دلالة محددة
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
              // استخدام لون سطح البطاقة الديناميكي
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
                    color: (stat['color'] as Color).withOpacity(0.1),
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
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              // حقول الإدخال تستخدم InputDecorationTheme من الثيم الرئيسي
              decoration: InputDecoration(
                hintText: 'ابحث عن بائع...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTier,
              // حقول الإدخال تستخدم InputDecorationTheme من الثيم الرئيسي
              decoration: InputDecoration(labelText: 'التصنيف'),
              items: ['الكل', 'Platinum', 'Gold', 'Silver', 'Bronze']
                  .map(
                    (tier) => DropdownMenuItem(value: tier, child: Text(tier)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedTier = value!),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              // حقول الإدخال تستخدم InputDecorationTheme من الثيم الرئيسي
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

  Widget _buildSellersTable(SellersProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
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

    return Container(
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
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
          // استخدام DividerThemeData من الثيم
          Divider(height: 1, color: theme.dividerColor),
          SizedBox(
            height: 600,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 20,
              minWidth: 1400,
              // لون رأس الجدول يتغير بناءً على وضع الثيم (فاتح/داكن)
              headingRowColor: WidgetStateProperty.all(
                theme.brightness == Brightness.light
                    ? AppColors.grey50
                    : AppColors.darkSurface,
              ),
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
                final tierColor = _getTierColor(seller.sellerTier);
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            // لون التصنيف ثابت للدلالة
                            backgroundColor: tierColor,
                            child: Text(
                              seller.name[0],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
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
                                      SizedBox(width: AppSpacing.xs),
                                      Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: AppColors.info,
                                      ),
                                    ],
                                  ],
                                ),
                                // TextStyles بدون لون محدد ترث لون النص الأساسي من الثيم
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(seller.totalRevenue)} ج',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success, // لون دلالي ثابت
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning, // لون دلالي ثابت
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          // لون الخلفية من لون التصنيف مع Opacity
                          color: tierColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seller.sellerTier,
                          style: TextStyle(
                            color: tierColor, // لون النص من لون التصنيف
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      // الـ Switch يستخدم SwitchThemeData من الثيم الرئيسي
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
                            color: AppColors.info, // لون دلالي ثابت
                          ),
                          if (!seller.isVerified)
                            IconButton(
                              icon: Icon(Icons.verified_user, size: 18),
                              onPressed: () =>
                                  provider.verifySeller(seller.id, true),
                              tooltip: 'توثيق',
                              color: AppColors.success, // لون دلالي ثابت
                            ),
                          IconButton(
                            icon: Icon(Icons.attach_money, size: 18),
                            onPressed: () => _showPayCommissionDialog(
                              context,
                              seller,
                              provider,
                            ),
                            tooltip: 'دفع عمولة',
                            color: AppColors.warning, // لون دلالي ثابت
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

  // تم الاحتفاظ بألوان التصنيفات الثابتة لأنها ألوان دلالية محددة (Platinum, Gold, Bronze)
  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Platinum':
        return Color(0xFF9333EA);
      case 'Gold':
        return AppColors.warning;
      case 'Silver':
        return AppColors.grey600;
      case 'Bronze':
        return Color(0xFFCD7F32);
      default:
        return AppColors.grey500;
    }
  }

  void _showSellerDetails(BuildContext context, Seller seller) {
    final textTheme = Theme.of(context).textTheme;
    // AlertDialog يستخدم DialogThemeData من الثيم
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // عنوان النص يستخدم titleTextStyle من DialogThemeData
        title: Text('تفاصيل البائع'),
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
          // TextButton يستخدم TextButtonThemeData من الثيم الرئيسي
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // تم تعديل الدالة لقبول TextTheme لجعل نصوصها ديناميكية
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
              // استخدام TextTheme لضبط اللون بناءً على الثيم
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // استخدام TextTheme لضبط اللون بناءً على الثيم
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

    // الحصول على ColorScheme لاستخدامه في SnackBar
    final colorScheme = Theme.of(context).colorScheme;

    // AlertDialog يستخدم DialogThemeData من الثيم
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('دفع عمولة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // النص سيعتمد على الثيم
            Text(
              'العمولة المعلقة: ${NumberFormat('#,##0').format(seller.pendingCommission)} ج',
            ),
            SizedBox(height: AppSpacing.md),
            // TextField يستخدم InputDecorationTheme من الثيم الرئيسي
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
          // TextButton يستخدم TextButtonThemeData من الثيم الرئيسي
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          // ElevatedButton يستخدم ElevatedButtonThemeData من الثيم الرئيسي
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                provider.payCommission(seller.id, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم دفع العمولة بنجاح'),
                    // استخدام لون النجاح الديناميكي (Secondary)
                    backgroundColor: colorScheme.secondary,
                  ),
                );
              }
            },
            child: Text('دفع'),
          ),
        ],
      ),
    );
  }
}
