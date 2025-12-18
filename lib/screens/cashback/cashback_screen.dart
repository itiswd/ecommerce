// lib/screens/cashback/cashback_screen.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/cashback.dart';
import 'package:ecommerce_dashboard/providers/cashback_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CashbackScreen extends StatefulWidget {
  const CashbackScreen({super.key});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  final TextEditingController _searchController = TextEditingController();
  CashbackType? _selectedType;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CashbackProvider>(
        context,
        listen: false,
      ).loadTransactions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CashbackProvider>(
      builder: (context, cashbackProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cashbackProvider, isDark),
              const SizedBox(height: 24),
              _buildStatsCards(cashbackProvider.stats, isDark),
              const SizedBox(height: 24),
              _buildFiltersSection(isDark),
              const SizedBox(height: 24),
              _buildTransactionsTable(cashbackProvider, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(CashbackProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إدارة الكاش باك',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'متابعة معاملات الكاش باك',
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
              onPressed: () => _showAddTransactionDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('تعديل يدوي'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(CashbackStats stats, bool isDark) {
    const int alpha10 = 0x19;

    final statsData = [
      {
        'title': 'إجمالي المكتسب',
        'value': '${NumberFormat('#,##0').format(stats.totalEarned)} ج',
        'icon': Icons.arrow_upward,
        'color': Colors.green,
      },
      {
        'title': 'إجمالي المستخدم',
        'value': '${NumberFormat('#,##0').format(stats.totalUsed)} ج',
        'icon': Icons.arrow_downward,
        'color': Colors.blue,
      },
      {
        'title': 'المنتهي الصلاحية',
        'value': '${NumberFormat('#,##0').format(stats.totalExpired)} ج',
        'icon': Icons.close,
        'color': Colors.red,
      },
      {
        'title': 'الرصيد الحالي',
        'value': '${NumberFormat('#,##0').format(stats.currentBalance)} ج',
        'icon': Icons.account_balance_wallet,
        'color': Colors.purple,
      },
    ];

    return Row(
      children: statsData.map((stat) {
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

  Widget _buildFiltersSection(bool isDark) {
    const int alpha10 = 0x19;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن عميل...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<CashbackType?>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع المعاملة',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('الكل')),
                ...CashbackType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.arabicName),
                  );
                }),
              ],
              isExpanded: true,
              onChanged: (value) => setState(() => _selectedType = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(CashbackProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    var filteredTransactions = provider.search(_searchController.text);

    if (_selectedType != null) {
      filteredTransactions = filteredTransactions
          .where((t) => t.type == _selectedType)
          .toList();
    }

    const int alpha10 = 0x19;

    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المعاملات (${filteredTransactions.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          SizedBox(
            height: 600,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 20,
              minWidth: 1000,
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkSurface : Colors.grey[50],
              ),
              dataRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkCard : Colors.white,
              ),
              columns: const [
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'العميل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'رقم الطلب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المبلغ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'النوع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الوصف',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الإجراءات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.S,
                ),
              ],
              rows: filteredTransactions.map((transaction) {
                return DataRow(
                  cells: [
                    DataCell(Center(child: Text(transaction.customerName))),
                    DataCell(Center(child: Text(transaction.orderId ?? '-'))),
                    DataCell(
                      Center(
                        child: Text(
                          '${NumberFormat('#,##0').format(transaction.amount)} ج',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(transaction.type),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              transaction.type,
                            ).withAlpha(alpha10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            transaction.type.arabicName,
                            style: TextStyle(
                              color: _getTypeColor(transaction.type),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                            'ar',
                          ).format(transaction.createdAt),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          transaction.description ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () =>
                              _confirmDelete(context, transaction, provider),
                          tooltip: 'حذف',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(CashbackType type) {
    switch (type) {
      case CashbackType.earned:
        return Colors.green;
      case CashbackType.used:
        return Colors.blue;
      case CashbackType.expired:
        return Colors.red;
      case CashbackType.adjusted:
        return Colors.purple;
    }
  }

  Color _getAmountColor(CashbackType type) {
    switch (type) {
      case CashbackType.earned:
      case CashbackType.adjusted:
        return Colors.green;
      case CashbackType.used:
      case CashbackType.expired:
        return Colors.red;
    }
  }

  void _showAddTransactionDialog(BuildContext context) {
    final customerNameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل يدوي'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ (موجب للإضافة، سالب للخصم)',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customerNameController.text.isEmpty ||
                  amountController.text.isEmpty) {
                return;
              }

              final transaction = CashbackTransaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                customerId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                customerName: customerNameController.text,
                amount: double.parse(amountController.text).abs(),
                type: CashbackType.adjusted,
                createdAt: DateTime.now(),
                description: descriptionController.text,
              );

              Provider.of<CashbackProvider>(
                context,
                listen: false,
              ).addTransaction(transaction);

              Navigator.pop(context);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إضافة المعاملة بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CashbackTransaction transaction,
    CashbackProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTransaction(transaction.id);
              Navigator.pop(context);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المعاملة بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
