// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;
  static const String _themeKey = 'theme_mode';

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // تحميل الثيم المحفوظ
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // تبديل الثيم فورًا
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // استدعاء فوري
    await _saveThemeToPrefs();
  }

  // تعيين الثيم فورًا
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    notifyListeners(); // استدعاء فوري
    await _saveThemeToPrefs();
  }

  // حفظ الثيم
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
