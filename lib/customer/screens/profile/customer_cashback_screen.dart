// lib/customer/screens/profile/customer_cashback_screen.dart
import 'package:ecommerce_dashboard/config/customer_constants.dart';
import 'package:ecommerce_dashboard/providers/cashback_provider.dart';
import 'package:ecommerce_dashboard/providers/customer_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomerCashbackScreen extends StatefulWidget {
  const CustomerCashbackScreen({super.key});

  @override
  State<CustomerCashbackScreen> createState() => _CustomerCashbackScreenState();
}

class _CustomerCashbackScreenState extends State<CustomerCashbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCashbackHistory();
    });
  }

  Future<void> _loadCashbackHistory() async {
    final auth = Provider.of<CustomerAuthProvider>(context, listen: false);
    final cashback = Provider.of<CashbackProvider>(context, listen: false);

    if (auth.userId != null) {
      await cashback.loadUserCashbackHistory(auth.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = Provider.of<CustomerAuthProvider>(context);
    final balance = auth.currentUser?.cashbackBalance ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('محفظة الكاش باك')),
      body: Column(
        children: [
          // بطاقة الرصيد
          _buildBalanceCard(balance, colorScheme),

          // كيفية كسب الكاش باك
          _buildHowToEarnSection(colorScheme),

          // سجل العمليات
          Expanded(child: _buildTransactionsHistory()),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'رصيدك الحالي',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wallet, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'كاش باك',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'جنيه',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    balance >= CustomerConstants.minimumCashbackToUse
                        ? 'يمكنك استخدام رصيدك في عملية الشراء القادمة'
                        : 'الحد الأدنى للاستخدام ${CustomerConstants.minimumCashbackToUse.toStringAsFixed(0)} جنيه',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnSection(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'كيف تكسب كاش باك؟',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEarnStep(
            '1',
            'اطلب بأكثر من ${CustomerConstants.minimumOrderForCashback.toStringAsFixed(0)} جنيه',
          ),
          _buildEarnStep(
            '2',
            'احصل على ${(CustomerConstants.cashbackPercentage * 100).toStringAsFixed(0)}% من قيمة الطلب كاش باك',
          ),
          _buildEarnStep('3', 'استخدم الكاش باك في عملية الشراء القادمة'),
        ],
      ),
    );
  }

  Widget _buildEarnStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTransactionsHistory() {
    return Consumer<CashbackProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = provider.userTransactions;

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'لا يوجد سجل عمليات',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ابدأ التسوق لكسب الكاش باك',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'سجل العمليات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final date = transaction['date'] as DateTime;
    final description = transaction['description'] as String;

    final isCredit = type == 'credit';
    final color = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.add_circle : Icons.remove_circle;
    final sign = isCredit ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(description),
        subtitle: Text(
          DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(date),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '$sign${amount.toStringAsFixed(0)} جنيه',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
