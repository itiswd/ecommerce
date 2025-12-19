import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // مؤقت لمدة 3 ثوانٍ كما هو مطلوب في الوصف
    Timer(const Duration(seconds: 3), () {
      // حالياً سنوجه المستخدم لـ AuthWrapper أو الصفحة الرئيسية مباشرة
      Navigator.pushReplacementNamed(context, '/wrapper');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/icons/logo.png', // تأكد من أن المسار صحيح
          width: 264,
          height: 264,
        ),
      ),
    );
  }
}
