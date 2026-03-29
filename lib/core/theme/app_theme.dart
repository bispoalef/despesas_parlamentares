import 'package:flutter/material.dart';

class AppTheme {
  static const Color corPrimaria = Color(0xFF1D3557);
  static const Color corSecundaria = Color(0xFFFFC107);
  static const Color corSucesso = Color(0xFF4CAF50);
  static const Color corFundo = Color(0xFFF8F9FA);
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: corPrimaria,
        primary: corPrimaria,
        secondary: corSecundaria,
        tertiary: corSucesso,
        surface: corFundo,
        onSurface: const Color(0xFF212529),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),

      scaffoldBackgroundColor: corFundo,

      appBarTheme: const AppBarTheme(
        backgroundColor: corPrimaria,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: corPrimaria, width: 2),
        ),
        prefixIconColor: corPrimaria,
        labelStyle: const TextStyle(color: corPrimaria),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
