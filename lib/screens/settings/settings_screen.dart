// lib/screens/settings/settings_screen.dart
import 'package:ecommerce_dashboard/constants/app_theme.dart';
import 'package:ecommerce_dashboard/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification Settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _orderNotifications = true;
  bool _stockNotifications = true;

  // Appearance Settings
  bool _darkMode = false;
  String _language = 'ar';
  double _fontSize = 14.0;

  // Store Settings
  final _storeNameController = TextEditingController(text: 'متجري الإلكتروني');
  final _storeEmailController = TextEditingController(text: 'info@mystore.com');
  final _storePhoneController = TextEditingController(text: '+20 123 456 7890');
  final _storeAddressController = TextEditingController(text: 'القاهرة، مصر');

  // Currency Settings
  String _currency = 'EGP';
  String _taxRate = '14';

  @override
  void initState() {
    super.initState();
    // يجب أن تكون _darkMode متزامنة مع ThemeProvider في البداية
    _darkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _language = prefs.getString('language') ?? 'ar';
      // _darkMode يتم تحميلها مباشرة من ThemeProvider الآن
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('language', _language);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح'),
          // استخدام لون النجاح الديناميكي
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. استخراج خصائص الثيم الأساسية
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(textTheme),
          SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildNotificationSettings(colorScheme),
                    SizedBox(height: AppSpacing.md),
                    _buildAppearanceSettings(colorScheme),
                    SizedBox(height: AppSpacing.md),
                    _buildSecuritySettings(colorScheme),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _buildStoreSettings(colorScheme),
                    SizedBox(height: AppSpacing.md),
                    _buildSystemInfo(colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإعدادات', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.xs),
            Text(
              'إدارة إعدادات التطبيق والحساب',
              style: AppTextStyles.bodyMedium.copyWith(
                // استخدام لون النص الثانوي الديناميكي
                color: textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // الأزرار تستخدم ثيمات OutlinedButtonThemeData و ElevatedButtonThemeData
            OutlinedButton.icon(
              onPressed: _resetSettings,
              icon: Icon(Icons.refresh),
              label: Text('إعادة تعيين'),
            ),
            SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: Icon(Icons.save),
              label: Text('حفظ التغييرات'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(ColorScheme colorScheme) {
    return _settingsCard(
      'الإشعارات',
      Icons.notifications,
      AppColors.warning,
      colorScheme,
      [
        SwitchListTile(
          title: Text('إشعارات البريد الإلكتروني'),
          subtitle: Text('تلقي إشعارات عبر البريد الإلكتروني'),
          value: _emailNotifications,
          onChanged: (value) {
            setState(() => _emailNotifications = value);
          },
        ),
        Divider(height: 1),
        SwitchListTile(
          title: Text('الإشعارات الفورية'),
          subtitle: Text('تلقي إشعارات فورية على المتصفح'),
          value: _pushNotifications,
          onChanged: (value) {
            setState(() => _pushNotifications = value);
          },
        ),
        Divider(height: 1),
        SwitchListTile(
          title: Text('إشعارات الطلبات'),
          subtitle: Text('إشعار عند استلام طلب جديد'),
          value: _orderNotifications,
          onChanged: (value) {
            setState(() => _orderNotifications = value);
          },
        ),
        Divider(height: 1),
        SwitchListTile(
          title: Text('إشعارات المخزون'),
          subtitle: Text('إشعار عند انخفاض المخزون'),
          value: _stockNotifications,
          onChanged: (value) {
            setState(() => _stockNotifications = value);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings(ColorScheme colorScheme) {
    return _settingsCard('المظهر', Icons.palette, AppColors.info, colorScheme, [
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SwitchListTile(
            title: Text('الوضع الداكن'),
            subtitle: Text('تفعيل الوضع الداكن للتطبيق'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setTheme(value);
              setState(() => _darkMode = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'تم تفعيل الوضع الداكن' : 'تم تفعيل الوضع الفاتح',
                  ),
                  // استخدام لون النجاح الديناميكي
                  backgroundColor: colorScheme.secondary,
                ),
              );
            },
          );
        },
      ),
      Divider(height: 1),
      ListTile(
        title: Text('اللغة'),
        subtitle: Text('اختر لغة التطبيق'),
        trailing: DropdownButton<String>(
          value: _language,
          underline: SizedBox(),
          // استخدام TextTheme للألوان
          items: [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _language = value);
            }
          },
        ),
      ),
      Divider(height: 1),
      ListTile(
        title: Text('حجم الخط'),
        subtitle: Slider(
          value: _fontSize,
          min: 12,
          max: 18,
          divisions: 6,
          label: '${_fontSize.toInt()}',
          // لون الـ Slider يستخدم colorScheme.primary تلقائياً
          onChanged: (value) {
            setState(() => _fontSize = value);
          },
        ),
      ),
    ]);
  }

  Widget _buildSecuritySettings(ColorScheme colorScheme) {
    return _settingsCard(
      'الأمان',
      Icons.security,
      AppColors.error,
      colorScheme,
      [
        ListTile(
          // IconThemeData يعالج لون الأيقونة
          leading: Icon(Icons.lock, color: colorScheme.primary),
          title: Text('تغيير كلمة المرور'),
          subtitle: Text('تحديث كلمة المرور الخاصة بك'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showChangePasswordDialog,
        ),
        Divider(height: 1),
        ListTile(
          // IconThemeData يعالج لون الأيقونة
          leading: Icon(Icons.phone_android, color: AppColors.success),
          title: Text('المصادقة الثنائية'),
          subtitle: Text('تأمين حسابك بخطوة إضافية'),
          // الـ Switch يستخدم SwitchThemeData
          trailing: Switch(
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('سيتم تفعيل هذه الميزة قريباً')),
              );
            },
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.history, color: AppColors.info),
          title: Text('سجل النشاط'),
          subtitle: Text('عرض سجل تسجيل الدخول'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('قريباً...')));
          },
        ),
      ],
    );
  }

  Widget _buildStoreSettings(ColorScheme colorScheme) {
    return _settingsCard(
      'إعدادات المتجر',
      Icons.store,
      AppColors.primary,
      colorScheme,
      [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // حقول الإدخال تعتمد على InputDecorationTheme و TextTheme من الثيم الرئيسي
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: 'اسم المتجر',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: _storeEmailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: _storePhoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: _storeAddressController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: InputDecoration(
                  labelText: 'العملة',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'EGP',
                    child: Text('جنيه مصري (EGP)'),
                  ),
                  DropdownMenuItem(value: 'USD', child: Text('دولار (USD)')),
                  DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
                  DropdownMenuItem(value: 'SAR', child: Text('ريال (SAR)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: TextEditingController(text: _taxRate),
                decoration: InputDecoration(
                  labelText: 'نسبة الضريبة (%)',
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _taxRate = value,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfo(ColorScheme colorScheme) {
    return _settingsCard(
      'معلومات النظام',
      Icons.info,
      AppColors.grey600,
      colorScheme,
      [
        _infoTile('الإصدار', '1.0.0'),
        Divider(height: 1),
        _infoTile('آخر تحديث', '15 ديسمبر 2024'),
        Divider(height: 1),
        _infoTile('حجم قاعدة البيانات', '45.2 MB'),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.cleaning_services, color: AppColors.warning),
          title: Text('مسح ذاكرة التخزين المؤقت'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _clearCache,
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.download, color: AppColors.info),
          title: Text('تحديث التطبيق'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _checkForUpdates,
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.bug_report, color: AppColors.error),
          title: Text('الإبلاغ عن مشكلة'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _reportIssue,
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.help, color: colorScheme.primary),
          title: Text('المساعدة والدعم'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showHelp,
        ),
      ],
    );
  }

  // 2. تحديث دالة البطاقة لقبول ColorScheme
  Widget _settingsCard(
    String title,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        // استخدام لون السطح الديناميكي
        color: colorScheme.surface,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              // لون الترويسة من اللون الدلالي + شفافية
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.medium.bottomLeft.x),
                topRight: Radius.circular(AppBorderRadius.medium.bottomLeft.x),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: AppSpacing.md),
                // لون النص يبقى باللون الدلالي ليتناسب مع الخلفية الفاتحة (الشفافة)
                Text(title, style: AppTextStyles.h4.copyWith(color: color)),
              ],
            ),
          ),
          // جميع الـ ListTiles و Dividers ستستخدم الثيم بشكل افتراضي
          ...children,
        ],
      ),
    );
  }

  // 3. تحديث دالة _infoTile
  Widget _infoTile(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      // عنوان النص يرث لون الثيم
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          // استخدام لون النص الثانوي الديناميكي
          color: textTheme.bodyMedium?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    // AlertDialog و TextFields و Buttons تستخدم ألوان الثيم تلقائياً
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تغيير كلمة المرور بنجاح'),
                  backgroundColor: colorScheme.secondary,
                ),
              );
            },
            child: Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    final colorScheme = Theme.of(context).colorScheme;
    // AlertDialog و TextButtons تستخدم ألوان الثيم تلقائياً
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إعادة تعيين الإعدادات'),
        content: Text(
          'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى الافتراضية؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _emailNotifications = true;
                _pushNotifications = true;
                _orderNotifications = true;
                _stockNotifications = true;
                _darkMode = false;
                _language = 'ar';
                _fontSize = 14.0;
                // يجب إعادة تعيين الثيم أيضاً
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).setTheme(false);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إعادة تعيين الإعدادات'),
                  backgroundColor: colorScheme.error,
                ),
              );
            },
            // استخدام لون الخطأ الديناميكي
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
            child: Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مسح ذاكرة التخزين المؤقت'),
        content: Text('هل تريد مسح جميع البيانات المؤقتة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم مسح ذاكرة التخزين المؤقت'),
                  backgroundColor: colorScheme.secondary,
                ),
              );
            },
            child: Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('التحقق من التحديثات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // لون الـ Indicator يعتمد على colorScheme.primary
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            // النص يرث لون الثيم
            Text('جاري التحقق من التحديثات...', style: textTheme.bodyMedium),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أنت تستخدم أحدث إصدار'),
          backgroundColor: colorScheme.secondary,
        ),
      );
    });
  }

  void _reportIssue() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الإبلاغ عن مشكلة'),
        // TextField يستخدم InputDecorationTheme من الثيم
        content: TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'صف المشكلة التي واجهتها...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال التقرير. شكراً لك!'),
                  backgroundColor: colorScheme.secondary,
                ),
              );
            },
            child: Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('المساعدة والدعم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              // لون الأيقونة يرث IconThemeData
              leading: Icon(Icons.email),
              title: Text('البريد الإلكتروني'),
              subtitle: Text('support@mystore.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('الهاتف'),
              subtitle: Text('+20 123 456 7890'),
            ),
            ListTile(
              leading: Icon(Icons.web),
              title: Text('الموقع الإلكتروني'),
              subtitle: Text('www.mystore.com/help'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeEmailController.dispose();
    _storePhoneController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }
}
