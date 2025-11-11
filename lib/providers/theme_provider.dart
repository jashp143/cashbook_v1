import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    // This is used for backward compatibility
    // When system mode is selected, we can't determine if it's dark without context
    // So we return false as default, but this shouldn't be used when themeMode is system
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    // Cycle through: system -> light -> dark -> system
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void setTheme(bool isDark) {
    // For backward compatibility
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

