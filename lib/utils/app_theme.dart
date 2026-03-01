// ============================================================
// APP THEME – Material Design 3
// ============================================================
// Cấu hình theme cho toàn bộ app.
// Sử dụng ColorScheme.fromSeed() để tạo bảng màu tự động
// theo chuẩn Material You.
// Hỗ trợ cả Light Mode và Dark Mode.
// ============================================================

import 'package:flutter/material.dart';

/// Cấu hình theme toàn cục của Smart Note Pro
class AppTheme {
  AppTheme._(); // private constructor – không cho khởi tạo

  /// Màu gốc để generate ColorScheme
  /// Thay đổi màu này sẽ tự động cập nhật toàn bộ bảng màu
  static const Color seedColor = Color(0xFF6750A4); // Material Purple

  // ────────────────────────────────────────────
  // SHARED COMPONENT THEMES
  // ────────────────────────────────────────────

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 1,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // bo góc 16dp chuẩn M3
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      );

  static AppBarTheme get _appBarTheme => const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 3,
      );

  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  static ElevatedButtonThemeData get _elevatedBtnTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      );

  static FilledButtonThemeData get _filledBtnTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );

  static FloatingActionButtonThemeData get _fabTheme =>
      const FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 6,
      );

  static DialogThemeData get _dialogTheme => DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 3,
      );

  // ────────────────────────────────────────────
  // LIGHT THEME
  // ────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        cardTheme: _cardTheme,
        appBarTheme: _appBarTheme,
        inputDecorationTheme: _inputTheme,
        elevatedButtonTheme: _elevatedBtnTheme,
        filledButtonTheme: _filledBtnTheme,
        floatingActionButtonTheme: _fabTheme,
        dialogTheme: _dialogTheme,
        // Typography rõ ràng
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w500),
        ),
      );

  // ────────────────────────────────────────────
  // DARK THEME
  // ────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        cardTheme: _cardTheme,
        appBarTheme: _appBarTheme,
        inputDecorationTheme: _inputTheme,
        elevatedButtonTheme: _elevatedBtnTheme,
        filledButtonTheme: _filledBtnTheme,
        floatingActionButtonTheme: _fabTheme,
        dialogTheme: _dialogTheme,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w500),
        ),
      );
}
