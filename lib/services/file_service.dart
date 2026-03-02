// ============================================================
// FILE SERVICE – FILE HANDLING
// ============================================================
//
// 📦 GIẢI THÍCH LƯU TRỮ FILE (ẢNH, TÀI LIỆU, HÌNH VẼ):
//
// Vị trí lưu: External App-Specific Directory
//   Android: /storage/emulated/0/Android/data/<package>/files/
//   iOS: NSApplicationSupportDirectory (sandboxed)
//
// Cấu trúc thư mục:
//   .../files/
//     ├── images/      ← ảnh từ gallery (jpg)
//     ├── documents/   ← file tài liệu (pdf, doc, txt…)
//     └── drawings/    ← ảnh vẽ tay (png)
//
// Tại sao KHÔNG dùng root /sdcard/ ?
//   ❌ Android 10+ yêu cầu MANAGE_EXTERNAL_STORAGE (rất khó xin)
//   ❌ Để lại file rác sau khi uninstall
//   ❌ Gây ô nhiễm bộ nhớ chia sẻ của người dùng
//
// Tại sao dùng External App Directory?
//   ✅ Android 10+ KHÔNG cần permission (Scoped Storage)
//   ✅ Auto xóa khi uninstall
//   ✅ Có thể xem bằng File Manager (thuận tiện debug)
//   ✅ Không bị giới hạn dung lượng như Internal
//
// ============================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

/// Service xử lý file: ảnh, tài liệu, và hình vẽ tay
class FileService {
  final _imagePicker = ImagePicker();

  // ────────────────────────────────────────────
  // DIRECTORY HELPERS
  // ────────────────────────────────────────────

  /// Lấy thư mục gốc của app để lưu file
  /// Ưu tiên external app dir; fallback sang internal nếu cần
  Future<Directory> _appRootDir() async {
    // getExternalStorageDirectories() trả về danh sách volume (thường có 1)
    // Trên Android: /storage/emulated/0/Android/data/<package>/files
    final dirs = await getExternalStorageDirectories();
    if (dirs != null && dirs.isNotEmpty) return dirs.first;

    // Fallback: internal documents dir (không cần permission)
    // Android: /data/data/<package>/files
    return getApplicationDocumentsDirectory();
  }

  /// Lấy / tạo sub-directory theo tên
  Future<Directory> _subDir(String name) async {
    final root = await _appRootDir();
    final dir = Directory('${root.path}/$name');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ────────────────────────────────────────────
  // IMAGE
  // ────────────────────────────────────────────

  /// Mở gallery để chọn ảnh, copy vào app directory
  /// Trả về đường dẫn tuyệt đối đến ảnh đã lưu, hoặc null nếu hủy
  Future<String?> pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // nén 85% để tiết kiệm dung lượng
      );
      if (picked == null) return null;

      final dir = await _subDir(AppConstants.imagesSubDir);
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dest = File('${dir.path}/$fileName');

      // Copy file từ cache của image_picker sang app dir
      await File(picked.path).copy(dest.path);
      return dest.path;
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────
  // DOCUMENT FILE
  // ────────────────────────────────────────────

  /// Mở file picker để chọn tài liệu
  /// Trả về Map {'path': ..., 'name': ...} hoặc null nếu hủy
  Future<Map<String, String>?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
        withData: false, // chỉ lấy path, không load vào RAM
      );

      if (result == null || result.files.single.path == null) return null;

      final picked = result.files.single;
      final dir = await _subDir(AppConstants.documentsSubDir);

      // Tên file giữ nguyên tên gốc, tránh trùng bằng timestamp prefix
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = '${timestamp}_${picked.name}';
      final dest = File('${dir.path}/$uniqueName');

      await File(picked.path!).copy(dest.path);
      return {'path': dest.path, 'name': picked.name};
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────
  // DRAWING
  // ────────────────────────────────────────────

  /// Lưu hình vẽ (Uint8List PNG bytes) ra file PNG
  /// Trả về đường dẫn file đã lưu, hoặc null nếu lỗi
  Future<String?> saveDrawing(Uint8List pngBytes) async {
    try {
      final dir = await _subDir(AppConstants.drawingsSubDir);
      final fileName = 'draw_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  // ────────────────────────────────────────────
  // CLEANUP
  // ────────────────────────────────────────────

  /// Xóa một file khỏi bộ nhớ (dùng khi xóa note hoặc thay attachment)
  Future<void> deleteFile(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Bỏ qua lỗi xóa file (file có thể đã bị xóa thủ công)
    }
  }
}
