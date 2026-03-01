// ============================================================
// NOTE MODEL
// ============================================================
// Đây là data model trung tâm của app.
// Lưu toàn bộ thông tin của một ghi chú.
// Hỗ trợ JSON serialization để lưu vào SharedPreferences.
// ============================================================

/// Sentinel class – dùng để phân biệt "không truyền giá trị"
/// với "truyền null" trong copyWith()
class _Undefined {
  const _Undefined();
}

/// Model đại diện cho một ghi chú trong Smart Note Pro
class NoteModel {
  /// ID duy nhất, dạng UUID v4
  final String id;

  /// Tiêu đề ghi chú
  String title;

  /// Nội dung ghi chú
  String content;

  /// Thời điểm tạo (không đổi sau khi tạo)
  final DateTime createdAt;

  /// Thời điểm cập nhật lần cuối
  DateTime updatedAt;

  /// Đường dẫn đến ảnh đính kèm (lưu trong external app dir)
  /// VD: /storage/emulated/0/Android/data/[pkg]/files/images/img_xxxx.jpg
  String? imagePath;

  /// Đường dẫn đến file tài liệu đính kèm
  String? filePath;

  /// Tên file tài liệu (chỉ hiển thị, không dùng để mở)
  String? fileName;

  /// Đường dẫn đến ảnh vẽ tay (PNG) đính kèm
  String? drawingPath;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.filePath,
    this.fileName,
    this.drawingPath,
  });

  // ────────────────────────────────────────────
  // JSON SERIALIZATION
  // ────────────────────────────────────────────

  /// Chuyển thành Map[String,dynamic] để lưu vào SharedPreferences
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'imagePath': imagePath,
        'filePath': filePath,
        'fileName': fileName,
        'drawingPath': drawingPath,
      };

  /// Tạo NoteModel từ JSON đã lưu
  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        imagePath: json['imagePath'] as String?,
        filePath: json['filePath'] as String?,
        fileName: json['fileName'] as String?,
        drawingPath: json['drawingPath'] as String?,
      );

  // ────────────────────────────────────────────
  // COPY WITH
  // Dùng sentinel _Undefined để có thể set nullable field về null
  // ────────────────────────────────────────────
  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    Object? imagePath = const _Undefined(),
    Object? filePath = const _Undefined(),
    Object? fileName = const _Undefined(),
    Object? drawingPath = const _Undefined(),
  }) =>
      NoteModel(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        // Nếu là _Undefined → giữ giá trị cũ; ngược lại → set mới (kể cả null)
        imagePath:
            imagePath is _Undefined ? this.imagePath : imagePath as String?,
        filePath: filePath is _Undefined ? this.filePath : filePath as String?,
        fileName: fileName is _Undefined ? this.fileName : fileName as String?,
        drawingPath: drawingPath is _Undefined
            ? this.drawingPath
            : drawingPath as String?,
      );

  @override
  String toString() =>
      'NoteModel(id: $id, title: $title, updatedAt: $updatedAt)';
}
