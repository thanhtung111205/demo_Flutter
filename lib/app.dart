// ============================================================
// APP ROOT – MaterialApp Configuration
// ============================================================
// Cấu hình root widget của Smart Note Pro:
//  • Material Design 3 (useMaterial3: true) – đã bật trong theme
//  • Light + Dark theme tự động theo hệ thống
//  • Không có debug banner
//  • Home → HomeScreen
// ============================================================

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

/// Root widget của Smart Note Pro
class SmartNoteProApp extends StatelessWidget {
  const SmartNoteProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ── Metadata ──
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme (Material 3) ──
      theme: AppTheme.lightTheme,       // Light mode
      darkTheme: AppTheme.darkTheme,    // Dark mode
      themeMode: ThemeMode.system,      // Tự động theo cài đặt thiết bị

      // ── Entry point ──
      home: const HomeScreen(),
    );
  }
}
