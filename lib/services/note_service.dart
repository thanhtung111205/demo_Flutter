// ============================================================
// NOTE SERVICE – LOCAL STORAGE
// ============================================================
//
// 📦 GIẢI THÍCH LƯU TRỮ DỮ LIỆU TEXT:
//
// Package: shared_preferences
// Cơ chế: Android lưu vào XML file tại:
//   /data/data/<package_name>/shared_prefs/<pref_file>.xml
//
// Đây là INTERNAL STORAGE (bộ nhớ trong riêng của app):
//   ✅ Không cần xin permission
//   ✅ Chỉ app này đọc được (bảo mật)
//   ✅ Tồn tại qua các lần khởi động lại
//   ❌ Bị xóa khi uninstall app
//   ❌ Không xuất hiện trong File Manager
//
// Dữ liệu được serialize thành JSON:
//   NoteModel → Map → jsonEncode → String → SharedPreferences
//
// ============================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';
import '../utils/constants.dart';

/// Service xử lý CRUD cho Notes sử dụng SharedPreferences
class NoteService {
  // ────────────────────────────────────────────
  // READ
  // ────────────────────────────────────────────

  /// Tải toàn bộ notes, sắp xếp mới nhất lên đầu
  Future<List<NoteModel>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(AppConstants.notesPrefsKey) ?? [];

    final notes = rawList
        .map((jsonStr) {
          try {
            return NoteModel.fromJson(
                jsonDecode(jsonStr) as Map<String, dynamic>);
          } catch (_) {
            return null; // bỏ qua entry bị corrupt
          }
        })
        .whereType<NoteModel>()
        .toList();

    // Sắp xếp: mới cập nhật nhất lên đầu
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  // ────────────────────────────────────────────
  // WRITE (internal helpers)
  // ────────────────────────────────────────────

  /// Lưu toàn bộ list notes (ghi đè)
  Future<void> _saveAll(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(AppConstants.notesPrefsKey, jsonList);
  }

  // ────────────────────────────────────────────
  // PUBLIC CRUD
  // ────────────────────────────────────────────

  /// Thêm một note mới vào storage
  Future<void> addNote(NoteModel note) async {
    final notes = await loadNotes();
    notes.insert(0, note); // thêm vào đầu
    await _saveAll(notes);
  }

  /// Cập nhật note đã có (tìm theo id)
  Future<void> updateNote(NoteModel updated) async {
    final notes = await loadNotes();
    final idx = notes.indexWhere((n) => n.id == updated.id);
    if (idx != -1) {
      notes[idx] = updated;
      await _saveAll(notes);
    }
  }

  /// Xóa note theo ID
  Future<void> deleteNote(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n.id == id);
    await _saveAll(notes);
  }

  /// Xóa toàn bộ notes (dùng để debug/reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.notesPrefsKey);
  }
}
