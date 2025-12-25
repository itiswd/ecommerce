// lib/customer/screens/cart/customer_cart_screen.dart
import 'package:flutter/material.dart';

class CustomerCartScreen extends StatelessWidget {
  const CustomerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة'),
      ),
      body: const Center(
        child: Text('شاشة السلة - قيد التطوير'),
      ),
    );
  }
}
