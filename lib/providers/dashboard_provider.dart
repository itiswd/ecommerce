import 'package:flutter/material.dart';

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
