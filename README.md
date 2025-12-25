# 🛍️ مكنتي - Makanty E-Commerce Platform

منصة تجارة إلكترونية متكاملة لبيع ماكينات الخياطة وقطع الغيار مع نظام كاش باك وإدارة كاملة.

## 📱 المكونات

### 1. تطبيق العملاء (Customer Mobile App)
- تطبيق Flutter للأندرويد و iOS
- تصفح المنتجات والأقسام
- نظام المقارنة بين المنتجات
- سلة التسوق والشراء
- نظام الكاش باك (5% من كل عملية شراء)
- تسجيل الدخول برقم الهاتف (OTP)
- وضع الزائر للتصفح بدون تسجيل

### 2. لوحة تحكم الأدمن (Admin Dashboard)
- لوحة تحكم ويب لإدارة المتجر
- إدارة المنتجات (إضافة، تعديل، حذف)
- إدارة الطلبات وتغيير حالاتها
- إدارة البانرات الإعلانية
- إدارة الكاش باك
- إحصائيات ومبيعات

## 🚀 التقنيات المستخدمة

- **Flutter** - للواجهات
- **Firebase Authentication** - Phone Auth & Email/Password
- **Cloud Firestore** - قاعدة البيانات
- **Cloudinary** - لتخزين الصور
- **Provider** - لإدارة الحالة
- **Material Design 3** - للتصميم

## ⚙️ الإعداد والتشغيل

### المتطلبات الأساسية
- Flutter SDK (3.10.4+)
- Android Studio / VS Code
- حساب Firebase
- حساب Cloudinary

### 1. تثبيت المشروع

```bash
# استنساخ المشروع
git clone https://github.com/itiswd/ecommerce.git
cd ecommerce

# تثبيت الحزم
flutter pub get
```

### 2. إعداد Firebase

#### أ. إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. أنشئ مشروع جديد
3. أضف تطبيق Android و iOS
4. حمّل ملفات التكوين:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

#### ب. تفعيل الخدمات

**Firebase Authentication:**
- فعّل Phone Authentication
- أضف أرقام اختبار للتطوير:
  ```
  +20 1234567890 → OTP: 123456
  +20 1098765432 → OTP: 123456
  ```
- فعّل Email/Password للأدمن

**Cloud Firestore:**
- أنشئ قاعدة بيانات في وضع Test Mode
- طبّق القواعد الأمنية (انظر `firestore.rules` أدناه)

**Firebase Storage (اختياري):**
- للصور الشخصية للمستخدمين

#### ج. إنشاء Collections

قم بإنشاء Collections التالية في Firestore:
- `users` - بيانات العملاء
- `admin_users` - بيانات الأدمن
- `products` - المنتجات
- `orders` - الطلبات
- `banners` - البانرات الإعلانية
- `cashback_transactions` - معاملات الكاش باك

### 3. إعداد Cloudinary

