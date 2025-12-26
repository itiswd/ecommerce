// lib/customer/screens/search/customer_search_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/config/customer_routes.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/comparison_provider.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Product> _searchResults = [];
  bool _isSearching = false;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // تركيز البحث عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // TODO: تحميل من SharedPreferences
    _recentSearches = ['ماكينة صناعي', 'Jack', 'قطع غيار'];
  }

  void _saveRecentSearch(String query) {
    if (query.isEmpty || _recentSearches.contains(query)) return;
    setState(() {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    // TODO: حفظ في SharedPreferences
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final products = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).products;
    final results = products.where((product) {
      final searchLower = query.toLowerCase();
      return product.name.toLowerCase().contains(searchLower) ||
          product.description.toLowerCase().contains(searchLower) ||
          product.category.toLowerCase().contains(searchLower) ||
          product.sellerName.toLowerCase().contains(searchLower) ||
          product.specifications.values.any(
            (v) => v.toLowerCase().contains(searchLower),
          );
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onChanged: _performSearch,
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              _saveRecentSearch(query);
              _performSearch(query);
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _saveRecentSearch(_searchController.text);
                _performSearch(_searchController.text);
              },
              child: const Text('بحث'),
            ),
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    // عرض نتائج البحث
    if (_searchController.text.isNotEmpty) {
      if (_isSearching) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'لا توجد نتائج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'جرب كلمات بحث مختلفة',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return _buildSearchResults();
    }

    // عرض عمليات البحث الأخيرة
    return _buildRecentSearches(colorScheme);
  }

  Widget _buildRecentSearches(ColorScheme colorScheme) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('ابحث عن الماكينات وقطع الغيار'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'عمليات البحث الأخيرة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: const Text('مسح'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                avatar: const Icon(Icons.history, size: 18),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            'اقتراحات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'ماكينات صناعي',
                  'ماكينات منزلي',
                  'قطع غيار',
                  'Jack',
                  'Juki',
                  'Brother',
                ].map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _searchController.text = suggestion;
                      _performSearch(suggestion);
                    },
                    backgroundColor: colorScheme.primaryContainer,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildProductSearchItem(product);
      },
    );
  }

  Widget _buildProductSearchItem(Product product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            CustomerRoutes.productDetails,
            arguments: product,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // صورة المنتج
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.images.isNotEmpty ? product.images[0] : '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // معلومات المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} جنيه',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            product.originalPrice!.toStringAsFixed(0),
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // أزرار
              Column(
                children: [
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          cart.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تمت الإضافة للسلة')),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<ComparisonProvider>(
                    builder: (context, comparison, _) {
                      final isInComparison = comparison.contains(product.id);
                      return IconButton(
                        icon: Icon(
                          Icons.compare_arrows,
                          color: isInComparison ? Colors.orange : null,
                        ),
                        onPressed: () {
                          if (isInComparison) {
                            comparison.removeProduct(product.id);
                          } else {
                            comparison.addProduct(product);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
