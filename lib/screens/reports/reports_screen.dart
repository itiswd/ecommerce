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
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          _buildPeriodSelector(),
          SizedBox(height: 24),
          _buildQuickStats(),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRevenueChart()),
              SizedBox(width: 16),
              Expanded(child: _buildTopProducts()),
            ],
          ),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCategoryBreakdown()),
              SizedBox(width: 16),
              Expanded(child: _buildSalesComparison()),
            ],
          ),
          SizedBox(height: 24),
          _buildDetailedReports(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التقارير والإحصائيات', style: AppTextStyles.h2),
            SizedBox(height: 4),
            Text(
              'تحليل شامل لأداء المتجر',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _exportReport,
              icon: Icon(Icons.file_download),
              label: Text('تصدير PDF'),
            ),
            SizedBox(width: 12),
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.primary),
          SizedBox(width: 12),
          Text('الفترة الزمنية:', style: AppTextStyles.h4),
          SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                _periodChip('اليوم'),
                _periodChip('هذا الأسبوع'),
                _periodChip('هذا الشهر'),
                _periodChip('هذا العام'),
                _periodChip('مخصص'),
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

  Widget _periodChip(String label) {
    final isSelected = _selectedPeriod == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = label;
          _updateDateRange(label);
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
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

  Widget _buildQuickStats() {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
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
                              SizedBox(width: 4),
                              Text(
                                stat['change'] as String,
                                style: TextStyle(
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
                    SizedBox(height: 12),
                    Text(
                      stat['title'] as String,
                      style: AppTextStyles.bodySmall,
                    ),
                    SizedBox(height: 4),
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

  Widget _buildRevenueChart() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  SizedBox(width: 16),
                  _chartLegend('الأرباح', AppColors.success),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppColors.grey200, strokeWidth: 1);
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
                          style: AppTextStyles.caption,
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
                          style: AppTextStyles.caption,
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
                  // Sales Line
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
        SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildTopProducts() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        final topProducts = provider.getTopSellingProducts(limit: 5);

        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.medium,
            boxShadow: [AppShadows.medium],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الأكثر مبيعاً', style: AppTextStyles.h3),
              SizedBox(height: 16),
              ...topProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return _topProductItem(
                  index + 1,
                  product.name,
                  product.soldCount,
                  product.price * product.soldCount,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _topProductItem(int rank, String name, int sales, double revenue) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: AppBorderRadius.small,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.warning : AppColors.grey300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : AppColors.grey700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium),
                Text('$sales مبيعة', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            '${NumberFormat('#,##0').format(revenue)} ج',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المبيعات حسب الفئة', style: AppTextStyles.h3),
          SizedBox(height: 24),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
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
        SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildSalesComparison() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مقارنة المبيعات', style: AppTextStyles.h3),
          SizedBox(height: 24),
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
                          style: AppTextStyles.caption,
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
                          style: AppTextStyles.caption,
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

  Widget _buildDetailedReports() {
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التقارير التفصيلية', style: AppTextStyles.h3),
          SizedBox(height: 16),
          ...reports.map((report) => _reportCard(report)),
        ],
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> report) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: AppBorderRadius.medium,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (report['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              report['icon'] as IconData,
              color: report['color'] as Color,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
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
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _generateReport(report['title'] as String),
            child: Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تصدير التقرير...'),
        action: SnackBarAction(label: 'إلغاء', onPressed: () {}),
      ),
    );
  }

  void _printReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('جاري الطباعة...')));
  }

  void _generateReport(String reportName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reportName),
        content: Text('هل تريد إنشاء هذا التقرير؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم إنشاء التقرير بنجاح')));
            },
            child: Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}
