// lib/screens/banners/add_edit_banner_dialog.dart
import 'dart:typed_data';

import 'package:ecommerce_dashboard/models/banner.dart';
import 'package:ecommerce_dashboard/providers/banners_provider.dart';
import 'package:ecommerce_dashboard/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddEditBannerDialog extends StatefulWidget {
  final BannerModel? banner;

  const AddEditBannerDialog({super.key, this.banner});

  @override
  State<AddEditBannerDialog> createState() => _AddEditBannerDialogState();
}

class _AddEditBannerDialogState extends State<AddEditBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetIdController = TextEditingController();
  final _orderController = TextEditingController();

  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  BannerType _selectedType = BannerType.general;
  bool _isActive = true;
  String? _imageUrl;
  XFile? _pendingImage;
  Uint8List? _imagePreview;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _titleController.text = widget.banner!.title;
      _descriptionController.text = widget.banner!.description ?? '';
      _targetIdController.text = widget.banner!.targetId ?? '';
      _orderController.text = widget.banner!.order.toString();
      _selectedType = widget.banner!.type;
      _isActive = widget.banner!.isActive;
      _imageUrl = widget.banner!.imageUrl;
      _startDate = widget.banner!.startDate;
      _endDate = widget.banner!.endDate;
    } else {
      _orderController.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.85,
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
                      _buildImageSection(),
                      SizedBox(height: 24),
                      _buildBasicInfoSection(),
                      SizedBox(height: 24),
                      _buildTypeAndTargetSection(),
                      SizedBox(height: 24),
                      _buildScheduleSection(),
                      SizedBox(height: 24),
                      _buildOrderAndStatusSection(),
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
        color: Colors.purple,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.banner == null ? Icons.add_photo_alternate : Icons.edit,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            widget.banner == null ? 'إضافة بانر جديد' : 'تعديل البانر',
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'صورة البانر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              '(مطلوبة)',
              style: TextStyle(fontSize: 12, color: Colors.red[600]),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'يُفضل استخدام صورة بأبعاد 1200x400 بكسل للحصول على أفضل نتيجة',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),

        // عرض تقدم رفع الصورة
        if (_isUploadingImage)
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('جاري رفع الصورة...'),
              ],
            ),
          ),

        // معاينة الصورة
        if (_imageUrl != null || _imagePreview != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imagePreview != null
                      ? Image.memory(
                          _imagePreview!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image, size: 60),
                            );
                          },
                        ),
                ),
                // زر الحذف
                Positioned(
                  top: 8,
                  left: 8,
                  child: InkWell(
                    onTap: _removeImage,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                // زر تغيير الصورة
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: _isUploadingImage ? null : _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // زر اختيار صورة
          InkWell(
            onTap: _isUploadingImage ? null : _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
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
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'اضغط لاختيار صورة',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'عنوان البانر *',
            hintText: 'مثال: عرض خاص على اللابتوبات',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال عنوان البانر';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'الوصف (اختياري)',
            hintText: 'وصف مختصر للعرض',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeAndTargetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع البانر والهدف',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<BannerType>(
          initialValue: _selectedType,
          decoration: InputDecoration(
            labelText: 'نوع البانر',
            prefixIcon: Icon(Icons.category),
          ),
          items: BannerType.values.map((type) {
            return DropdownMenuItem(value: type, child: Text(type.arabicName));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              if (_selectedType == BannerType.general) {
                _targetIdController.clear();
              }
            });
          },
        ),
        SizedBox(height: 16),
        if (_selectedType != BannerType.general)
          TextFormField(
            controller: _targetIdController,
            decoration: InputDecoration(
              labelText: _getTargetLabel(),
              hintText: _getTargetHint(),
              prefixIcon: Icon(Icons.link),
              helperText: _getTargetHelperText(),
            ),
            validator: (value) {
              if (_selectedType != BannerType.general &&
                  (value == null || value.isEmpty)) {
                return 'الرجاء إدخال ${_getTargetLabel()}';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'جدولة العرض (اختياري)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'حدد موعد بداية ونهاية عرض البانر',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStartDate: true),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ البداية',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'اختر التاريخ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _startDate != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_startDate != null)
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() => _startDate = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStartDate: false),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ النهاية',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'اختر التاريخ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _endDate != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_endDate != null)
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() => _endDate = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderAndStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الترتيب والحالة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _orderController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ترتيب العرض',
            hintText: '1',
            prefixIcon: Icon(Icons.reorder),
            helperText: 'البانرات ذات الترتيب الأقل تظهر أولاً',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال ترتيب العرض';
            }
            if (int.tryParse(value) == null) {
              return 'الرجاء إدخال رقم صحيح';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('البانر نشط'),
          subtitle: Text('هل تريد عرض هذا البانر في التطبيق؟'),
          value: _isActive,
          onChanged: (value) {
            setState(() => _isActive = value);
          },
          activeThumbColor: Colors.green,
        ),
      ],
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
            onPressed: _isLoading || _isUploadingImage ? null : _saveBanner,
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
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== الدوال المساعدة ====================

  String _getTargetLabel() {
    switch (_selectedType) {
      case BannerType.product:
        return 'معرّف المنتج';
      case BannerType.category:
        return 'اسم الفئة';
      case BannerType.url:
        return 'الرابط';
      default:
        return 'الهدف';
    }
  }

  String _getTargetHint() {
    switch (_selectedType) {
      case BannerType.product:
        return 'مثال: 1234567890';
      case BannerType.category:
        return 'مثال: إلكترونيات';
      case BannerType.url:
        return 'مثال: https://example.com';
      default:
        return '';
    }
  }

  String _getTargetHelperText() {
    switch (_selectedType) {
      case BannerType.product:
        return 'معرّف المنتج الذي سيتم فتحه عند الضغط';
      case BannerType.category:
        return 'اسم الفئة التي سيتم عرضها عند الضغط';
      case BannerType.url:
        return 'الرابط الذي سيتم فتحه عند الضغط';
      default:
        return '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pendingImage = image;
          _imagePreview = bytes;
          _imageUrl = null; // مسح الصورة القديمة
        });
      }
    } catch (e) {
      debugPrint('خطأ في اختيار الصورة: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ في اختيار الصورة')));
    }
  }

  void _removeImage() {
    setState(() {
      _imageUrl = null;
      _imagePreview = null;
      _pendingImage = null;
    });
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageUrl == null && _imagePreview == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('الرجاء اختيار صورة للبانر')));
      return;
    }

    // التحقق من التواريخ
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تاريخ النهاية يجب أن يكون بعد تاريخ البداية'),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final bannerId =
          widget.banner?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      String finalImageUrl = _imageUrl ?? '';

      // رفع الصورة إذا كانت جديدة
      if (_pendingImage != null) {
        setState(() => _isUploadingImage = true);

        final uploadedUrl = await _storageService.uploadBannerImage(
          imageFile: _pendingImage!,
          bannerId: bannerId,
        );

        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;

          // حذف الصورة القديمة إذا كانت موجودة
          if (widget.banner != null && widget.banner!.imageUrl.isNotEmpty) {
            if (widget.banner!.imageUrl.contains('firebase') ||
                widget.banner!.imageUrl.contains('googleapis')) {
              await _storageService.deleteImage(widget.banner!.imageUrl);
            }
          }
        } else {
          throw Exception('فشل رفع الصورة');
        }

        setState(() => _isUploadingImage = false);
      }

      // إنشاء/تحديث البانر
      final banner = BannerModel(
        id: bannerId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        imageUrl: finalImageUrl,
        type: _selectedType,
        targetId: _targetIdController.text.isEmpty
            ? null
            : _targetIdController.text,
        order: int.parse(_orderController.text),
        isActive: _isActive,
        createdAt: widget.banner?.createdAt ?? DateTime.now(),
        startDate: _startDate,
        endDate: _endDate,
      );

      final provider = Provider.of<BannersProvider>(context, listen: false);

      if (widget.banner == null) {
        await provider.addBanner(banner);
      } else {
        await provider.updateBanner(banner);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.banner == null
                ? 'تم إضافة البانر بنجاح'
                : 'تم تحديث البانر بنجاح',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('خطأ في حفظ البانر: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isUploadingImage = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetIdController.dispose();
    _orderController.dispose();
    super.dispose();
  }
}
