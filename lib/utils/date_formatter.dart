// ============================================================
// DATE FORMATTER UTILITY
// ============================================================
// Tiện ích format ngày giờ hiển thị trên UI.
// Sử dụng package 'intl' để định dạng chuẩn.
// ============================================================

import 'package:intl/intl.dart';

/// Tiện ích format ngày giờ cho Smart Note Pro
class DateFormatter {
  DateFormatter._();

  // ────────────────────────────────────────────
  // RELATIVE TIME (ngắn, dùng trên Note Card)
  // ────────────────────────────────────────────

  /// Trả về chuỗi tương đối ngắn gọn:
  /// "Just now", "5m ago", "3h ago", "2d ago", "Mar 5, 2025"
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return DateFormat('MMM d').format(date);
    return DateFormat('MMM d, y').format(date);
  }

  // ────────────────────────────────────────────
  // FULL DATE TIME (dùng trên màn hình chi tiết)
  // ────────────────────────────────────────────

  /// Trả về ngày giờ đầy đủ: "March 5, 2025 – 02:30 PM"
  static String full(DateTime date) {
    return DateFormat("MMMM d, y '–' hh:mm a").format(date);
  }

  /// Trả về chỉ ngày: "March 5, 2025"
  static String dateOnly(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
