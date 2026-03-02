// ============================================================
// APP CONSTANTS
// ============================================================
// Các hằng số dùng chung toàn app.
// Tập trung tại đây để dễ thay đổi sau này.
// ============================================================

/// Hằng số toàn cục của Smart Note Pro
class AppConstants {
  AppConstants._();

  // ── App info ─────────────────────────────────
  static const String appName = 'Smart Note Pro';
  static const String appVersion = '1.0.0';

  // ── SharedPreferences keys ───────────────────
  /// Key lưu danh sách notes (List[String] JSON)
  static const String notesPrefsKey = 'smart_note_pro_notes_v1';

  // ── Layout ───────────────────────────────────
  static const double pagePadding = 16.0;
  static const double cardRadius = 16.0;
  static const double chipRadius = 24.0;

  // ── Note content ─────────────────────────────
  /// Độ dài tối đa của nội dung hiển thị trước (preview)
  static const int contentPreviewLength = 120;

  // ── Animation durations ──────────────────────
  static const Duration shortAnim = Duration(milliseconds: 200);
  static const Duration normalAnim = Duration(milliseconds: 350);
  static const Duration longAnim = Duration(milliseconds: 500);

  // ── File sub-directories (trong external app dir) ──
  static const String imagesSubDir = 'images';
  static const String documentsSubDir = 'documents';
  static const String drawingsSubDir = 'drawings';
}
