import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:ecommerce_dashboard/screens/products/add_edit_product_dialog.dart';
import 'package:ecommerce_dashboard/screens/products/product_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _selectedStatus = 'الكل';
  String _sortBy = 'الأحدث';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<ProductsProvider>(context, listen: false).loadProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(productsProvider, isDark),
              const SizedBox(height: 24),
              _buildStatsCards(productsProvider, isDark),
              const SizedBox(height: 24),
              _buildFiltersSection(isDark),
              const SizedBox(height: 24),
              _buildProductsTable(productsProvider, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProductsProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتجات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'إدارة منتجات المتجر',
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
              onPressed: () => provider.exportProducts(),
              icon: const Icon(Icons.download),
              label: const Text('تصدير'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(ProductsProvider provider, bool isDark) {
    // 0.1 * 255 = 25 (0x19)
    const int alpha10 = 0x19;
    // 0.1 * 255 = 25 (0x19)
    const int alphaShadow = 0x19;

    final stats = [
      {
        'title': 'إجمالي المنتجات',
        'value': '${provider.products.length}',
        'icon': Icons.inventory_2,
        'color': Colors.blue,
        'trend': '+5',
      },
      {
        'title': 'المنتجات النشطة',
        'value': '${provider.products.where((p) => p.isActive).length}',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'trend': '+12',
      },
      {
        'title': 'المخزون المنخفض',
        'value': '${provider.products.where((p) => p.stock < 10).length}',
        'icon': Icons.warning,
        'color': Colors.orange,
        'trend': '-3',
      },
      {
        'title': 'نفذت من المخزون',
        'value': '${provider.products.where((p) => p.stock == 0).length}',
        'icon': Icons.remove_circle,
        'color': Colors.red,
        'trend': '0',
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // استخدام withAlpha
                  color: (isDark ? Colors.black : Colors.grey).withAlpha(
                    alphaShadow,
                  ),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // استخدام withAlpha
                        color: (stat['color'] as Color).withAlpha(alpha10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 24,
                      ),
                    ),
                    Text(
                      stat['trend'] as String,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
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
    const int alphaShadow = 0x19;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withAlpha(alphaShadow),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // حقل البحث
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),

              // الفئة
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'الفئة',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    isExpanded: true,
                    items:
                        ['الكل', 'إلكترونيات', 'ملابس', 'كتب', 'أثاث', 'أخرى']
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                  ),
                ),
              ),

              // الحالة
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    isExpanded: true,
                    items: ['الكل', 'نشط', 'غير نشط', 'نفذ من المخزون']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value!),
                  ),
                ),
              ),

              // ترتيب حسب
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'ترتيب حسب',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  isExpanded: true,
                  items:
                      [
                            'الأحدث',
                            'الأقدم',
                            'السعر: الأعلى',
                            'السعر: الأقل',
                            'الأكثر مبيعاً',
                          ]
                          .map(
                            (sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(
                                sort,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsTable(ProductsProvider provider, bool isDark) {
    const int alpha10 = 0x19;

    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return _buildEmptyState(isDark);
    }

    var filteredProducts = provider.products.where((product) {
      bool matchesSearch =
          _searchController.text.isEmpty ||
          product.name.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      bool matchesCategory =
          _selectedCategory == 'الكل' || product.category == _selectedCategory;
      bool matchesStatus =
          _selectedStatus == 'الكل' ||
          (_selectedStatus == 'نشط' && product.isActive) ||
          (_selectedStatus == 'غير نشط' && !product.isActive) ||
          (_selectedStatus == 'نفذ من المخزون' && product.stock == 0);
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    switch (_sortBy) {
      case 'الأقدم':
        filteredProducts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'السعر: الأعلى':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'السعر: الأقل':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'الأكثر مبيعاً':
        filteredProducts.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      default:
        filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withAlpha(alpha10),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  'قائمة المنتجات (${filteredProducts.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => provider.loadProducts(),
                      tooltip: 'تحديث',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.divider.withAlpha(128)
                : AppColors.darkDivider.withAlpha(128),
          ),
          SizedBox(
            height: 600,
            child: DataTable2(
              dataRowHeight: 80,
              columnSpacing: 12,
              horizontalMargin: 8,
              minWidth: 1200,
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
                    'المنتج',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الفئة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'السعر',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المخزون',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'المبيعات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'العمولة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'البائع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              rows: filteredProducts.map((product) {
                return DataRow(
                  cells: [
                    // Product Cell
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.images.first,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 40,
                                      height: 40,
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 40,
                                          height: 40,
                                          color: isDark
                                              ? AppColors.darkSurface
                                              : Colors.grey[200],
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    color: isDark
                                        ? AppColors.darkSurface
                                        : Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'رقم: ${product.id}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category Cell
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // استخدام withAlpha
                            color: Colors.blue.withAlpha(
                              0x19,
                            ), // 0.1 * 255 = 25
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Price Cell
                    DataCell(
                      Center(
                        child: Text(
                          '${NumberFormat('#,##0').format(product.price)} ج',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    // Stock Cell
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: product.stock == 0
                                ? Colors.red
                                : product.stock < 10
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              color: product.stock == 0
                                  ? Colors.red
                                  : product.stock < 10
                                  ? Colors.orange
                                  : (isDark
                                        ? AppColors.darkTextPrimary
                                        : Colors.grey[800]),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sales Cell
                    DataCell(
                      Center(
                        child: Text(
                          '${product.soldCount}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Commission Cell
                    DataCell(
                      Center(
                        child: Text(
                          '${(product.commission * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Seller Cell
                    DataCell(
                      Center(
                        child: Text(
                          product.sellerName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Status Cell
                    DataCell(
                      Center(
                        child: Switch(
                          value: product.isActive,
                          onChanged: (value) =>
                              provider.toggleProductStatus(product.id),
                        ),
                      ),
                    ),
                    // Actions Cell
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () => _showProductDetails(context, product),
                            child: Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                _showEditProductDialog(context, product),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.orange,
                            ),
                          ),
                          InkWell(
                            onTap: () => _confirmDelete(context, product),
                            child: Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
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

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة منتجاتك الأولى',
              style: TextStyle(
                color: isDark ? AppColors.darkTextLight : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج جديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditProductDialog(),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(product: product),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(product: product),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. استخدام provider محليًا قبل الـ await (رغم عدم وجود await هنا، الأفضل هو فصل الـ provider عن الـ context)
              final provider = Provider.of<ProductsProvider>(
                context,
                listen: false,
              );

              // 2. إغلاق الـ Dialog
              Navigator.pop(context);

              // 3. تنفيذ الحذف
              provider.deleteProduct(product.id);

              // 4. استخدام mounted للتحقق قبل ScaffoldMessenger
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المنتج بنجاح')),
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