1. أنشئ حساب على [Cloudinary](https://cloudinary.com/)
2. احصل على:
   - Cloud Name
   - Upload Preset (اجعله unsigned)
3. حدّث الإعدادات في:
   - `lib/services/cloudinary_service.dart`

### 4. قواعد Firestore الأمنية

أنشئ ملف `firestore.rules` في مجلد المشروع:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return exists(/databases/$(database)/documents/admin_users/$(request.auth.uid));
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin users collection
    match /admin_users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // يتم إنشاؤهم من Console فقط
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if true; // الجميع يقرأ
      allow write: if request.auth != null && isAdmin();
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null && 
                     (resource.data.customerId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if request.auth != null && isAdmin();
    }
    
    // Banners collection
    match /banners/{bannerId} {
      allow read: if true;
      allow write: if request.auth != null && isAdmin();
    }
    
    // Cashback transactions
    match /cashback_transactions/{transactionId} {
      allow read: if request.auth != null && 
                     (resource.data.customerId == request.auth.uid || isAdmin());
      allow write: if request.auth != null && isAdmin();
    }
  }
}
```

نشر القواعد:
```bash
firebase deploy --only firestore:rules
```

### 5. إنشاء مستخدم Admin

في Firebase Console → Authentication:
1. أضف مستخدم جديد بالبريد الإلكتروني:
   - Email: `admin@makanty.com`
   - Password: `Admin@123456`
2. انسخ UID المستخدم
3. في Firestore، أنشئ document في `admin_users` مع UID:
   ```json
   {
     "uid": "USER_UID_HERE",
     "email": "admin@makanty.com",
     "displayName": "المدير",
     "role": "super_admin",
     "permissions": ["all"],
     "createdAt": "TIMESTAMP",
     "lastLogin": "TIMESTAMP"
   }
   ```

### 6. تشغيل التطبيقات

#### تطبيق العملاء (Customer App)
```bash
flutter run -t lib/customer_main.dart
```

أو للتشغيل على جهاز معين:
```bash
flutter run -t lib/customer_main.dart -d [device_id]
```

#### لوحة التحكم (Admin Dashboard)
```bash
flutter run -t lib/main.dart
```

أو للويب:
```bash
flutter run -t lib/main.dart -d chrome
```

### 7. بناء APK للإنتاج

```bash
# Customer App
flutter build apk --release -t lib/customer_main.dart

