// lib/screens/products/add_edit_product_dialog.dart
import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
import 'package:ecommerce_dashboard/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddEditProductDialog extends StatefulWidget {
  final Product? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _commissionController = TextEditingController();

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedCategory = 'إلكترونيات';
  String _selectedSeller = 'بائع 1';
  bool _isActive = true;
  List<String> _imageUrls = [];
  final List<XFile> _pendingImages = []; // صور جديدة لم يتم رفعها بعد
  bool _isLoading = false;
  bool _isUploadingImages = false;
  int _uploadProgress = 0;
  int _totalImages = 0;

  final _categories = ['إلكترونيات', 'ملابس', 'كتب', 'أثاث', 'أخرى'];
  final _sellers = ['بائع 1', 'بائع 2', 'بائع 3'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _costPriceController.text = widget.product!.costPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _commissionController.text = (widget.product!.commission * 100)
          .toString();
      _selectedCategory = widget.product!.category;
      _selectedSeller = widget.product!.sellerName;
      _isActive = widget.product!.isActive;
      _imageUrls = List.from(widget.product!.images);
    } else {
      _commissionController.text = '10';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 900,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagesSection(),
                      SizedBox(height: 24),
                      _buildBasicInfoSection(),
                      SizedBox(height: 24),
                      _buildPricingSection(),
                      SizedBox(height: 24),
                      _buildSellerSection(),
                      SizedBox(height: 16),
                      if (_priceController.text.isNotEmpty &&
                          _costPriceController.text.isNotEmpty &&
                          _commissionController.text.isNotEmpty)
                        _buildProfitCalculation(),
                      SizedBox(height: 24),
                      _buildStatusSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.product == null ? Icons.add_circle : Icons.edit,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'صور المنتج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              '(حد أقصى 5 صور)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 16),

        // عرض تقدم رفع الصور
        if (_isUploadingImages)
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('جاري رفع الصور... $_uploadProgress من $_totalImages'),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _totalImages > 0 ? _uploadProgress / _totalImages : 0,
                ),
              ],
            ),
          ),

        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // زر إضافة صورة
              if (_imageUrls.length + _pendingImages.length < 5)
                InkWell(
                  onTap: _isUploadingImages ? null : _pickImages,
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'إضافة صورة',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

              // الصور المرفوعة فعلياً
              ..._imageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return _buildImageThumbnail(
                  url: url,
                  index: index,
                  isUploaded: true,
                );
              }),

              // الصور المعلقة (لم يتم رفعها بعد)
              ..._pendingImages.asMap().entries.map((entry) {
                final index = entry.key + _imageUrls.length;
                final xFile = entry.value;
                return _buildPendingImageThumbnail(xFile: xFile, index: index);
              }),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'الصورة الأولى ستكون الصورة الرئيسية. يمكنك اختيار عدة صور في نفس الوقت.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail({
    required String url,
    required int index,
    required bool isUploaded,
  }) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          // زر الحذف
          Positioned(
            top: 8,
            left: 8,
            child: InkWell(
              onTap: () => _removeImage(index, isUploaded),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          // شارة "رئيسية"
          if (index == 0)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'رئيسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingImageThumbnail({
    required XFile xFile,
    required int index,
  }) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<Uint8List>(
              future: xFile.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                }
                return Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          // شارة "جديدة"
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'جديدة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // زر الحذف
          Positioned(
            top: 8,
            left: 8,
            child: InkWell(
              onTap: () => _removePendingImage(index - _imageUrls.length),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المعلومات الأساسية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المنتج *',
                  hintText: 'أدخل اسم المنتج',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المنتج';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'الفئة *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'الوصف',
            hintText: 'أدخل وصف المنتج',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التسعير والمخزون',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'سعر البيع *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'جنيه',
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال السعر';
                  }
                  if (double.tryParse(value) == null) {
                    return 'سعر غير صحيح';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _costPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'سعر التكلفة',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.money_off),
                  suffixText: 'جنيه',
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'المخزون *',
                  hintText: '0',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الكمية';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البائع والعمولة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSeller,
                decoration: InputDecoration(
                  labelText: 'البائع *',
                  prefixIcon: Icon(Icons.person),
                ),
                items: _sellers.map((seller) {
                  return DropdownMenuItem(value: seller, child: Text(seller));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSeller = value!);
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _commissionController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'نسبة العمولة *',
                  hintText: '10',
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                  helperText: 'نسبة عمولتك من سعر البيع',
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال النسبة';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0 || num > 100) {
                    return 'نسبة غير صحيحة (0-100)';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitCalculation() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0;
    final commission = double.tryParse(_commissionController.text) ?? 0;

    final profit = price - costPrice;
    final commissionAmount = price * (commission / 100);
    final netProfit = profit - commissionAmount;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حساب الأرباح',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _profitItem('الربح الإجمالي', profit, Colors.green),
              ),
              Expanded(
                child: _profitItem('عمولتك', commissionAmount, Colors.blue),
              ),
              Expanded(
                child: _profitItem('صافي ربح البائع', netProfit, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profitItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ج',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return SwitchListTile(
      title: Text('المنتج نشط'),
      subtitle: Text('هل تريد عرض المنتج في المتجر؟'),
      value: _isActive,
      onChanged: (value) {
        setState(() => _isActive = value);
      },
      activeThumbColor: Colors.green,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isLoading || _isUploadingImages ? null : _saveProduct,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.save),
            label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== الدوال المساعدة ====================

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();

      if (images.isEmpty) return;

      // التحقق من عدد الصور
      final totalImages =
          _imageUrls.length + _pendingImages.length + images.length;
      if (totalImages > 5) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('يمكنك إضافة 5 صور كحد أقصى')));

        // أخذ الصور المسموح بها فقط
        final allowedCount = 5 - (_imageUrls.length + _pendingImages.length);
        if (allowedCount > 0) {
          setState(() {
            _pendingImages.addAll(images.take(allowedCount));
          });
        }
        return;
      }

      setState(() {
        _pendingImages.addAll(images);
      });
    } catch (e) {
      debugPrint('خطأ في اختيار الصور: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ في اختيار الصور')));
    }
  }

  void _removeImage(int index, bool isUploaded) async {
    setState(() {
      if (isUploaded && index < _imageUrls.length) {
        final removedUrl = _imageUrls[index];
        _imageUrls.removeAt(index);

        // حذف الصورة من Storage (فقط لو من Firebase)
        if (removedUrl.contains('firebase') ||
            removedUrl.contains('googleapis')) {
          _cloudinaryService.deleteImage(removedUrl).then((success) {
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حذف الصورة من القائمة ولكن حدث خطأ في حذفها من Storage',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });
        }
      }
    });
  }

  void _removePendingImage(int index) {
    setState(() {
      _pendingImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    // 1. التحقق من صحة الحقول الأساسية في النموذج
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. التحقق من وجود صورة واحدة على الأقل للمنتج
    if (_imageUrls.isEmpty && _pendingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة صورة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // إنشاء معرف فريد للمنتج إذا كان جديداً
      final productId =
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // 3. رفع الصور الجديدة (المعلقة) إلى Cloudinary
      if (_pendingImages.isNotEmpty) {
        setState(() {
          _isUploadingImages = true;
          _totalImages = _pendingImages.length;
          _uploadProgress = 0;
        });

        // استخدام خدمة Cloudinary للرفع بدلاً من Firebase Storage
        final uploadedUrls = await _cloudinaryService.uploadMultipleImages(
          imageFiles: _pendingImages,
          folder: 'products/$productId',
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = current;
            });
          },
        );

        // إضافة الروابط الجديدة للقائمة ومسح الصور المعلقة بعد الرفع
        _imageUrls.addAll(uploadedUrls);
        _pendingImages.clear();

        setState(() {
          _isUploadingImages = false;
        });
      }

      // 4. تجهيز بيانات المنتج النهائية للحفظ
      final product = Product(
        id: productId,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        costPrice: double.parse(_costPriceController.text),
        category: _selectedCategory,
        images: _imageUrls,
        stock: int.parse(_stockController.text),
        soldCount: widget.product?.soldCount ?? 0,
        sellerId: 'seller_123',
        sellerName: _selectedSeller,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        isActive: _isActive,
        commission: double.parse(_commissionController.text) / 100,
      );

      final provider = Provider.of<ProductsProvider>(context, listen: false);

      // 5. حفظ المنتج في Firestore (إضافة أو تحديث)
      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }

      // 6. إغلاق الحوار وإظهار رسالة نجاح
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'تم إضافة المنتج بنجاح'
                  : 'تم تحديث المنتج بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // معالجة الأخطاء وإظهارها للمستخدم
      debugPrint('❌ خطأ في حفظ المنتج: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // إعادة حالة التحميل لوضعها الطبيعي
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImages = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _commissionController.dispose();
    super.dispose();
  }
}
