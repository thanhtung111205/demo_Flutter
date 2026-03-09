// ============================================================
// NOTE SERVICE – LOCAL STORAGE + FIRESTORE SYNC
// ============================================================
//
// 📦 GIẢI THÍCH LƯU TRỮ DỮ LIỆU:
//
// Local Storage: SharedPreferences (offline cache)
// Cloud Storage: Firebase Firestore (sync when online)
//
// Dữ liệu được lưu ở cả hai nơi:
// ✅ Offline: Đọc từ SharedPreferences
// ✅ Online: Sync với Firestore tự động
//
// ============================================================

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';
import '../utils/constants.dart';

/// Service xử lý CRUD cho Notes (Local + Firestore)
class NoteService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  // ────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────

  String get _userId => _auth.currentUser?.uid ?? '';

  String get _notesCollection => 'users/$_userId/notes';

  /// Tải toàn bộ notes, sắp xếp mới nhất lên đầu
  Future<List<NoteModel>> loadNotes() async {
    try {
      // Thử load từ Firestore trước
      final snapshot = await _firestore
          .collection(_notesCollection)
          .orderBy('updatedAt', descending: true)
          .get();

      final notes = snapshot.docs.map((doc) {
        return NoteModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Lưu cache vào SharedPreferences để dùng khi offline
      await _saveLocalCache(notes);
      return notes;
    } catch (e) {
      // Nếu lỗi (offline), load từ cache cục bộ
      return _loadLocalCache();
    }
  }

  /// Load từ SharedPreferences (offline mode)
  Future<List<NoteModel>> _loadLocalCache() async {
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

  /// Lưu cache vào SharedPreferences
  Future<void> _saveLocalCache(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(AppConstants.notesPrefsKey, jsonList);
  }

  /// Lưu toàn bộ list notes vào Firestore (ghi đè)
  Future<void> _saveAll(List<NoteModel> notes) async {
    // Lưu cache cục bộ
    await _saveLocalCache(notes);

    // Nếu chưa login, bỏ qua Firestore
    if (_userId.isEmpty) return;

    try {
      // Xóa collection cũ
      final batch = _firestore.batch();
      final oldDocs = await _firestore.collection(_notesCollection).get();
      for (var doc in oldDocs.docs) {
        batch.delete(doc.reference);
      }

      // Thêm notes mới
      for (var note in notes) {
        final docRef = _firestore.collection(_notesCollection).doc(note.id);
        batch.set(docRef, note.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('Error saving to Firestore: $e');
      // Tiếp tục dù có lỗi, data vẫn lưu cục bộ
    }
  }

  // ────────────────────────────────────────────
  // PUBLIC CRUD
  // ────────────────────────────────────────────

  /// Thêm một note mới vào storage
  Future<void> addNote(NoteModel note) async {
    // Lưu cục bộ
    final notes = await _loadLocalCache();
    notes.insert(0, note);
    await _saveLocalCache(notes);

    // Lưu lên Firestore
    if (_userId.isEmpty) return;
    try {
      await _firestore
          .collection(_notesCollection)
          .doc(note.id)
          .set(note.toJson());
    } catch (e) {
      print('Error adding note to Firestore: $e');
    }
  }

  /// Cập nhật note đã có (tìm theo id)
  Future<void> updateNote(NoteModel updated) async {
    // Lưu cục bộ
    final notes = await _loadLocalCache();
    final idx = notes.indexWhere((n) => n.id == updated.id);
    if (idx != -1) {
      notes[idx] = updated;
      await _saveLocalCache(notes);
    }

    // Cập nhật lên Firestore
    if (_userId.isEmpty) return;
    try {
      await _firestore
          .collection(_notesCollection)
          .doc(updated.id)
          .update(updated.toJson());
    } catch (e) {
      print('Error updating note in Firestore: $e');
    }
  }

  /// Xóa note theo ID
  Future<void> deleteNote(String id) async {
    // Xóa cục bộ
    final notes = await _loadLocalCache();
    notes.removeWhere((n) => n.id == id);
    await _saveLocalCache(notes);

    // Xóa khỏi Firestore
    if (_userId.isEmpty) return;
    try {
      await _firestore
          .collection(_notesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting note from Firestore: $e');
    }
  }

  /// Xóa toàn bộ notes (dùng để debug/reset)
  Future<void> clearAll() async {
    // Xóa cục bộ
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.notesPrefsKey);

    // Xóa khỏi Firestore
    if (_userId.isEmpty) return;
    try {
      final batch = _firestore.batch();
      final docs = await _firestore.collection(_notesCollection).get();
      for (var doc in docs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing Firestore: $e');
    }
  }
}
