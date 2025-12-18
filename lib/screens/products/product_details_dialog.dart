import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Product product;

  const ProductDetailsDialog({super.key, required this.product});

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1000,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images Gallery
                  Expanded(flex: 2, child: _buildImageGallery()),

                  // Product Info
                  Expanded(flex: 3, child: _buildProductInfo()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'رقم المنتج: ${widget.product.id}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.product.isActive
                  ? Colors.green.withAlpha(26)
                  : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  widget.product.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: widget.product.isActive ? Colors.green : Colors.red,
                ),
                SizedBox(width: 6),
                Text(
                  widget.product.isActive ? 'نشط' : 'غير نشط',
                  style: TextStyle(
                    color: widget.product.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      padding: EdgeInsets.all(24),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Main Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.product.images[_selectedImageIndex],
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.broken_image, size: 80)),
                      )
                    : Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Thumbnail Images
          if (widget.product.images.length > 1)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.images.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedImageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedImageIndex = index);
                    },
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Section
          _buildSection(
            'السعر والمخزون',
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'سعر البيع',
                    '${NumberFormat('#,##0').format(widget.product.price)} جنيه',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'سعر التكلفة',
                    '${NumberFormat('#,##0').format(widget.product.costPrice)} جنيه',
                    Icons.money_off,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'المخزون',
                    '${widget.product.stock}',
                    Icons.inventory,
                    widget.product.stock == 0
                        ? Colors.red
                        : widget.product.stock < 10
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Sales & Commission
          _buildSection(
            'المبيعات والعمولة',
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'المبيعات',
                    '${widget.product.soldCount}',
                    Icons.shopping_cart,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'نسبة العمولة',
                    '${(widget.product.commission * 100).toInt()}%',
                    Icons.percent,
                    Colors.purple,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'إجمالي العمولة',
                    '${NumberFormat('#,##0').format(widget.product.totalCommission)} ج',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Category & Seller
          _buildSection(
            'التفاصيل',
            Column(
              children: [
                _buildDetailRow(
                  'الفئة',
                  widget.product.category,
                  Icons.category,
                ),
                _buildDetailRow(
                  'البائع',
                  widget.product.sellerName,
                  Icons.person,
                ),
                _buildDetailRow(
                  'تاريخ الإضافة',
                  DateFormat(
                    'dd/MM/yyyy - hh:mm a',
                    'ar',
                  ).format(widget.product.createdAt),
                  Icons.calendar_today,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Description
          _buildSection(
            'الوصف',
            Text(
              widget.product.description.isNotEmpty
                  ? widget.product.description
                  : 'لا يوجد وصف',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),

          SizedBox(height: 24),

          // Profit Calculation
          _buildSection(
            'حساب الأرباح (لكل وحدة)',
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(51)),
              ),
              child: Column(
                children: [
                  _buildProfitRow(
                    'سعر البيع',
                    widget.product.price,
                    Colors.grey[800]!,
                  ),
                  Divider(),
                  _buildProfitRow(
                    'سعر التكلفة',
                    -widget.product.costPrice,
                    Colors.red,
                  ),
                  Divider(),
                  _buildProfitRow(
                    'الربح الإجمالي',
                    widget.product.price - widget.product.costPrice,
                    Colors.green,
                    isBold: true,
                  ),
                  Divider(),
                  _buildProfitRow(
                    'عمولتك (${(widget.product.commission * 100).toInt()}%)',
                    -(widget.product.price * widget.product.commission),
                    Colors.blue,
                  ),
                  Divider(),
                  _buildProfitRow(
                    'صافي ربح البائع',
                    (widget.product.price - widget.product.costPrice) -
                        (widget.product.price * widget.product.commission),
                    Colors.orange,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Performance Stats
          if (widget.product.soldCount > 0)
            _buildSection(
              'الأداء',
              Column(
                children: [
                  _buildPerformanceCard(
                    'إجمالي الإيرادات',
                    '${NumberFormat('#,##0').format(widget.product.price * widget.product.soldCount)} جنيه',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                  SizedBox(height: 12),
                  _buildPerformanceCard(
                    'إجمالي الأرباح',
                    '${NumberFormat('#,##0').format(widget.product.profit)} جنيه',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                  SizedBox(height: 12),
                  _buildPerformanceCard(
                    'عمولتك الإجمالية',
                    '${NumberFormat('#,##0').format(widget.product.totalCommission)} جنيه',
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${amount >= 0 ? '' : ''}${NumberFormat('#,##0.00').format(amount.abs())} ج',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
