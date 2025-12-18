// lib/screens/reports/reports_screen.dart
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'هذا الشهر';
  String _selectedCategory = 'الكل';
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<OrdersProvider, ProductsProvider>(
      builder: (context, ordersProvider, productsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),
              _buildFiltersSection(isDark),
              const SizedBox(height: 24),
              _buildSummaryCards(ordersProvider, productsProvider, isDark),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildRevenueChart(ordersProvider, isDark),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTopProductsCard(productsProvider, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCategorySalesCard(ordersProvider, isDark),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: _buildCommissionCard(ordersProvider, isDark)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير والإحصائيات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تحليل شامل للمبيعات والأرباح',
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
              onPressed: _exportToPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('تصدير PDF'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _exportToExcel,
              icon: const Icon(Icons.file_download),
              label: const Text('تصدير Excel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersSection(bool isDark) {
    const int alpha10 = 0x19;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفلاتر',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'الفترة الزمنية',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'اليوم', child: Text('اليوم')),
                    DropdownMenuItem(
                      value: 'هذا الأسبوع',
                      child: Text('هذا الأسبوع'),
                    ),
                    DropdownMenuItem(
                      value: 'هذا الشهر',
                      child: Text('هذا الشهر'),
                    ),
                    DropdownMenuItem(
                      value: 'آخر 3 أشهر',
                      child: Text('آخر 3 أشهر'),
                    ),
                    DropdownMenuItem(
                      value: 'هذا العام',
                      child: Text('هذا العام'),
                    ),
                    DropdownMenuItem(value: 'مخصص', child: Text('مخصص')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                      _updateDateRange();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                    DropdownMenuItem(
                      value: 'إلكترونيات',
                      child: Text('إلكترونيات'),
                    ),
                    DropdownMenuItem(value: 'ملابس', child: Text('ملابس')),
                    DropdownMenuItem(value: 'كتب', child: Text('كتب')),
                    DropdownMenuItem(value: 'أثاث', child: Text('أثاث')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              if (_selectedPeriod == 'مخصص') ...[
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCustomDate(isStart: true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'من: ${DateFormat('dd/MM/yyyy').format(_startDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCustomDate(isStart: false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'إلى: ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    OrdersProvider ordersProvider,
    ProductsProvider productsProvider,
    bool isDark,
  ) {
    const int alpha10 = 0x19;

    final filteredOrders = _getFilteredOrders(ordersProvider.orders);
    final totalRevenue = filteredOrders
        .where((o) => o.status.toString().contains('delivered'))
        .fold(0.0, (sum, order) => sum + order.grandTotal);
    final totalOrders = filteredOrders.length;
    final totalCommission = filteredOrders
        .where((o) => o.status.toString().contains('delivered'))
        .fold(0.0, (sum, order) => sum + order.totalCommission);
    final totalProfit = totalCommission;

    final stats = [
      {
        'title': 'إجمالي المبيعات',
        'value': '${NumberFormat('#,##0').format(totalRevenue)} ج',
        'icon': Icons.monetization_on,
        'color': Colors.blue,
        'change': '+12.5%',
      },
      {
        'title': 'عدد الطلبات',
        'value': '$totalOrders',
        'icon': Icons.shopping_cart,
        'color': Colors.green,
        'change': '+8.2%',
      },
      {
        'title': 'العمولات',
        'value': '${NumberFormat('#,##0').format(totalCommission)} ج',
        'icon': Icons.account_balance_wallet,
        'color': Colors.purple,
        'change': '+15.3%',
      },
      {
        'title': 'صافي الربح',
        'value': '${NumberFormat('#,##0').format(totalProfit)} ج',
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'change': '+20.1%',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withAlpha(alpha10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(alpha10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stat['change'] as String,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildRevenueChart(OrdersProvider ordersProvider, bool isDark) {
    const int alpha10 = 0x19;

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تطور المبيعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'المبيعات اليومية خلال الفترة المحددة',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? AppColors.darkDivider : Colors.grey[200]!,
                    strokeWidth: 1,
                  ),
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
                          days[value.toInt() % 7],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value / 1000).toInt()}k',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
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
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(alpha10),
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

  Widget _buildTopProductsCard(ProductsProvider productsProvider, bool isDark) {
    const int alpha10 = 0x19;
    final topProducts = productsProvider.getTopSellingProducts(limit: 5);

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات الأكثر مبيعاً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          ...topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${product.soldCount} مبيعة',
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
                  Text(
                    '${NumberFormat('#,##0').format(product.totalRevenue)} ج',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategorySalesCard(OrdersProvider ordersProvider, bool isDark) {
    const int alpha10 = 0x19;

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبيعات حسب الفئة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: Colors.blue,
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.orange,
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.purple,
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend([
            {'label': 'إلكترونيات', 'color': Colors.blue},
            {'label': 'ملابس', 'color': Colors.green},
            {'label': 'كتب', 'color': Colors.orange},
            {'label': 'أثاث', 'color': Colors.purple},
          ]),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(OrdersProvider ordersProvider, bool isDark) {
    const int alpha10 = 0x19;

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل العمولات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          _buildCommissionItem(
            'إجمالي العمولات',
            '15,450 ج',
            Colors.purple,
            isDark,
          ),
          _buildCommissionItem('متوسط العمولة', '450 ج', Colors.blue, isDark),
          _buildCommissionItem('أعلى عمولة', '1,200 ج', Colors.green, isDark),
          _buildCommissionItem('أقل عمولة', '50 ج', Colors.orange, isDark),
        ],
      ),
    );
  }

  Widget _buildCommissionItem(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    const int alpha10 = 0x19;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(alpha10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(item['label'] as String, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey[400]!;
    if (index == 2) return Colors.brown[400]!;
    return Colors.blue;
  }

  List<dynamic> _getFilteredOrders(List<dynamic> orders) {
    return orders.where((order) {
      final orderDate = order.createdAt as DateTime;
      return orderDate.isAfter(_startDate) &&
          orderDate.isBefore(_endDate.add(Duration(days: 1)));
    }).toList();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
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
      case 'آخر 3 أشهر':
        _startDate = DateTime(now.year, now.month - 3, now.day);
        _endDate = now;
        break;
      case 'هذا العام':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
    }
  }

  Future<void> _selectCustomDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير إلى PDF...'),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: Implement PDF export
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير إلى Excel...'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implement Excel export
  }
}
