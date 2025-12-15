import 'package:ecommerce_dashboard/models/product.dart';
import 'package:ecommerce_dashboard/providers/products_provider.dart';
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

  String _selectedCategory = 'إلكترونيات';
  String _selectedSeller = 'بائع 1';
  bool _isActive = true;
  List<String> _imageUrls = [];
  bool _isLoading = false;

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
            // Header
            Container(
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
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images Section
                      _buildImagesSection(),
                      SizedBox(height: 24),

                      // Basic Info
                      Text(
                        'المعلومات الأساسية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
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
                      SizedBox(height: 24),

                      // Pricing & Stock
                      Text(
                        'التسعير والمخزون',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'سعر البيع *',
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.attach_money),
                                suffixText: 'جنيه',
                              ),
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
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'سعر التكلفة',
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.money_off),
                                suffixText: 'جنيه',
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                      SizedBox(height: 24),

                      // Seller & Commission
                      Text(
                        'البائع والعمولة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                                return DropdownMenuItem(
                                  value: seller,
                                  child: Text(seller),
                                );
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
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'نسبة العمولة *',
                                hintText: '10',
                                prefixIcon: Icon(Icons.percent),
                                suffixText: '%',
                                helperText: 'نسبة عمولتك من سعر البيع',
                              ),
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
                      SizedBox(height: 16),

                      // Profit Calculation
                      if (_priceController.text.isNotEmpty &&
                          _costPriceController.text.isNotEmpty &&
                          _commissionController.text.isNotEmpty)
                        _buildProfitCalculation(),

                      SizedBox(height: 24),

                      // Status
                      SwitchListTile(
                        title: Text('المنتج نشط'),
                        subtitle: Text('هل تريد عرض المنتج في المتجر؟'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
                        },
                        activeThumbColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
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
                    onPressed: _isLoading ? null : _saveProduct,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صور المنتج',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add Image Button
              InkWell(
                onTap: _pickImage,
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

              // Existing Images
              ..._imageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
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
                      Positioned(
                        top: 8,
                        left: 8,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _imageUrls.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
              }),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'يمكنك إضافة حتى 5 صور. الصورة الأولى ستكون الصورة الرئيسية.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
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

  Future<void> _pickImage() async {
    if (_imageUrls.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يمكنك إضافة 5 صور كحد أقصى')));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // في التطبيق الحقيقي، ارفع الصورة إلى Firebase Storage وخذ الرابط
      setState(() {
        _imageUrls.add('https://via.placeholder.com/300'); // مؤقت
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إضافة صورة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id:
            widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
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

      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
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
