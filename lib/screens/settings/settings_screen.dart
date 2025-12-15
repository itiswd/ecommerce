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
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'ar';
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
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildNotificationSettings(),
                    SizedBox(height: 16),
                    _buildAppearanceSettings(),
                    SizedBox(height: 16),
                    _buildSecuritySettings(),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildStoreSettings(),
                    SizedBox(height: 16),
                    _buildSystemInfo(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإعدادات', style: AppTextStyles.h2),
            SizedBox(height: 4),
            Text(
              'إدارة إعدادات التطبيق والحساب',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _resetSettings,
              icon: Icon(Icons.refresh),
              label: Text('إعادة تعيين'),
            ),
            SizedBox(width: 12),
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

  Widget _buildNotificationSettings() {
    return _settingsCard('الإشعارات', Icons.notifications, AppColors.warning, [
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
    ]);
  }

  Widget _buildAppearanceSettings() {
    return _settingsCard('المظهر', Icons.palette, AppColors.info, [
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
                  backgroundColor: AppColors.success,
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
          onChanged: (value) {
            setState(() => _fontSize = value);
          },
        ),
      ),
    ]);
  }

  Widget _buildSecuritySettings() {
    return _settingsCard('الأمان', Icons.security, AppColors.error, [
      ListTile(
        leading: Icon(Icons.lock, color: AppColors.primary),
        title: Text('تغيير كلمة المرور'),
        subtitle: Text('تحديث كلمة المرور الخاصة بك'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _showChangePasswordDialog,
      ),
      Divider(height: 1),
      ListTile(
        leading: Icon(Icons.phone_android, color: AppColors.success),
        title: Text('المصادقة الثنائية'),
        subtitle: Text('تأمين حسابك بخطوة إضافية'),
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
    ]);
  }

  Widget _buildStoreSettings() {
    return _settingsCard('إعدادات المتجر', Icons.store, AppColors.primary, [
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                labelText: 'اسم المتجر',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _storeEmailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _storePhoneController,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _storeAddressController,
              decoration: InputDecoration(
                labelText: 'العنوان',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: InputDecoration(
                labelText: 'العملة',
                prefixIcon: Icon(Icons.attach_money),
              ),
              items: [
                DropdownMenuItem(value: 'EGP', child: Text('جنيه مصري (EGP)')),
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
            SizedBox(height: 16),
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
    ]);
  }

  Widget _buildSystemInfo() {
    return _settingsCard('معلومات النظام', Icons.info, AppColors.grey600, [
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
        leading: Icon(Icons.help, color: AppColors.primary),
        title: Text('المساعدة والدعم'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _showHelp,
      ),
    ]);
  }

  Widget _settingsCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 12),
                Text(title, style: AppTextStyles.h4.copyWith(color: color)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
            SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 16),
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
                SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
              );
            },
            child: Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
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
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إعادة تعيين الإعدادات')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
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
                SnackBar(content: Text('تم مسح ذاكرة التخزين المؤقت')),
              );
            },
            child: Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('التحقق من التحديثات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري التحقق من التحديثات...'),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('أنت تستخدم أحدث إصدار')));
    });
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الإبلاغ عن مشكلة'),
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
                SnackBar(content: Text('تم إرسال التقرير. شكراً لك!')),
              );
            },
            child: Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('المساعدة والدعم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
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
