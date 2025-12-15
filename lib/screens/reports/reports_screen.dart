// lib/screens/reports/reports_screen.dart
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/customers_provider.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:ecommerce_dashboard/providers/sellers_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'هذا الشهر';
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // 1. استخراج خصائص الثيم الأساسية لسهولة الاستخدام الديناميكي
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(textTheme),
          SizedBox(height: AppSpacing.lg),
          _buildPeriodSelector(colorScheme, textTheme),
          SizedBox(height: AppSpacing.lg),
          _buildQuickStats(colorScheme),
          SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRevenueChart(theme)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _buildTopProducts(colorScheme, textTheme)),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCategoryBreakdown(colorScheme, textTheme)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _buildSalesComparison(colorScheme, textTheme)),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _buildDetailedReports(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التقارير والإحصائيات', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.xs),
            Text(
              'تحليل شامل لأداء المتجر',
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
              onPressed: _exportReport,
              icon: Icon(Icons.file_download),
              label: Text('تصدير PDF'),
            ),
            SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _printReport,
              icon: Icon(Icons.print),
              label: Text('طباعة'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme, TextTheme textTheme) {
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
          // أيقونة بلون الـ Primary الديناميكي
          Icon(Icons.calendar_today, color: colorScheme.primary),
          SizedBox(width: AppSpacing.md),
          Text('الفترة الزمنية:', style: AppTextStyles.h4),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                _periodChip('اليوم', colorScheme),
                _periodChip('هذا الأسبوع', colorScheme),
                _periodChip('هذا الشهر', colorScheme),
                _periodChip('هذا العام', colorScheme),
                _periodChip('مخصص', colorScheme),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم تحديث البيانات')));
            },
            tooltip: 'تحديث',
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String label, ColorScheme colorScheme) {
    final isSelected = _selectedPeriod == label;
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = label;
          _updateDateRange(label);
        });
      },
      // لون الخلفية للغير محدد ديناميكي
      backgroundColor: isSelected ? null : colorScheme.surface,
      // لون الاختيار من الـ Primary الديناميكي
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        // لون النص ديناميكي
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'اليوم':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'هذا الأسبوع':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'هذا الشهر':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'هذا العام':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 'مخصص':
        _showDateRangePicker();
        break;
    }
  }

  Future<void> _showDateRangePicker() async {
    // DateRangePicker يستخدم ثيم التطبيق الرئيسي
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Widget _buildQuickStats(ColorScheme colorScheme) {
    return Consumer4<
      ProductsProvider,
      OrdersProvider,
      CustomersProvider,
      SellersProvider
    >(
      builder: (context, products, orders, customers, sellers, child) {
        final stats = [
          {
            'title': 'إجمالي المبيعات',
            'value': '${NumberFormat('#,##0').format(orders.totalRevenue)} ج',
            'change': '+12.5%',
            'icon': Icons.monetization_on,
            'color': AppColors.success,
            'isPositive': true,
          },
          {
            'title': 'عدد الطلبات',
            'value': '${orders.totalOrders}',
            'change': '+8.2%',
            'icon': Icons.shopping_cart,
            'color': AppColors.info,
            'isPositive': true,
          },
          {
            'title': 'متوسط قيمة الطلب',
            'value':
                '${NumberFormat('#,##0').format(orders.totalOrders > 0 ? orders.totalRevenue / orders.totalOrders : 0)} ج',
            'change': '+5.1%',
            'icon': Icons.receipt,
            'color': AppColors.warning,
            'isPositive': true,
          },
          {
            'title': 'عدد العملاء',
            'value': '${customers.totalCustomers}',
            'change': '+15.3%',
            'icon': Icons.people,
            'color': AppColors.primary,
            'isPositive': true,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            // ألوان دلالية ثابتة مع شفافية
                            color: (stat['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Icon(
                            stat['icon'] as IconData,
                            color: stat['color'] as Color,
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            // ألوان دلالية ثابتة مع شفافية
                            color: (stat['isPositive'] as bool)
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (stat['isPositive'] as bool)
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: (stat['isPositive'] as bool)
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                stat['change'] as String,
                                style: TextStyle(
                                  // ألوان دلالية ثابتة
                                  color: (stat['isPositive'] as bool)
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // النص يرث لون الثيم
                    Text(
                      stat['title'] as String,
                      style: AppTextStyles.bodySmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(stat['value'] as String, style: AppTextStyles.h3),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRevenueChart(ThemeData theme) {
    // تحديد الألوان الديناميكية للـ Chart
    final chartGridColor = theme.dividerColor;
    final chartLabelColor = theme.textTheme.bodySmall?.color;
    final chartBackgroundColor = theme.colorScheme.surface;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // استخدام لون سطح البطاقة الديناميكي
        color: chartBackgroundColor,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإيرادات', style: AppTextStyles.h3),
              Row(
                children: [
                  _chartLegend('المبيعات', AppColors.primary),
                  SizedBox(width: AppSpacing.md),
                  _chartLegend('الأرباح', AppColors.success),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) {
                    // لون خطوط الشبكة ديناميكي
                    return FlLine(color: chartGridColor, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
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
                          days[value.toInt() % 7],
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
                      reservedSize: 50,
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
                  // Sales Line (الألوان الثابتة هنا لرسومات البيانات مقبولة)
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 15000),
                      FlSpot(1, 22000),
                      FlSpot(2, 18000),
                      FlSpot(3, 28000),
                      FlSpot(4, 24000),
                      FlSpot(5, 32000),
                      FlSpot(6, 29000),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  // Profit Line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 8000),
                      FlSpot(1, 12000),
                      FlSpot(2, 10000),
                      FlSpot(3, 16000),
                      FlSpot(4, 14000),
                      FlSpot(5, 19000),
                      FlSpot(6, 17000),
                    ],
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.success.withOpacity(0.1),
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

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.xs),
        // النص يرث لون الثيم
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildTopProducts(ColorScheme colorScheme, TextTheme textTheme) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        final topProducts = provider.getTopSellingProducts(limit: 5);

        return Container(
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
              Text('الأكثر مبيعاً', style: AppTextStyles.h3),
              SizedBox(height: AppSpacing.md),
              ...topProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return _topProductItem(
                  index + 1,
                  product.name,
                  product.soldCount,
                  product.price * product.soldCount,
                  colorScheme,
                  textTheme,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _topProductItem(
    int rank,
    String name,
    int sales,
    double revenue,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // لون خلفية العنصر يتغير حسب الثيم
    final itemBackgroundColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.grey50
        : AppColors.darkSurface;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: itemBackgroundColor,
        borderRadius: AppBorderRadius.small,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              // ألوان دلالية ثابتة للـ Rank
              color: rank <= 3 ? AppColors.warning : AppColors.grey300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  // لون النص يتغير حسب الثيم للحالة غير المميزة
                  color: rank <= 3
                      ? Colors.white
                      : Theme.of(context).brightness == Brightness.light
                      ? AppColors.grey700
                      : AppColors.darkTextPrimary,
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
                Text(name, style: AppTextStyles.bodyMedium),
                Text(
                  '$sales مبيعة',
                  // استخدام لون النص الثانوي الديناميكي
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${NumberFormat('#,##0').format(revenue)} ج',
            style: AppTextStyles.bodyMedium.copyWith(
              // لون دلالي ثابت
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ColorScheme colorScheme, TextTheme textTheme) {
    // تحديد لون نص المحاور ديناميكياً
    final chartLabelColor = textTheme.bodySmall?.color;

    return Container(
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
          Text('المبيعات حسب الفئة', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: AppColors.primary,
                    radius: 100,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: AppColors.success,
                    radius: 100,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: AppColors.warning,
                    radius: 100,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 15,
                    title: '15%',
                    color: AppColors.info,
                    radius: 100,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 5,
                    title: '5%',
                    color: AppColors.grey400,
                    radius: 100,
                    titleStyle: TextStyle(
                      // لون نص المحور ديناميكي
                      color: chartLabelColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _categoryLegend('إلكترونيات', AppColors.primary),
              _categoryLegend('ملابس', AppColors.success),
              _categoryLegend('كتب', AppColors.warning),
              _categoryLegend('أثاث', AppColors.info),
              _categoryLegend('أخرى', AppColors.grey400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildSalesComparison(ColorScheme colorScheme, TextTheme textTheme) {
    // تحديد لون نص المحاور ديناميكياً
    final chartLabelColor = textTheme.bodySmall?.color;

    return Container(
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
          Text('مقارنة المبيعات', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'يناير',
                          'فبراير',
                          'مارس',
                          'أبريل',
                          'مايو',
                          'يونيو',
                        ];
                        return Text(
                          months[value.toInt()],
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
                      reservedSize: 50,
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
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _barGroup(0, 15000, AppColors.primary),
                  _barGroup(1, 18000, AppColors.primary),
                  _barGroup(2, 22000, AppColors.primary),
                  _barGroup(3, 19000, AppColors.primary),
                  _barGroup(4, 25000, AppColors.primary),
                  _barGroup(5, 28000, AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildDetailedReports(ColorScheme colorScheme) {
    final reports = [
      {
        'title': 'تقرير المبيعات التفصيلي',
        'description': 'تحليل كامل للمبيعات مع تفاصيل المنتجات والعملاء',
        'icon': Icons.assessment,
        'color': AppColors.primary,
      },
      {
        'title': 'تقرير المخزون',
        'description': 'حالة المخزون والمنتجات المنخفضة والحركة',
        'icon': Icons.inventory,
        'color': AppColors.warning,
      },
      {
        'title': 'تقرير الأرباح والخسائر',
        'description': 'تحليل مالي شامل مع الإيرادات والمصروفات',
        'icon': Icons.account_balance,
        'color': AppColors.success,
      },
      {
        'title': 'تقرير أداء البائعين',
        'description': 'إحصائيات البائعين والعمولات والمبيعات',
        'icon': Icons.people,
        'color': AppColors.info,
      },
    ];

    return Container(
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
          Text('التقارير التفصيلية', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          ...reports.map((report) => _reportCard(report, colorScheme)),
        ],
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> report, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // لون الحدود ديناميكي
        border: Border.all(color: theme.dividerColor),
        // لون الخلفية من سطح البطاقة
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.medium,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              // ألوان دلالية ثابتة مع شفافية
              color: (report['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              report['icon'] as IconData,
              color: report['color'] as Color,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report['description'] as String,
                  // استخدام لون النص الثانوي الديناميكي
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          // زر "إنشاء" يستخدم ElevatedButtonThemeData
          ElevatedButton(
            onPressed: () => _generateReport(report['title'] as String),
            child: Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    // SnackBar يستخدم الألوان الافتراضية للـ Scaffold والخلفية
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تصدير التقرير...'),
        backgroundColor: colorScheme.surface,
        action: SnackBarAction(label: 'إلغاء', onPressed: () {}),
      ),
    );
  }

  void _printReport() {
    // SnackBar يستخدم الألوان الافتراضية للـ Scaffold والخلفية
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري الطباعة...'),
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  void _generateReport(String reportName) {
    // AlertDialog يستخدم DialogThemeData
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reportName),
        content: Text('هل تريد إنشاء هذا التقرير؟'),
        actions: [
          // TextButton يستخدم TextButtonThemeData
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          // ElevatedButton يستخدم ElevatedButtonThemeData
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إنشاء التقرير بنجاح'),
                  // استخدام لون النجاح الديناميكي (Secondary)
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            child: Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}
