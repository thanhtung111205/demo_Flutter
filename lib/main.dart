// ============================================================
// MAIN ENTRY POINT  Smart Note Pro
// ============================================================
// Diem khoi dong cua ung dung.
// WidgetsFlutterBinding.ensureInitialized() dam bao cac
// platform channel (SharedPreferences, image_picker...) san sang
// truoc khi runApp().
// ============================================================

import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Khoi tao Flutter engine bindings truoc khi dung plugin
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SmartNoteProApp());
}
