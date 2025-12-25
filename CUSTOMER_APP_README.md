# تطبيق العملاء - مكنتي (Customer Mobile App)

## 🎯 نظرة عامة
تطبيق Flutter للعملاء (Android & iOS) لمتجر إلكتروني لبيع ماكينات الخياطة وقطع الغيار، مع التكامل الكامل مع Firebase و Cloudinary.

## 📱 كيفية التشغيل

### لتشغيل تطبيق العملاء:
```bash
# تأكد من وجود Flutter في النظام
flutter doctor

# تثبيت الحزم
flutter pub get

# تشغيل تطبيق العملاء
flutter run -t lib/customer_main.dart
```

### لتشغيل لوحة تحكم الأدمن (Dashboard):
```bash
flutter run -t lib/main.dart
```

## 🏗️ هيكل المشروع

```
lib/
├── customer_main.dart                 # نقطة دخول تطبيق العملاء
├── main.dart                          # نقطة دخول لوحة التحكم
├── config/
│   ├── customer_routes.dart          # مسارات تطبيق العملاء
│   └── customer_constants.dart       # الثوابت والإعدادات
├── models/
│   ├── product.dart                  # نموذج المنتج (مشترك)
│   ├── order.dart                    # نموذج الطلب (مشترك)
│   ├── cashback.dart                 # نموذج الكاش باك (مشترك)
│   ├── banner.dart                   # نموذج البانر (مشترك)
│   ├── user.dart                     # نموذج المستخدم (جديد)
│   ├── address.dart                  # نموذج العنوان (جديد)
│   ├── cart_item.dart                # نموذج عنصر السلة (جديد)
│   └── comparison.dart               # نموذج المقارنة (جديد)
├── services/
│   ├── cloudinary_service.dart       # خدمة Cloudinary (مشتركة)
│   ├── auth_service.dart             # خدمة المصادقة (جديدة)
│   └── firestore_service.dart        # خدمة Firestore (جديدة)
├── providers/
│   ├── products_provider.dart        # إدارة المنتجات (مشترك)
│   ├── orders_provider.dart          # إدارة الطلبات (مشترك)
│   ├── cashback_provider.dart        # إدارة الكاش باك (مشترك)
│   ├── banners_provider.dart         # إدارة البانرات (مشترك)
│   ├── customer_auth_provider.dart   # إدارة المصادقة (جديد)
│   ├── cart_provider.dart            # إدارة السلة (جديد)
│   └── comparison_provider.dart      # إدارة المقارنات (جديد)
└── customer/
    ├── screens/
    │   ├── auth/
    │   │   ├── customer_splash_screen.dart
    │   │   └── customer_onboarding_screen.dart
    │   ├── home/
    │   │   ├── customer_home_screen.dart
    │   │   └── customer_main_tab.dart
    │   ├── products/
    │   ├── comparison/
    │   │   └── customer_comparison_screen.dart
    │   ├── cart/
    │   │   └── customer_cart_screen.dart
    │   └── profile/
    │       └── customer_profile_screen.dart
    └── widgets/
```

## ✨ المميزات المنفذة

### ✅ المرحلة 1: البنية الأساسية
- [x] نماذج البيانات الكاملة (User, Address, CartItem, Comparison)
- [x] خدمة المصادقة مع Firebase (Phone Auth + Guest Mode)
- [x] خدمة Firestore للتعامل مع قاعدة البيانات
- [x] إدارة الحالة باستخدام Provider

### ✅ المرحلة 2: State Management
- [x] CustomerAuthProvider - إدارة المصادقة والمستخدمين
- [x] CartProvider - إدارة السلة مع التخزين المحلي
- [x] ComparisonProvider - إدارة المقارنات مع منطق تحديد الأفضل

### ✅ المرحلة 3: الواجهات الأساسية
- [x] Splash Screen مع أنيميشن جميل
- [x] Onboarding بـ 3 شاشات تعريفية
- [x] Home Screen مع Bottom Navigation
- [x] هيكل التنقل الأساسي

