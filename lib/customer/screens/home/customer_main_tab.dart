// lib/customer/screens/home/customer_main_tab.dart
import 'package:flutter/material.dart';

class CustomerMainTab extends StatelessWidget {
  const CustomerMainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مكنتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('الصفحة الرئيسية - قيد التطوير'),
      ),
    );
  }
}
