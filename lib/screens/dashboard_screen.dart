import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/dashboard_provider.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
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
  String _selectedPeriod = 'اليوم';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer3<DashboardProvider, OrdersProvider, ProductsProvider>(
      builder:
          (context, dashProvider, ordersProvider, productsProvider, child) {
            if (dashProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(dashProvider, textTheme),
                  SizedBox(height: AppSpacing.lg),
                  _buildStatsCards(
                    ordersProvider,
                    productsProvider,
                    colorScheme,
                    textTheme,
                  ),
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
                        child: _buildOrdersStatusChart(
                          ordersProvider,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildRecentOrders(ordersProvider, theme),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildTopProducts(productsProvider, theme),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(theme),
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
            Row(
              children: [
                Text(
                  'لوحة التحكم',
                  style: AppTextStyles.h2.copyWith(
                    color: textTheme.headlineMedium?.color,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(0x19),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'مباشر',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'مرحباً بك، إليك نظرة عامة على متجرك',
              style: AppTextStyles.bodyMedium.copyWith(
                color: textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildFilterChip('اليوم', _selectedPeriod == 'اليوم', theme),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              'هذا الأسبوع',
              _selectedPeriod == 'هذا الأسبوع',
              theme,
            ),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              'هذا الشهر',
              _selectedPeriod == 'هذا الشهر',
              theme,
            ),
            SizedBox(width: AppSpacing.md),
            IconButton.filled(
              onPressed: () {
                provider.refreshData();
                context.read<OrdersProvider>().refresh();
                context.read<ProductsProvider>().refresh();
              },
              icon: Icon(Icons.refresh),
              tooltip: 'تحديث البيانات',
            ),
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
        setState(() => _selectedPeriod = label);
      },
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        width: 0.5,
      ),
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.grey100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
      ),
    );
  }

  Widget _buildStatsCards(
    OrdersProvider ordersProvider,
    ProductsProvider productsProvider,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final stats = [
      {
        'title': 'إجمالي المبيعات',
        'value':
            '${NumberFormat('#,##0').format(ordersProvider.totalRevenue)} ج',
        'change': '+12.5%',
        'isPositive': true,
        'icon': Icons.attach_money,
        'color': AppColors.primary,
        'subtitle': 'من ${ordersProvider.deliveredOrders} طلب مكتمل',
      },
      {
        'title': 'الطلبات',
        'value': '${ordersProvider.totalOrders}',
        'change': '+8.2%',
        'isPositive': true,
        'icon': Icons.shopping_cart,
        'color': AppColors.success,
        'subtitle': '${ordersProvider.pendingOrders} قيد الانتظار',
      },
      {
        'title': 'المنتجات',
        'value': '${productsProvider.totalProducts}',
        'change': '+5',
        'isPositive': true,
        'icon': Icons.inventory_2,
        'color': AppColors.info,
        'subtitle': '${productsProvider.activeProducts} نشط',
      },
      {
        'title': 'العمولة المكتسبة',
        'value':
            '${NumberFormat('#,##0').format(ordersProvider.totalCommission)} ج',
        'change': '+20.1%',
        'isPositive': true,
        'icon': Icons.trending_up,
        'color': AppColors.warning,
        'subtitle': 'من ${ordersProvider.deliveredOrders} طلب',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.4,
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
          subtitle: stat['subtitle'] as String,
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
    required String subtitle,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    const alpha10 = 0x19;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
        border: Border.all(color: color.withAlpha(0x33), width: 1),
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
                  color: color.withAlpha(alpha10),
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
                  color: isPositive
                      ? AppColors.success.withAlpha(alpha10)
                      : AppColors.error.withAlpha(alpha10),
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
                  color: textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(value, style: AppTextStyles.h3.copyWith(color: color)),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(DashboardProvider provider, ThemeData theme) {
    final chartGridColor = theme.dividerColor;
    final chartLabelColor = theme.textTheme.bodySmall?.color;
    final chartTitleColor = theme.textTheme.titleMedium?.color;
    final chartBackgroundColor = theme.colorScheme.surface;
    const alpha10 = 0x19;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: chartBackgroundColor,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المبيعات الأسبوعية',
                    style: AppTextStyles.h4.copyWith(color: chartTitleColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'آخر 7 أيام',
                    style: TextStyle(fontSize: 12, color: chartLabelColor),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem('المبيعات', AppColors.primary),
                  SizedBox(width: 16),
                  _buildLegendItem('الهدف', AppColors.success),
                ],
              ),
            ],
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
                          style: AppTextStyles.caption.copyWith(
                            color: chartLabelColor,
                          ),
                        );
                      },
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
                    spots: provider.salesData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withAlpha(alpha10),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildOrdersStatusChart(
    OrdersProvider ordersProvider,
    ColorScheme colorScheme,
  ) {
    final chartTitleColor = Theme.of(context).textTheme.titleMedium?.color;

    final statusData = [
      {
        'status': 'مكتمل',
        'count': ordersProvider.deliveredOrders,
        'color': AppColors.success,
      },
      {
        'status': 'قيد الشحن',
        'count': ordersProvider.shippedOrders,
        'color': AppColors.info,
      },
      {
        'status': 'قيد الانتظار',
        'count': ordersProvider.pendingOrders,
        'color': AppColors.warning,
      },
      {
        'status': 'ملغي',
        'count': ordersProvider.cancelledOrders,
        'color': AppColors.error,
      },
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلبات',
            style: AppTextStyles.h4.copyWith(color: chartTitleColor),
          ),
          SizedBox(height: 4),
          Text(
            'توزيع الطلبات حسب الحالة',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: statusData.map((data) {
                  final count = data['count'] as int;
                  final total = ordersProvider.totalOrders;
                  final percentage = total > 0 ? (count / total * 100) : 0;

                  return PieChartSectionData(
                    value: count.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: data['color'] as Color,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
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
          SizedBox(height: AppSpacing.md),
          ...statusData.map(
            (data) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: data['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['status'] as String,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${data['count']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(OrdersProvider provider, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final chartTitleColor = textTheme.titleMedium?.color;

    final recentOrders = provider.orders.take(5).toList();

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أحدث الطلبات',
                    style: AppTextStyles.h4.copyWith(color: chartTitleColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'آخر ${recentOrders.length} طلبات',
                    style: TextStyle(
                      fontSize: 12,
                      color: textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (recentOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'لا توجد طلبات حتى الآن',
                  style: TextStyle(color: textTheme.bodySmall?.color),
                ),
              ),
            )
          else
            ...recentOrders.map((order) => _buildOrderItem(order, theme)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final itemBackgroundColor = theme.brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.grey50;
    final statusColor = _getStatusColor(order.status);
    const alpha10 = 0x19;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: itemBackgroundColor,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withAlpha(alpha10),
            child: Text(
              order.customerName[0],
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
                  order.customerName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'طلب #${order.id}',
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
                '${NumberFormat('#,##0').format(order.grandTotal)} ج',
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
                  color: statusColor.withAlpha(alpha10),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(
                  order.status.arabicName,
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

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'OrderStatus.delivered':
        return AppColors.success;
      case 'OrderStatus.pending':
        return AppColors.warning;
      case 'OrderStatus.shipped':
        return AppColors.info;
      case 'OrderStatus.cancelled':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  Widget _buildTopProducts(ProductsProvider provider, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final chartTitleColor = theme.textTheme.titleMedium?.color;

    final topProducts = provider.getTopSellingProducts(limit: 5);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأكثر مبيعاً',
                    style: AppTextStyles.h4.copyWith(color: chartTitleColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'أفضل ${topProducts.length} منتجات',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (topProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'لا توجد منتجات حتى الآن',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
              ),
            )
          else
            ...topProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return _buildTopProductItem(index + 1, product, theme);
            }),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(int rank, product, ThemeData theme) {
    final textTheme = theme.textTheme;
    final itemBackgroundColor = theme.brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.grey50;

    final rankCircleColor = rank <= 3 ? AppColors.warning : AppColors.grey300;
    final rankTextColor = rank <= 3
        ? Colors.white
        : textTheme.bodyMedium?.color;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: itemBackgroundColor,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: theme.dividerColor, width: 0.5),
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
                  product.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${product.soldCount} مبيعة',
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
                '${NumberFormat('#,##0').format(product.totalRevenue)} ج',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Text(
                '${NumberFormat('#,##0').format(product.totalCommission)} ج عمولة',
                style: TextStyle(
                  fontSize: 11,
                  color: textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    final actions = [
      {
        'title': 'إضافة منتج',
        'icon': Icons.add_box,
        'color': AppColors.primary,
        'onTap': () {},
      },
      {
        'title': 'عرض الطلبات',
        'icon': Icons.shopping_bag,
        'color': AppColors.success,
        'onTap': () {},
      },
      {
        'title': 'إدارة البانرات',
        'icon': Icons.image,
        'color': AppColors.warning,
        'onTap': () {},
      },
      {
        'title': 'التقارير',
        'icon': Icons.assessment,
        'color': AppColors.info,
        'onTap': () {},
      },
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إجراءات سريعة', style: AppTextStyles.h4),
          SizedBox(height: AppSpacing.md),
          Row(
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md),
                  child: InkWell(
                    onTap: action['onTap'] as VoidCallback,
                    borderRadius: AppBorderRadius.medium,
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withAlpha(0x19),
                        borderRadius: AppBorderRadius.medium,
                        border: Border.all(
                          color: (action['color'] as Color).withAlpha(0x33),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            action['icon'] as IconData,
                            size: 32,
                            color: action['color'] as Color,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            action['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: action['color'] as Color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
