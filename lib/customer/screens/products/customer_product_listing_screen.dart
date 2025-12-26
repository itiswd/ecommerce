// lib/customer/screens/products/customer_product_listing_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/config/customer_constants.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/comparison_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerProductListingScreen extends StatefulWidget {
  final String? category;
  final String? searchQuery;

  const CustomerProductListingScreen({
    super.key,
    this.category,
    this.searchQuery,
  });

  @override
  State<CustomerProductListingScreen> createState() =>
      _CustomerProductListingScreenState();
}

class _CustomerProductListingScreenState
    extends State<CustomerProductListingScreen> {
  String? _selectedBrand;
  String? _selectedCondition;
  RangeValues _priceRange = const RangeValues(0, 50000);
  String _sortBy = 'الأحدث';
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductsProvider>(context, listen: false);
    await provider.loadProducts();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    var filtered = products.where((p) {
      // تصفية حسب الفئة
      if (widget.category != null && p.category != widget.category) {
        return false;
      }

      // تصفية حسب البحث
      if (widget.searchQuery != null &&
          !p.name.toLowerCase().contains(widget.searchQuery!.toLowerCase())) {
        return false;
      }

      // تصفية حسب السعر
      if (p.price < _priceRange.start || p.price > _priceRange.end) {
        return false;
      }

      // تصفية حسب الماركة
      if (_selectedBrand != null) {
        final brand = p.specifications['الماركة'] ?? '';
        if (brand != _selectedBrand) return false;
      }

      // تصفية حسب الحالة
      if (_selectedCondition != null) {
        final condition = p.specifications['الحالة'] ?? 'جديد';
        if (condition != _selectedCondition) return false;
      }

      return true;
    }).toList();

    // الترتيب
    switch (_sortBy) {
      case 'الأحدث':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'الأقدم':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'الأرخص':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'الأغلى':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'الأكثر مبيعاً':
        filtered.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? widget.searchQuery ?? 'المنتجات'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible:
                  _selectedBrand != null ||
                  _selectedCondition != null ||
                  _priceRange.start > 0 ||
                  _priceRange.end < 50000,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => CustomerConstants.sortOptions
                .map(
                  (option) => PopupMenuItem(
                    value: option,
                    child: Row(
                      children: [
                        if (_sortBy == option)
                          Icon(Icons.check, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(option),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // فلاتر
          if (_isFilterVisible) _buildFiltersSection(colorScheme),

          // قائمة المنتجات
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredProducts = _getFilteredProducts(
                  provider.products,
                );

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد منتجات',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedBrand = null;
                              _selectedCondition = null;
                              _priceRange = const RangeValues(0, 50000);
                            });
                          },
                          child: const Text('إعادة تعيين الفلاتر'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filteredProducts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نطاق السعر
          Text(
            'السعر: ${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} جنيه',
            style: AppTextStyles.bodyMedium,
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 50000,
            divisions: 100,
            labels: RangeLabels(
              '${_priceRange.start.toInt()}',
              '${_priceRange.end.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 12),

          // الماركة والحالة
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'الماركة',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...CustomerConstants.brands.map(
                      (brand) =>
                          DropdownMenuItem(value: brand, child: Text(brand)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCondition,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...CustomerConstants.conditions.map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // زر إعادة التعيين
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedBrand = null;
                  _selectedCondition = null;
                  _priceRange = const RangeValues(0, 50000);
                });
              },
              child: const Text('إعادة تعيين الفلاتر'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<CartProvider, ComparisonProvider>(
      builder: (context, cartProvider, comparisonProvider, _) {
        final isInComparison = comparisonProvider.contains(product.id);

        return InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed('/product-details', arguments: product);
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المنتج
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: product.images.isNotEmpty
                              ? product.images[0]
                              : '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                    // أزرار السلة والمقارنة
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // زر السلة
                          GestureDetector(
                            onTap: () {
                              cartProvider.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تمت الإضافة إلى السلة'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                          // زر المقارنة
                          GestureDetector(
                            onTap: () {
                              if (isInComparison) {
                                comparisonProvider.removeProduct(product.id);
                              } else {
                                comparisonProvider.addProduct(product);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isInComparison
                                    ? Colors.orange
                                    : colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.compare_arrows,
                                color: isInComparison
                                    ? Colors.white
                                    : colorScheme.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // شارة الخصم
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '-${product.discountPercentage!.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // معلومات المنتج
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(0)} جنيه',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 4),
                              Text(
                                product.originalPrice!.toStringAsFixed(0),
                                style: AppTextStyles.caption.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
