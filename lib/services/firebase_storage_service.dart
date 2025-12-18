// lib/services/firebase_storage_service.dart
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// رفع صورة واحدة إلى Firebase Storage
  /// يرجع رابط الصورة بعد الرفع
  Future<String?> uploadProductImage({
    required XFile imageFile,
    required String productId,
  }) async {
    try {
      // قراءة بيانات الصورة
      final Uint8List imageData = await imageFile.readAsBytes();

      // إنشاء مسار فريد للصورة
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final String path = 'products/$productId/$fileName';

      // رفع الصورة
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // انتظار اكتمال الرفع
      final TaskSnapshot snapshot = await uploadTask;

      // الحصول على رابط التحميل
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ تم رفع الصورة بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ خطأ في رفع الصورة: $e');
      return null;
    }
  }

  /// رفع عدة صور دفعة واحدة
  /// يرجع قائمة بروابط الصور
  Future<List<String>> uploadMultipleImages({
    required List<XFile> imageFiles,
    required String productId,
    Function(int current, int total)? onProgress,
  }) async {
    List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadProductImage(
        imageFile: imageFiles[i],
        productId: productId,
      );

      if (url != null) {
        uploadedUrls.add(url);
      }

      // تحديث التقدم
      if (onProgress != null) {
        onProgress(i + 1, imageFiles.length);
      }
    }

    return uploadedUrls;
  }

  /// حذف صورة من Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // التحقق من أن الرابط من Firebase Storage
      if (!imageUrl.contains('firebase') && !imageUrl.contains('googleapis')) {
        debugPrint('⚠️ الصورة ليست من Firebase Storage، تم تجاهل الحذف');
        return true; // نرجع true لأن الصورة أصلاً placeholder
      }

      // استخراج المسار من الرابط
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      debugPrint('✅ تم حذف الصورة بنجاح');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف الصورة: $e');
      return false;
    }
  }

  /// حذف جميع صور منتج معين
  Future<bool> deleteProductImages(String productId) async {
    try {
      final Reference folderRef = _storage.ref().child('products/$productId');

      // الحصول على جميع الملفات في المجلد
      final ListResult result = await folderRef.listAll();

      // حذف كل الصور
      for (var fileRef in result.items) {
        await fileRef.delete();
      }

      debugPrint('✅ تم حذف جميع صور المنتج بنجاح');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف صور المنتج: $e');
      return false;
    }
  }

  /// رفع صورة بانر
  Future<String?> uploadBannerImage({
    required XFile imageFile,
    required String bannerId,
  }) async {
    try {
      final Uint8List imageData = await imageFile.readAsBytes();
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final String path = 'banners/$bannerId/$fileName';

      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ تم رفع صورة البانر بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ خطأ في رفع صورة البانر: $e');
      return null;
    }
  }

  /// الحصول على حجم الصورة
  Future<int?> getImageSize(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      debugPrint('❌ خطأ في الحصول على حجم الصورة: $e');
      return null;
    }
  }

  /// ضغط الصورة قبل الرفع (اختياري)
  Future<Uint8List> compressImage(Uint8List imageData) async {
    // TODO: يمكن إضافة مكتبة لضغط الصور مثل flutter_image_compress
    // حالياً نرجع الصورة كما هي
    return imageData;
  }
}
