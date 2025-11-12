import 'package:flutter/material.dart';

class AppTheme {
  // Theme colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);

  static ThemeData getLightTheme([String fontFamily = 'NotoSans']) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: black,
        primary: black,
        secondary: black,
        surface: white,
        error: red,
        onPrimary: white,
        onSecondary: white,
        onSurface: black,
        onError: white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: white,
      cardColor: white,
      dividerColor: black,
      iconTheme: const IconThemeData(color: black),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: black, fontFamily: fontFamily),
        displayMedium: TextStyle(color: black, fontFamily: fontFamily),
        displaySmall: TextStyle(color: black, fontFamily: fontFamily),
        headlineLarge: TextStyle(color: black, fontFamily: fontFamily),
        headlineMedium: TextStyle(color: black, fontFamily: fontFamily),
        headlineSmall: TextStyle(color: black, fontFamily: fontFamily),
        titleLarge: TextStyle(color: black, fontFamily: fontFamily),
        titleMedium: TextStyle(color: black, fontFamily: fontFamily),
        titleSmall: TextStyle(color: black, fontFamily: fontFamily),
        bodyLarge: TextStyle(color: black, fontFamily: fontFamily),
        bodyMedium: TextStyle(color: black, fontFamily: fontFamily),
        bodySmall: TextStyle(color: black, fontFamily: fontFamily),
        labelLarge: TextStyle(color: black, fontFamily: fontFamily),
        labelMedium: TextStyle(color: black, fontFamily: fontFamily),
        labelSmall: TextStyle(color: black, fontFamily: fontFamily),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        iconTheme: IconThemeData(color: black),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: black, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: black, width: 1),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: black, width: 2),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme([String fontFamily = 'NotoSans']) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: white,
        primary: white,
        secondary: white,
        surface: black,
        error: red,
        onPrimary: black,
        onSecondary: black,
        onSurface: white,
        onError: white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: black,
      cardColor: black,
      dividerColor: white,
      iconTheme: const IconThemeData(color: white),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: white, fontFamily: fontFamily),
        displayMedium: TextStyle(color: white, fontFamily: fontFamily),
        displaySmall: TextStyle(color: white, fontFamily: fontFamily),
        headlineLarge: TextStyle(color: white, fontFamily: fontFamily),
        headlineMedium: TextStyle(color: white, fontFamily: fontFamily),
        headlineSmall: TextStyle(color: white, fontFamily: fontFamily),
        titleLarge: TextStyle(color: white, fontFamily: fontFamily),
        titleMedium: TextStyle(color: white, fontFamily: fontFamily),
        titleSmall: TextStyle(color: white, fontFamily: fontFamily),
        bodyLarge: TextStyle(color: white, fontFamily: fontFamily),
        bodyMedium: TextStyle(color: white, fontFamily: fontFamily),
        bodySmall: TextStyle(color: white, fontFamily: fontFamily),
        labelLarge: TextStyle(color: white, fontFamily: fontFamily),
        labelMedium: TextStyle(color: white, fontFamily: fontFamily),
        labelSmall: TextStyle(color: white, fontFamily: fontFamily),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        iconTheme: IconThemeData(color: white),
      ),
      cardTheme: CardThemeData(
        color: black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: white, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: white, width: 1),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 2),
        ),
      ),
    );
  }
}

