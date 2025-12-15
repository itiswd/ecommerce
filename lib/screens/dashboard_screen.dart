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
    // جلب البيانات عند فتح الصفحة
    Future.microtask(
      () => Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadDashboardData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, child) {
        if (dashProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(dashProvider),
              SizedBox(height: 24),

              // Stats Cards
              _buildStatsCards(dashProvider),
              SizedBox(height: 24),

              // Charts Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSalesChart(dashProvider)),
                  SizedBox(width: 16),
                  Expanded(child: _buildCategoryPieChart(dashProvider)),
                ],
              ),
              SizedBox(height: 24),

              // Recent Orders & Top Products
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentOrders(dashProvider)),
                  SizedBox(width: 16),
                  Expanded(child: _buildTopProducts(dashProvider)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DashboardProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'مرحباً بك، إليك نظرة عامة على متجرك',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            _buildFilterChip('اليوم', true),
            SizedBox(width: 8),
            _buildFilterChip('هذا الأسبوع', false),
            SizedBox(width: 8),
            _buildFilterChip('هذا الشهر', false),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider) {
    final stats = [
      {
        'title': 'إجمالي المبيعات',
        'value': '${NumberFormat('#,##0').format(provider.totalSales)} جنيه',
        'change': '+12.5%',
        'isPositive': true,
        'icon': Icons.attach_money,
        'color': Colors.blue,
      },
      {
        'title': 'الطلبات',
        'value': '${provider.totalOrders}',
        'change': '+8.2%',
        'isPositive': true,
        'icon': Icons.shopping_cart,
        'color': Colors.green,
      },
      {
        'title': 'العملاء',
        'value': '${provider.totalCustomers}',
        'change': '+15.3%',
        'isPositive': true,
        'icon': Icons.people,
        'color': Colors.purple,
      },
      {
        'title': 'العمولة المكتسبة',
        'value':
            '${NumberFormat('#,##0').format(provider.totalCommission)} جنيه',
        'change': '+20.1%',
        'isPositive': true,
        'icon': Icons.trending_up,
        'color': Colors.orange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
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
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(DashboardProvider provider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبيعات الأسبوعية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
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
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
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

  Widget _buildCategoryPieChart(DashboardProvider provider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات حسب الفئة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: provider.categoryData.entries.map((entry) {
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
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

  Widget _buildRecentOrders(DashboardProvider provider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أحدث الطلبات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(onPressed: () {}, child: Text('عرض الكل')),
            ],
          ),
          SizedBox(height: 16),
          ...provider.recentOrders.map((order) => _buildOrderItem(order)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(
              order['customer'][0],
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customer'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  order['product'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order['amount'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    color: _getStatusColor(order['status']),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد المعالجة':
        return Colors.orange;
      case 'قيد الشحن':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTopProducts(DashboardProvider provider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأكثر مبيعاً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          ...provider.topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return _buildTopProductItem(index + 1, product);
          }),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(int rank, Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : Colors.grey[700],
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
                Text(
                  product['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${product['sold']} مبيعة',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            product['revenue'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// Provider للـ Dashboard
class DashboardProvider extends ChangeNotifier {
  bool isLoading = true;
  double totalSales = 245800;
  int totalOrders = 185;
  int totalCustomers = 98;
  double totalCommission = 24580;

  List<double> salesData = [15000, 22000, 18000, 28000, 24000, 32000, 29000];

  Map<String, int> categoryData = {
    'إلكترونيات': 35,
    'ملابس': 25,
    'كتب': 20,
    'أثاث': 15,
    'أخرى': 5,
  };

  List<Map<String, dynamic>> recentOrders = [
    {
      'customer': 'أحمد محمد',
      'product': 'لابتوب HP',
      'amount': '12,500 جنيه',
      'status': 'مكتمل',
    },
    {
      'customer': 'سارة علي',
      'product': 'هاتف iPhone',
      'amount': '18,000 جنيه',
      'status': 'قيد المعالجة',
    },
    {
      'customer': 'محمود حسن',
      'product': 'سماعات Sony',
      'amount': '2,800 جنيه',
      'status': 'مكتمل',
    },
  ];

  List<Map<String, dynamic>> topProducts = [
    {'name': 'لابتوب Dell XPS', 'sold': 45, 'revenue': '225,000 ج'},
    {'name': 'iPhone 15 Pro', 'sold': 38, 'revenue': '342,000 ج'},
    {'name': 'iPad Air', 'sold': 32, 'revenue': '192,000 ج'},
    {'name': 'AirPods Pro', 'sold': 28, 'revenue': '84,000 ج'},
  ];

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    // محاكاة جلب البيانات من API/Firebase
    await Future.delayed(Duration(seconds: 1));

    isLoading = false;
    notifyListeners();
  }

  void refreshData() {
    loadDashboardData();
  }
}
