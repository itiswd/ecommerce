import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadDashboardData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. استخراج خصائص الثيم الأساسية
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, child) {
        if (dashProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dashProvider, textTheme),
              SizedBox(height: AppSpacing.lg),
              _buildStatsCards(dashProvider, colorScheme, textTheme),
              SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSalesChart(dashProvider, theme),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildCategoryPieChart(dashProvider, colorScheme),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentOrders(dashProvider, theme)),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildTopProducts(dashProvider, theme)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DashboardProvider provider, TextTheme textTheme) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // استخدام AppTextStyles لضمان التناسق
            Text('لوحة التحكم', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.xs),
            Text(
              'مرحباً بك، إليك نظرة عامة على متجرك',
              style: AppTextStyles.bodyMedium.copyWith(
                // استخدام لون النص الثانوي الديناميكي
                color: textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildFilterChip('اليوم', true, theme),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip('هذا الأسبوع', false, theme),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip('هذا الشهر', false, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, ThemeData theme) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement actual filtering logic
      },
      // لون الاختيار من الـ Primary الديناميكي
      selectedColor: theme.colorScheme.primary,
      // خلفية الشريحة غير المختارة ديناميكية
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.grey100,
      labelStyle: TextStyle(
        // لون النص ديناميكي
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
      ),
    );
  }

  Widget _buildStatsCards(
    DashboardProvider provider,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // ألوان الحالات تبقى ثابتة للدلالة البصرية
    final stats = [
      {
        'title': 'إجمالي المبيعات',
        'value': '${NumberFormat('#,##0').format(provider.totalSales)} جنيه',
        'change': '+12.5%',
        'isPositive': true,
        'icon': Icons.attach_money,
        'color': AppColors.primary,
      },
      {
        'title': 'الطلبات',
        'value': '${provider.totalOrders}',
        'change': '+8.2%',
        'isPositive': true,
        'icon': Icons.shopping_cart,
        'color': AppColors.success,
      },
      {
        'title': 'العملاء',
        'value': '${provider.totalCustomers}',
        'change': '+15.3%',
        'isPositive': true,
        'icon': Icons.people,
        'color': AppColors.info,
      },
      {
        'title': 'العمولة المكتسبة',
        'value':
            '${NumberFormat('#,##0').format(provider.totalCommission)} جنيه',
        'change': '+20.1%',
        'isPositive': true,
        'icon': Icons.trending_up,
        'color': AppColors.warning,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          change: stat['change'] as String,
          isPositive: stat['isPositive'] as bool,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  // ألوان دلالية ثابتة مع شفافية
                  color: isPositive
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  // استخدام لون النص الثانوي الديناميكي
                  color: textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              // استخدام AppTextStyles.h3 لضمان حجم ووزن الخط المناسب
              Text(value, style: AppTextStyles.h3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(DashboardProvider provider, ThemeData theme) {
    // تحديد الألوان الديناميكية للـ Chart
    final chartGridColor = theme.dividerColor;
    final chartLabelColor = theme.textTheme.bodySmall?.color;
    final chartTitleColor = theme.textTheme.titleMedium?.color;
    final chartBackgroundColor = theme.colorScheme.surface;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: chartBackgroundColor,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبيعات الأسبوعية',
            style: AppTextStyles.h4.copyWith(color: chartTitleColor),
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    // لون خطوط الشبكة ديناميكي
                    return FlLine(color: chartGridColor, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'السبت',
                          'الأحد',
                          'الاثنين',
                          'الثلاثاء',
                          'الأربعاء',
                          'الخميس',
                          'الجمعة',
                        ];
                        return Text(
                          days[value.toInt() % days.length],
                          // لون نص المحاور ديناميكي
                          style: AppTextStyles.caption.copyWith(
                            color: chartLabelColor,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}k',
                          // لون نص المحاور ديناميكي
                          style: AppTextStyles.caption.copyWith(
                            color: chartLabelColor,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: provider.salesData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    // استخدام لون Primary ثابت للرسوم البيانية
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(
    DashboardProvider provider,
    ColorScheme colorScheme,
  ) {
    final chartTitleColor = Theme.of(context).textTheme.titleMedium?.color;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات حسب الفئة',
            style: AppTextStyles.h4.copyWith(color: chartTitleColor),
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: provider.categoryData.entries.map((entry) {
                  // استخدام الألوان الدلالية من AppColors
                  final colors = [
                    AppColors.primary,
                    AppColors.success,
                    AppColors.warning,
                    AppColors.info,
                    AppColors.error,
                  ];
                  final index = provider.categoryData.keys.toList().indexOf(
                    entry.key,
                  );
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.value}%',
                    color: colors[index % colors.length],
                    radius: 100,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(DashboardProvider provider, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final chartTitleColor = textTheme.titleMedium?.color;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أحدث الطلبات',
                style: AppTextStyles.h4.copyWith(color: chartTitleColor),
              ),
              // TextButton يستخدم TextButtonThemeData
              TextButton(onPressed: () {}, child: Text('عرض الكل')),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...provider.recentOrders.map(
            (order) => _buildOrderItem(order, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // لون خلفية العنصر ديناميكي: رمادي فاتح في الفاتح، وسطح داكن في الداكن
    final itemBackgroundColor = theme.brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.grey50;
    final statusColor = _getStatusColor(order['status']);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: itemBackgroundColor,
        borderRadius: AppBorderRadius.medium,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Text(
              order['customer'][0],
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customer'],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order['product'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order['amount'],
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: AppSpacing.xs),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // استخدام AppColors بدلاً من Colors.green/orange/blue/grey
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return AppColors.success;
      case 'قيد المعالجة':
        return AppColors.warning;
      case 'قيد الشحن':
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }

  Widget _buildTopProducts(DashboardProvider provider, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final chartTitleColor = theme.textTheme.titleMedium?.color;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأكثر مبيعاً',
            style: AppTextStyles.h4.copyWith(color: chartTitleColor),
          ),
          SizedBox(height: AppSpacing.md),
          ...provider.topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return _buildTopProductItem(index + 1, product, theme);
          }),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(
    int rank,
    Map<String, dynamic> product,
    ThemeData theme,
  ) {
    final textTheme = theme.textTheme;
    // لون خلفية العنصر ديناميكي: رمادي فاتح في الفاتح، وسطح داكن في الداكن
    final itemBackgroundColor = theme.brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.grey50;

    // لون دائرة الترتيب
    final rankCircleColor = rank <= 3 ? AppColors.warning : AppColors.grey300;
    // لون نص الترتيب
    final rankTextColor = rank <= 3
        ? Colors.white
        : textTheme.bodyMedium?.color;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: itemBackgroundColor,
        borderRadius: AppBorderRadius.medium,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankCircleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rankTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${product['sold']} مبيعة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            product['revenue'],
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              // لون دلالي ثابت
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