### 🔄 قيد التطوير
- [ ] الصفحة الرئيسية (Banner Slider, Categories, Products)
- [ ] صفحات المنتجات (Listing, Details, Filters)
- [ ] خاصية المقارنة (UI كاملة)
- [ ] السلة والشراء (Cart, Checkout, Orders)
- [ ] الملف الشخصي (Profile, Orders History, Cashback Wallet)

## 🔥 Firebase Configuration

التطبيق مهيأ للعمل مع Firebase. تأكد من:
1. وجود ملف `google-services.json` في `android/app/`
2. وجود ملف `GoogleService-Info.plist` في `ios/Runner/`
3. تفعيل Firebase Authentication (Phone Auth)
4. تفعيل Cloud Firestore
5. إعداد Firestore Rules المناسبة

## 📦 Collections في Firestore

```
users                    # بيانات المستخدمين
products                 # المنتجات
categories               # الأقسام (اختياري)
banners                  # البانرات
orders                   # الطلبات
cashback_transactions    # معاملات الكاش باك
user_addresses           # العناوين المحفوظة
comparisons              # المقارنات المحفوظة
```

## 🎨 المميزات التقنية

### Authentication
- تسجيل الدخول برقم الهاتف + OTP
- Guest Mode (زائر بدون تسجيل)
- تحويل حساب الزائر إلى حساب دائم

### State Management
- Provider لإدارة الحالة
- Shared Preferences للتخزين المحلي
- Firebase Realtime Updates

### Performance
- Lazy Loading للصور باستخدام cached_network_image
- Pagination للمنتجات
- Offline Support مع Firestore Persistence
- تحسين استعلامات Firestore

### UI/UX
- RTL Support كامل للغة العربية
- Dark Mode Support
- Responsive Design
- Smooth Animations
- Material Design 3

## 🔧 التكوينات

### الكاش باك
- النسبة الافتراضية: 5% من قيمة الطلب
- الحد الأدنى للطلب: 500 جنيه
- الحد الأدنى للاستخدام: 10 جنيه

### الشحن
- رسوم شحن افتراضية: 50 جنيه
- شحن مجاني فوق: 1000 جنيه
- رسوم متغيرة حسب المحافظة

### المقارنة
- الحد الأقصى للمنتجات: 3 منتجات
- تحديد تلقائي للمنتج الأفضل في كل خاصية

## 📱 كيفية البناء للإنتاج

### Android
```bash
flutter build apk --release -t lib/customer_main.dart
# أو
flutter build appbundle --release -t lib/customer_main.dart
```

### iOS
```bash
flutter build ios --release -t lib/customer_main.dart
```

## 🚀 الخطوات التالية

1. **تطوير الصفحة الرئيسية**
   - Banner Slider
   - Categories Grid
   - Featured Products
   - Best Sellers

2. **صفحات المنتجات**
   - Product Listing مع Filters
   - Product Details مع Image Gallery
   - Add to Cart/Comparison

3. **السلة والشراء**
   - Cart Screen
   - Checkout Flow
   - Payment Integration
   - Order Confirmation

4. **الملف الشخصي**
   - User Profile
   - Orders History
   - Cashback Wallet
   - Address Management

5. **التحسينات**
   - Search Functionality
   - Notifications
   - Sharing
   - Reviews & Ratings

## 📝 ملاحظات

- التطبيق يستخدم نفس قاعدة البيانات مع لوحة تحكم الأدمن
- جميع النماذج متوافقة بين التطبيقين
- التطبيق جاهز للتوسع (Multi-vendor, Payment Gateways, etc.)
- الكود منظم وموثق بالعربية

## 🤝 المساهمة

هذا التطبيق جزء من مشروع "مكنتي" لبيع ماكينات الخياطة.

---

**Built with ❤️ using Flutter & Firebase**
