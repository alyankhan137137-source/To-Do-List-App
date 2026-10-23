import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing theme preferences (Light/Dark/System) and custom primary accent color with persistence.
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'user_theme_mode';
  static const String _colorKey = 'user_accent_color';

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF6366F1); // Default Indigo

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  static const List<Color> availableAccentColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Royal Violet
    Color(0xFFF43F5E), // Coral Rose
    Color(0xFFF59E0B), // Golden Amber
    Color(0xFF06B6D4), // Ocean Teal
  ];

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    final savedColorValue = prefs.getInt(_colorKey);

    if (savedTheme != null) {
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    }

    if (savedColorValue != null) {
      _primaryColor = Color(savedColorValue);
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setPrimaryAccentColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.toARGB32());
  }

  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
