import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  final String _themeKey = 'isDarkTheme';
  bool _isLoading = true;

  bool get isDark => _isDark;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_themeKey) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);
  }
}