// lib/customer/screens/comparison/customer_comparison_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/comparison_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerComparisonScreen extends StatelessWidget {
  const CustomerComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المقارنة'),
        actions: [
          Consumer<ComparisonProvider>(
            builder: (context, comparison, _) {
              if (comparison.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  comparison.clearComparison();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح المقارنة')),
                  );
                },
                child: const Text(
                  'مسح الكل',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ComparisonProvider>(
        builder: (context, comparison, _) {
          if (comparison.isEmpty) {
            return _buildEmptyComparison(context);
          }

          final products = comparison.productsList;

          return SingleChildScrollView(
            child: Column(
              children: [
                // صور المنتجات
                _buildProductImages(context, products, comparison),
                const Divider(),
                // السعر
                _buildComparisonRow(
                  'السعر',
                  products
                      .map((p) => '${p.price.toStringAsFixed(0)} جنيه')
                      .toList(),
                  highlightBest: true,
                  getBestIndex: (values) {
                    double minPrice = double.infinity;
                    int bestIndex = 0;
                    for (int i = 0; i < products.length; i++) {
                      if (products[i].price < minPrice) {
                        minPrice = products[i].price;
                        bestIndex = i;
                      }
                    }
                    return bestIndex;
                  },
                ),
                // الفئة
                _buildComparisonRow(
                  'الفئة',
                  products.map((p) => p.category).toList(),
                ),
                // البائع
                _buildComparisonRow(
                  'البائع',
                  products.map((p) => p.sellerName).toList(),
                ),
                // التوفر
                _buildComparisonRow(
                  'التوفر',
                  products
                      .map((p) => p.isAvailable ? 'متوفر' : 'غير متوفر')
                      .toList(),
                  highlightBest: true,
                  getBestIndex: (values) {
                    for (int i = 0; i < products.length; i++) {
                      if (products[i].isAvailable) return i;
                    }
                    return -1;
                  },
                ),
                // المواصفات الفنية
                _buildSpecificationsComparison(products),
                const SizedBox(height: 16),
                // أزرار الإضافة للسلة
                _buildAddToCartButtons(context, products),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyComparison(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 100,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد منتجات للمقارنة',
              style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              'أضف منتجات من الصفحة الرئيسية\nللمقارنة بينها',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '(الحد الأقصى 3 منتجات)',
              style: AppTextStyles.caption.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImages(
    BuildContext context,
    List<Product> products,
    ComparisonProvider comparison,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: products.map((product) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.images.first,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image),
                              ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            comparison.removeProduct(product.id);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    List<String> values, {
    bool highlightBest = false,
    int Function(List<String>)? getBestIndex,
  }) {
    int? bestIndex;
    if (highlightBest && getBestIndex != null) {
      bestIndex = getBestIndex(values);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ...List.generate(values.length, (index) {
            final isBest = highlightBest && bestIndex == index;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isBest ? Colors.green.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(4),
                  border: isBest
                      ? Border.all(color: Colors.green, width: 1)
                      : null,
                ),
                child: Text(
                  values[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isBest ? Colors.green.shade700 : null,
                    fontWeight: isBest ? FontWeight.bold : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpecificationsComparison(List<Product> products) {
    // جمع كل المواصفات الفريدة
    final allSpecs = <String>{};
    for (var product in products) {
      allSpecs.addAll(product.specifications.keys);
    }

    if (allSpecs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'المواصفات الفنية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...allSpecs.map((spec) {
          return _buildComparisonRow(
            spec,
            products.map((p) => p.specifications[spec] ?? '-').toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAddToCartButtons(BuildContext context, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: products.map((product) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: product.isAvailable
                    ? () {
                        context.read<CartProvider>().addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت إضافة ${product.name} للسلة'),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('أضف للسلة', style: TextStyle(fontSize: 12)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
