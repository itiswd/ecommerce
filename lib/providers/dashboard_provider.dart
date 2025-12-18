import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  bool isLoading = false;

  // Sales data for charts (last 7 days)
  List<double> salesData = [15000, 22000, 18000, 28000, 24000, 32000, 29000];

  // Sales data by day name
  Map<String, double> salesByDay = {
    'السبت': 15000,
    'الأحد': 22000,
    'الاثنين': 18000,
    'الثلاثاء': 28000,
    'الأربعاء': 24000,
    'الخميس': 32000,
    'الجمعة': 29000,
  };

  // Category distribution
  Map<String, int> categoryData = {
    'إلكترونيات': 35,
    'ملابس': 25,
    'كتب': 20,
    'أثاث': 15,
    'أخرى': 5,
  };

  // Statistics
  double get totalWeeklySales => salesData.fold(0, (sum, value) => sum + value);

  double get averageDailySales => totalWeeklySales / salesData.length;

  double get highestDaySale =>
      salesData.reduce((curr, next) => curr > next ? curr : next);

  double get lowestDaySale =>
      salesData.reduce((curr, next) => curr < next ? curr : next);

  // Growth calculation
  double get weeklyGrowth {
    if (salesData.length < 2) return 0;
    final lastWeek = salesData.sublist(0, salesData.length ~/ 2);
    final thisWeek = salesData.sublist(salesData.length ~/ 2);

    final lastWeekTotal = lastWeek.fold(0.0, (sum, value) => sum + value);
    final thisWeekTotal = thisWeek.fold(0.0, (sum, value) => sum + value);

    if (lastWeekTotal == 0) return 0;
    return ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;
  }

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    // Simulate loading data from API/Firebase
    await Future.delayed(Duration(milliseconds: 800));

    // In a real app, you would fetch data here
    // For now, we're using the sample data defined above

    isLoading = false;
    notifyListeners();
  }

  void refreshData() {
    loadDashboardData();
  }

  // Filter data by period
  void filterByPeriod(String period) {
    // This would filter the data based on the selected period
    // For now, it just triggers a reload
    loadDashboardData();
  }

  // Update sales data (for testing/demo)
  void updateSalesData(List<double> newData) {
    salesData = newData;
    notifyListeners();
  }

  // Add sale (for testing/demo)
  void addSale(double amount) {
    if (salesData.isNotEmpty) {
      salesData[salesData.length - 1] += amount;
      notifyListeners();
    }
  }
}