# الملف الناتج في:
# build/app/outputs/flutter-apk/app-release.apk
```

## 📊 هيكل المشروع

```
lib/
├── config/                    # الإعدادات والثوابت
│   ├── customer_constants.dart
│   └── customer_routes.dart
├── constants/                 # الثوابت المشتركة
│   └── app_theme.dart
├── models/                    # نماذج البيانات
│   ├── user.dart
│   ├── product.dart
│   ├── order.dart
│   ├── cart_item.dart
│   ├── address.dart
│   ├── banner.dart
│   ├── cashback.dart
│   └── comparison.dart
├── services/                  # الخدمات
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── cloudinary_service.dart
├── providers/                 # إدارة الحالة
│   ├── customer_auth_provider.dart
│   ├── cart_provider.dart
│   ├── comparison_provider.dart
│   ├── products_provider.dart
│   ├── orders_provider.dart
│   ├── banners_provider.dart
│   ├── cashback_provider.dart
│   └── theme_provider.dart
├── customer/                  # تطبيق العملاء
│   └── screens/
│       ├── auth/
│       ├── home/
│       ├── cart/
│       ├── comparison/
│       └── profile/
├── screens/                   # لوحة تحكم الأدمن
│   ├── products/
│   ├── orders/
│   ├── banners/
│   ├── cashback/
│   ├── reports/
│   └── settings/
├── customer_main.dart         # نقطة دخول تطبيق العملاء
└── main.dart                  # نقطة دخول لوحة التحكم
```

## 🎯 الميزات الرئيسية

### تطبيق العملاء

#### ✅ المنفذ
- [x] تسجيل الدخول برقم الهاتف + OTP
- [x] وضع الزائر للتصفح
- [x] عرض المنتجات مع بانرات وأقسام
- [x] إضافة للسلة مع إدارة الكميات
- [x] عرض السلة والإجماليات
- [x] حظر الشراء للزوار
- [x] الملف الشخصي مع عرض الكاش باك

#### 🔄 قيد التطوير
- [ ] تفاصيل المنتج الكاملة
- [ ] صفحة الشراء (Checkout)
- [ ] اختيار/إضافة عنوان التوصيل
- [ ] استخدام الكاش باك في الطلب
- [ ] تأكيد الطلب
- [ ] عرض الطلبات السابقة
- [ ] المقارنة بين المنتجات (UI)
- [ ] البحث والفلاتر

### لوحة تحكم الأدمن

#### ✅ المنفذ
- [x] تسجيل الدخول Demo Mode
- [x] عرض المنتجات من Firestore
- [x] عرض الطلبات
- [x] عرض البانرات
- [x] عرض إحصائيات

#### 🔄 قيد التطوير
- [ ] تسجيل دخول حقيقي بالبريد
- [ ] إضافة/تعديل منتج مع رفع صور
- [ ] إدارة حالات الطلبات
- [ ] تفعيل الكاش باك عند التوصيل
- [ ] إضافة/تعديل بانر
- [ ] إدارة الكاش باك (يدوي)
- [ ] إحصائيات حقيقية من Firebase

## 💾 البيانات التجريبية

### بيانات الاختبار

#### أرقام هواتف للاختبار (Customer App)
```
+20 1234567890 → OTP: 123456
+20 1098765432 → OTP: 123456
```

#### حساب الأدمن (Admin Dashboard)
```
Email: admin@makanty.com
Password: Admin@123456
```

### إضافة منتجات تجريبية

يمكنك إضافة منتجات يدوياً من Firebase Console أو من لوحة التحكم. مثال على منتج:

```json
{
  "id": "prod_001",
  "name": "ماكينة خياطة جاك صناعي A5",
  "nameEn": "Jack Industrial A5 Sewing Machine",
  "description": "ماكينة خياطة صناعية عالية الأداء",
  "category": "ماكينات صناعي",
  "brand": "Jack",
  "condition": "جديد",
  "price": 15000,
  "discount": 10,
  "finalPrice": 13500,
  "images": [
    "https://example.com/image1.jpg"
  ],
  "specifications": {
    "السرعة": "5000 غرزة/دقيقة",
    "القدرة": "550 واط",
    "الوزن": "35 كجم"
  },
  "isActive": true,
  "stock": 10,
  "sold": 0,
  "rating": 4.5,
  "reviewsCount": 12,
  "createdAt": "TIMESTAMP",
  "updatedAt": "TIMESTAMP"
}
```

## 🧪 الاختبار

### اختبار رحلة العميل الكاملة

1. ✅ فتح التطبيق → Splash → Onboarding (أول مرة)
2. ✅ التصفح كزائر
3. ✅ عرض المنتجات والبانرات
4. ✅ إضافة منتجات للسلة
5. ✅ عرض السلة وتعديل الكميات
6. ✅ محاولة الشراء → طلب تسجيل دخول
7. ✅ تسجيل دخول برقم هاتف + OTP
8. ⏳ اختيار عنوان التوصيل
9. ⏳ مراجعة الطلب وتأكيده
10. ⏳ عرض الطلبات السابقة

### اختبار رحلة الأدمن

1. ⏳ تسجيل دخول بحساب Admin
2. ✅ عرض الإحصائيات
3. ✅ عرض المنتجات
4. ⏳ إضافة منتج جديد
5. ⏳ عرض الطلبات
6. ⏳ تغيير حالة طلب
7. ⏳ تفعيل كاش باك عند التوصيل

## 🔧 حل المشاكل

### مشكلة: Firebase لا يعمل
```bash
# تأكد من تثبيت flutterfire CLI
dart pub global activate flutterfire_cli

# إعادة تكوين Firebase
flutterfire configure
```

### مشكلة: الصور لا تظهر
- تحقق من إعدادات Cloudinary
- تأكد من أن Upload Preset مضبوط على unsigned

### مشكلة: Phone Auth لا يعمل
- تأكد من تفعيل Phone Authentication في Firebase
- أضف أرقام اختبار في Firebase Console
- تحقق من SHA-1 للأندرويد

للحصول على SHA-1:
```bash
cd android
./gradlew signingReport
```

## 📞 الدعم

للمساعدة أو الأسئلة:
- راجع الملفات التوثيقية الأخرى:
  - `CUSTOMER_APP_README.md`
  - `IMPLEMENTATION_STATUS.md`
  - `PROJECT_SUMMARY.md`
  - `FINAL_SUMMARY.md`

## 📄 الترخيص

هذا المشروع ملك خاص. جميع الحقوق محفوظة.

## 🙏 شكر وتقدير

تم تطوير هذا المشروع باستخدام:
- Flutter & Dart
- Firebase Services
- Cloudinary
- Material Design 3
- Provider Pattern

---

**Built with ❤️ for Makanty - مكنتي**

*آخر تحديث: 2025-12-25*

