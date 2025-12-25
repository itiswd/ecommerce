// lib/customer/screens/products/customer_product_details_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/comparison_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerProductDetailsScreen extends StatefulWidget {
  final Product? product;

  const CustomerProductDetailsScreen({super.key, this.product});

  @override
  State<CustomerProductDetailsScreen> createState() =>
      _CustomerProductDetailsScreenState();
}

class _CustomerProductDetailsScreenState
    extends State<CustomerProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: const Center(child: Text('المنتج غير موجود')),
      );
    }

    final product = widget.product!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // صور المنتج
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(product),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareProduct(product),
              ),
              Consumer<ComparisonProvider>(
                builder: (context, comparison, _) {
                  final isInComparison = comparison.contains(product.id);
                  return IconButton(
                    icon: Icon(
                      isInComparison
                          ? Icons.compare_arrows
                          : Icons.compare_arrows_outlined,
                      color: isInComparison ? Colors.orange : null,
                    ),
                    onPressed: () {
                      if (isInComparison) {
                        comparison.removeProduct(product.id);
                        _showSnackBar('تم الحذف من المقارنة');
                      } else {
                        final added = comparison.addProduct(product);
                        _showSnackBar(
                          added
                              ? 'تمت الإضافة للمقارنة'
                              : 'الحد الأقصى 3 منتجات للمقارنة',
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // محتوى الصفحة
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج
                  Text(
                    product.name,
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // السعر
                  _buildPriceSection(product, colorScheme),
                  const SizedBox(height: 16),

                  // البائع
                  _buildSellerSection(product, colorScheme),
                  const SizedBox(height: 20),

                  // الكمية
                  _buildQuantitySelector(colorScheme),
                  const SizedBox(height: 20),

                  // الوصف
                  _buildDescriptionSection(product),
                  const SizedBox(height: 20),

                  // المواصفات الفنية
                  if (product.specifications.isNotEmpty)
                    _buildSpecificationsSection(product, colorScheme),
                  const SizedBox(height: 100), // مساحة للأزرار السفلية
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(product, colorScheme),
    );
  }

  Widget _buildImageGallery(Product product) {
    if (product.images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 64),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: product.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showFullImage(product.images[index]),
              child: CachedNetworkImage(
                imageUrl: product.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            );
          },
        ),
        // مؤشر الصور
        if (product.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        // شارة الخصم
        if (product.hasDiscount)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'خصم ${product.discountPercentage!.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(Product product, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${product.price.toStringAsFixed(0)} جنيه',
          style: AppTextStyles.h2.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 12),
          Text(
            '${product.originalPrice!.toStringAsFixed(0)} جنيه',
            style: AppTextStyles.bodyLarge.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'وفّر ${(product.originalPrice! - product.price).toStringAsFixed(0)} جنيه',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSellerSection(Product product, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مباع بواسطة',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  product.sellerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Icon(Icons.verified, color: colorScheme.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ColorScheme colorScheme) {
    return Row(
      children: [
        const Text(
          'الكمية:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوصف',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(product.description, style: const TextStyle(height: 1.6)),
      ],
    );
  }

  Widget _buildSpecificationsSection(Product product, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المواصفات الفنية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: product.specifications.entries.map((entry) {
              final isEven =
                  product.specifications.keys.toList().indexOf(entry.key) % 2 ==
                  0;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isEven ? colorScheme.surfaceContainerHighest : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(flex: 3, child: Text(entry.value)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(Product product, ColorScheme colorScheme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // زر المقارنة
            Consumer<ComparisonProvider>(
              builder: (context, comparison, _) {
                final isInComparison = comparison.contains(product.id);
                return OutlinedButton.icon(
                  onPressed: () {
                    if (isInComparison) {
                      comparison.removeProduct(product.id);
                      _showSnackBar('تم الحذف من المقارنة');
                    } else {
                      final added = comparison.addProduct(product);
                      if (added) {
                        _showSnackBar('تمت الإضافة للمقارنة');
                      } else {
                        _showSnackBar('الحد الأقصى 3 منتجات للمقارنة');
                      }
                    }
                  },
                  icon: Icon(
                    Icons.compare_arrows,
                    color: isInComparison ? Colors.orange : colorScheme.primary,
                  ),
                  label: Text(
                    isInComparison ? 'في المقارنة' : 'قارن',
                    style: TextStyle(
                      color: isInComparison
                          ? Colors.orange
                          : colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    side: BorderSide(
                      color: isInComparison
                          ? Colors.orange
                          : colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // زر إضافة للسلة
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      cart.addToCart(product, quantity: _quantity);
                      _showSnackBar('تمت الإضافة إلى السلة ($_quantity)');
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(
                      'أضف للسلة (${(product.price * _quantity).toStringAsFixed(0)} جنيه)',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  void _shareProduct(Product product) {
    // TODO: تنفيذ المشاركة
    _showSnackBar('المشاركة - قريباً');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
