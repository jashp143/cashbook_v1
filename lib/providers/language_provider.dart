import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('en'); // Default to English
  
  Locale get locale => _locale;
  
  String get languageCode => _locale.languageCode;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // If there's an error, use default English
      _locale = const Locale('en');
    }
  }
  
  Future<void> setLanguage(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Helper method to get font family based on language
  String getFontFamily() {
    switch (_locale.languageCode) {
      case 'hi':
        return 'NotoSansDevanagari';
      case 'gu':
        return 'NotoSansGujarati';
      case 'en':
      default:
        return 'NotoSans';
    }
  }
}

