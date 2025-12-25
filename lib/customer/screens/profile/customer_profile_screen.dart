// lib/customer/screens/profile/customer_profile_screen.dart
import 'package:flutter/material.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
      ),
      body: const Center(
        child: Text('شاشة الملف الشخصي - قيد التطوير'),
      ),
    );
  }
}
