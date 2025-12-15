import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
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
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(productsProvider),
              SizedBox(height: 24),

              // Stats Cards
              _buildStatsCards(productsProvider),
              SizedBox(height: 24),

              // Filters & Search
              _buildFiltersSection(),
              SizedBox(height: 24),

              // Products Table
              _buildProductsTable(productsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProductsProvider provider) {
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
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'إدارة منتجات المتجر',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => provider.exportProducts(),
              icon: Icon(Icons.download),
              label: Text('تصدير'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: Icon(Icons.add),
              label: Text('إضافة منتج'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(ProductsProvider provider) {
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
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withOpacity(0.1),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  stat['title'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          SizedBox(width: 16),

          // Category Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'الفئة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: ['الكل', 'إلكترونيات', 'ملابس', 'كتب', 'أثاث', 'أخرى']
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
          ),
          SizedBox(width: 16),

          // Status Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'الحالة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: ['الكل', 'نشط', 'غير نشط', 'نفذ من المخزون']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
          ),
          SizedBox(width: 16),

          // Sort By
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: InputDecoration(
                labelText: 'ترتيب حسب',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  [
                        'الأحدث',
                        'الأقدم',
                        'السعر: الأعلى',
                        'السعر: الأقل',
                        'الأكثر مبيعاً',
                      ]
                      .map(
                        (sort) =>
                            DropdownMenuItem(value: sort, child: Text(sort)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() => _sortBy = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(ProductsProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return _buildEmptyState();
    }

    // Filter products
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

    // Sort products
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          // Table Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة المنتجات (${filteredProducts.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => provider.loadProducts(),
                      tooltip: 'تحديث',
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {},
                      tooltip: 'فلترة متقدمة',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Table
          SizedBox(
            height: 600,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 20,
              minWidth: 1200,
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: [
                DataColumn2(
                  label: Text(
                    'المنتج',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'الفئة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'السعر',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'المخزون',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'المبيعات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'العمولة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'البائع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn2(
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
                    // Product with Image
                    DataCell(
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.images.first,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'رقم: ${product.id}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
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

                    // Price
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0').format(product.price)} ج',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Stock
                    DataCell(
                      Row(
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
                          SizedBox(width: 6),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              color: product.stock == 0
                                  ? Colors.red
                                  : product.stock < 10
                                  ? Colors.orange
                                  : Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sales
                    DataCell(
                      Text(
                        '${product.soldCount}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    // Commission
                    DataCell(
                      Text(
                        '${(product.commission * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Seller
                    DataCell(
                      Text(product.sellerName, style: TextStyle(fontSize: 13)),
                    ),

                    // Status
                    DataCell(
                      Switch(
                        value: product.isActive,
                        onChanged: (value) {
                          provider.toggleProductStatus(product.id);
                        },
                        activeThumbColor: Colors.green,
                      ),
                    ),

                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, size: 18),
                            onPressed: () =>
                                _showProductDetails(context, product),
                            tooltip: 'عرض',
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 18),
                            onPressed: () =>
                                _showEditProductDialog(context, product),
                            tooltip: 'تعديل',
                            color: Colors.orange,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18),
                            onPressed: () => _confirmDelete(context, product),
                            tooltip: 'حذف',
                            color: Colors.red,
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

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'لا توجد منتجات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ابدأ بإضافة منتجاتك الأولى',
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: Icon(Icons.add),
              label: Text('إضافة منتج جديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AddEditProductDialog());
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
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProductsProvider>(
                context,
                listen: false,
              ).deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم حذف المنتج بنجاح')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
