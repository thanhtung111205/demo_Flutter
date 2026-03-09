// ============================================================
// MAIN ENTRY POINT  Smart Note Pro
// ============================================================
// Diem khoi dong cua ung dung.
// WidgetsFlutterBinding.ensureInitialized() dam bao cac
// platform channel (SharedPreferences, image_picker...) san sang
// truoc khi runApp().
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartNoteProApp());
}
