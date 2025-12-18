// lib/screens/banners/banners_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/models/banner.dart';
import 'package:ecommerce_dashboard/providers/banners_provider.dart';
import 'package:ecommerce_dashboard/screens/banners/add_edit_banner_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final TextEditingController _searchController = TextEditingController();
  BannerType? _selectedType;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<BannersProvider>(context, listen: false).loadBanners(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<BannersProvider>(
      builder: (context, bannersProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(bannersProvider, isDark),
              const SizedBox(height: 24),
              _buildStatsCards(bannersProvider, isDark),
              const SizedBox(height: 24),
              _buildFiltersSection(isDark),
              const SizedBox(height: 24),
              _buildBannersGrid(bannersProvider, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BannersProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إدارة البانرات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'إدارة صور العروض والإعلانات',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddBannerDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة بانر'),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.refresh(),
              tooltip: 'تحديث',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(BannersProvider provider, bool isDark) {
    const int alpha10 = 0x19;

    final stats = [
      {
        'title': 'إجمالي البانرات',
        'value': '${provider.totalBanners}',
        'icon': Icons.image,
        'color': Colors.blue,
      },
      {
        'title': 'البانرات النشطة',
        'value': '${provider.activeBanners}',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'البانرات المعروضة حالياً',
        'value': '${provider.currentlyActiveBanners}',
        'icon': Icons.visibility,
        'color': Colors.purple,
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
                  hintText: 'ابحث عن بانر...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<BannerType?>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع البانر',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('الكل')),
                ...BannerType.values.map((type) {
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

  Widget _buildBannersGrid(BannersProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    var filteredBanners = provider.banners.where((banner) {
      bool matchesSearch =
          _searchController.text.isEmpty ||
          banner.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      bool matchesType = _selectedType == null || banner.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    if (filteredBanners.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: filteredBanners.length,
      itemBuilder: (context, index) {
        final banner = filteredBanners[index];
        return _buildBannerCard(banner, provider, isDark);
      },
    );
  }

  Widget _buildBannerCard(
    BannerModel banner,
    BannersProvider provider,
    bool isDark,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: banner.isCurrentlyActive
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      banner.isCurrentlyActive ? 'نشط' : 'غير نشط',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Order Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#${banner.order}',
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
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.category, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      banner.type.arabicName,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      color: Colors.blue,
                      onPressed: () => _showBannerDetails(context, banner),
                      tooltip: 'عرض',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: Colors.orange,
                      onPressed: () => _showEditBannerDialog(context, banner),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: Icon(
                        banner.isActive ? Icons.toggle_on : Icons.toggle_off,
                        size: 18,
                      ),
                      color: banner.isActive ? Colors.green : Colors.grey,
                      onPressed: () => provider.toggleBannerStatus(banner.id),
                      tooltip: 'تفعيل/إيقاف',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      onPressed: () =>
                          _confirmDelete(context, banner, provider),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ],
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
            Icon(Icons.image_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد بانرات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة بانرات للعروض',
              style: TextStyle(
                color: isDark ? AppColors.darkTextLight : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBannerDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة بانر جديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditBannerDialog(),
    );
  }

  void _showEditBannerDialog(BuildContext context, BannerModel banner) {
    showDialog(
      context: context,
      builder: (context) => AddEditBannerDialog(banner: banner),
    );
  }

  void _showBannerDetails(BuildContext context, BannerModel banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(banner.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            if (banner.description != null) ...[
              Text(
                'الوصف:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(banner.description!),
              const SizedBox(height: 8),
            ],
            Text('النوع: ${banner.type.arabicName}'),
            Text('الترتيب: #${banner.order}'),
            Text('الحالة: ${banner.isActive ? "نشط" : "غير نشط"}'),
            Text(
              'تاريخ الإنشاء: ${DateFormat('dd/MM/yyyy').format(banner.createdAt)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    BannerModel banner,
    BannersProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${banner.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteBanner(banner.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف البانر بنجاح')),
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
