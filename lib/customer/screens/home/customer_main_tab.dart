// lib/customer/screens/home/customer_main_tab.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/config/customer_constants.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/banner.dart' as models;
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/banners_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerMainTab extends StatefulWidget {
  const CustomerMainTab({super.key});

  @override
  State<CustomerMainTab> createState() => _CustomerMainTabState();
}

class _CustomerMainTabState extends State<CustomerMainTab> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final bannersProvider = context.read<BannersProvider>();
    final productsProvider = context.read<ProductsProvider>();
    
    await Future.wait([
      bannersProvider.fetchBanners(),
      productsProvider.fetchProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('مكنتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('البحث - قريباً')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الإشعارات - قريباً')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banners Section
              _buildBannersSection(),
              const SizedBox(height: 20),
              // Categories Section
              _buildCategoriesSection(colorScheme),
              const SizedBox(height: 20),
              // Best Sellers Section
              _buildBestSellersSection(),
              const SizedBox(height: 20),
              // All Products Section
              _buildAllProductsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannersSection() {
    return Consumer<BannersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.banners.isEmpty) {
          return const SizedBox.shrink();
        }

        final activeBanners = provider.banners
            .where((b) => b.isActive)
            .toList();

        if (activeBanners.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 200,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: activeBanners.length,
                itemBuilder: (context, index) {
                  final banner = activeBanners[index];
                  return _buildBannerItem(banner);
                },
              ),
              // Page Indicator
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    activeBanners.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentBannerIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerItem(models.Banner banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأقسام',
            style: AppTextStyles.h3.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: CustomerConstants.productCategories.length,
            itemBuilder: (context, index) {
              final category = CustomerConstants.productCategories[index];
              final icon = CustomerConstants.categoryIcons[category] ?? Icons.category;
              
              return InkWell(
                onTap: () {
                  // TODO: Navigate to category products
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('عرض منتجات: $category')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellersSection() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.products.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get top 5 products (in real app, filter by sales)
        final bestSellers = provider.products.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'الأكثر مبيعاً',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bestSellers.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(bestSellers[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllProductsSection() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'جميع المنتجات',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: provider.products.length > 10 ? 10 : provider.products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(provider.products[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        // TODO: Navigate to product details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تفاصيل: ${product.name}')),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.images.isNotEmpty ? product.images[0] : '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (product.discount > 0) ...[
                        Text(
                          '${product.price.toStringAsFixed(0)} جنيه',
                          style: AppTextStyles.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${product.finalPrice.toStringAsFixed(0)} جنيه',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
