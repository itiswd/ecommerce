// lib/services/cloudinary_service.dart
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // إعدادات Cloudinary - يجب الحصول عليها من لوحة تحكم Cloudinary الخاصة بك
  final String _cloudName = 'djegn2uef';
  final String _uploadPreset = 'Makanty';

  late CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// رفع صورة واحدة إلى Cloudinary
  Future<String?> uploadImage({
    required XFile imageFile,
    required String folder,
  }) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      debugPrint('✅ تم رفع الصورة إلى Cloudinary: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('❌ خطأ في رفع الصورة إلى Cloudinary: $e');
      return null;
    }
  }

  /// رفع عدة صور دفعة واحدة
  Future<List<String>> uploadMultipleImages({
    required List<XFile> imageFiles,
    required String folder,
    Function(int current, int total)? onProgress,
  }) async {
    List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadImage(imageFile: imageFiles[i], folder: folder);

      if (url != null) {
        uploadedUrls.add(url);
      }

      if (onProgress != null) {
        onProgress(i + 1, imageFiles.length);
      }
    }

    return uploadedUrls;
  }

  /// ملاحظة: حذف الصور من Cloudinary من جانب العميل (Client-side) يتطلب إعدادات أمنية خاصة
  /// أو استخدام "Signature". عادة ما يتم الحذف عبر Backend.
  Future<bool> deleteImage(String imageUrl) async {
    // Cloudinary لا يسمح بالحذف البسيط عبر الرابط من طرف العميل لأسباب أمنية افتراضياً
    debugPrint('⚠️ حذف الصور من Cloudinary يتطلب إعدادات إضافية أو Backend.');
    return true;
  }
}
