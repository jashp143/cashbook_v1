import 'package:flutter/material.dart';

class AppTheme {
  // Theme colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: black),
        displayMedium: TextStyle(color: black),
        displaySmall: TextStyle(color: black),
        headlineLarge: TextStyle(color: black),
        headlineMedium: TextStyle(color: black),
        headlineSmall: TextStyle(color: black),
        titleLarge: TextStyle(color: black),
        titleMedium: TextStyle(color: black),
        titleSmall: TextStyle(color: black),
        bodyLarge: TextStyle(color: black),
        bodyMedium: TextStyle(color: black),
        bodySmall: TextStyle(color: black),
        labelLarge: TextStyle(color: black),
        labelMedium: TextStyle(color: black),
        labelSmall: TextStyle(color: black),
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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: white),
        displayMedium: TextStyle(color: white),
        displaySmall: TextStyle(color: white),
        headlineLarge: TextStyle(color: white),
        headlineMedium: TextStyle(color: white),
        headlineSmall: TextStyle(color: white),
        titleLarge: TextStyle(color: white),
        titleMedium: TextStyle(color: white),
        titleSmall: TextStyle(color: white),
        bodyLarge: TextStyle(color: white),
        bodyMedium: TextStyle(color: white),
        bodySmall: TextStyle(color: white),
        labelLarge: TextStyle(color: white),
        labelMedium: TextStyle(color: white),
        labelSmall: TextStyle(color: white),
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

