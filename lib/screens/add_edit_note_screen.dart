// ============================================================
// ADD / EDIT NOTE SCREEN
// ============================================================
// Dùng cho cả 2 chế độ:
//   • Add mode  : note == null → tạo NoteModel mới
//   • Edit mode : note != null → chỉnh sửa note đã có
//
// Tính năng:
//  • TextField: tiêu đề + nội dung multiline
//  • Đính kèm ảnh từ gallery (image_picker)
//  • Đính kèm file tài liệu (file_picker)
//  • Mở màn hình vẽ tay (DrawNoteScreen)
//  • Preview ảnh / hình vẽ inline
//  • Nút remove từng attachment
//  • Validate: tiêu đề không được trống
//  • Navigator.pop với NoteModel khi Save
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/note_model.dart';
import '../services/file_service.dart';
import '../services/cloudinary_service.dart';
import '../utils/cloudinary_config.dart';
import '../utils/constants.dart';
import '../utils/image_utils.dart';
import 'draw_note_screen.dart';

class AddEditNoteScreen extends StatefulWidget {
  /// null = Add mode; non-null = Edit mode
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _fileService = FileService();
  late final CloudinaryService _cloudinary;

  // Attachment state
  String? _imagePath;
  String? _filePath;
  String? _fileName;
  String? _drawingPath;

  bool _isSaving = false;

  bool get _isEditMode => widget.note != null;

  @override
  void initState() {
    super.initState();
    _cloudinary = CloudinaryService(
      cloudName: CloudinaryConfig.cloudName,
      uploadPreset: CloudinaryConfig.uploadPreset,
    );
    // Điền dữ liệu nếu là Edit mode
    if (_isEditMode) {
      final n = widget.note!;
      _titleCtrl.text = n.title;
      _contentCtrl.text = n.content;
      _imagePath = n.imagePath;
      _filePath = n.filePath;
      _fileName = n.fileName;
      _drawingPath = n.drawingPath;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // ATTACHMENT HANDLERS
  // ────────────────────────────────────────────

  Future<void> _pickImage() async {
    final path = await _fileService.pickImage();
    if (!mounted) return;
    if (path == null) return;

    // Upload to Cloudinary and store URL
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
      final url = await _cloudinary.uploadFile(File(path));
      if (!mounted) return;
      setState(() => _imagePath = url);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded')));
    } catch (e) {
      // Fallback to local path if upload fails
      if (!mounted) return;
      setState(() => _imagePath = path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _pickFile() async {
    final result = await _fileService.pickFile();
    if (!mounted) return;
    if (result == null) return;

    final path = result['path'] as String?;
    final name = result['name'] as String?;
    if (path == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading file...')));
      final url = await _cloudinary.uploadFile(File(path));
      if (!mounted) return;
      setState(() {
        _filePath = url;
        _fileName = name ?? url.split('/').last;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _filePath = path;
        _fileName = name;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _openDraw() async {
    final path = await Navigator.push<String>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, sec) =>
            DrawNoteScreen(existingPath: _drawingPath),
        transitionsBuilder: (_, anim, sec, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: AppConstants.shortAnim,
      ),
    );
    if (path != null && mounted) setState(() => _drawingPath = path);
  }

  // ────────────────────────────────────────────
  // SAVE
  // ────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final NoteModel result;

    if (_isEditMode) {
      // Edit mode: tạo NoteModel mới với cùng ID và createdAt
      result = NoteModel(
        id: widget.note!.id,
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        createdAt: widget.note!.createdAt,
        updatedAt: now,
        imagePath: _imagePath,
        filePath: _filePath,
        fileName: _fileName,
        drawingPath: _drawingPath,
      );
    } else {
      // Add mode: tạo NoteModel hoàn toàn mới
      result = NoteModel(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
        imagePath: _imagePath,
        filePath: _filePath,
        fileName: _fileName,
        drawingPath: _drawingPath,
      );
    }

    // Trả note về màn hình gọi thông qua Navigator.pop
    if (mounted) Navigator.pop(context, result);
  }

  // ────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Note' : 'New Note'),
        actions: [
          // Save button trong AppBar (dễ nhấn với 1 tay)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save'),
                  ),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            // ── Title ──
            TextFormField(
              controller: _titleCtrl,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter note title…',
                prefixIcon: const Icon(Icons.title_rounded),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),

            const SizedBox(height: 14),

            // ── Content ──
            TextFormField(
              controller: _contentCtrl,
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Write your thoughts here…',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.notes_rounded),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              minLines: 7,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 28),

            // ── Attachments header ──
            Text(
              'ATTACHMENTS',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // ── Action chips ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionChip(
                  icon: Icons.photo_library_outlined,
                  label: 'Photo',
                  isActive: _imagePath != null,
                  onTap: _pickImage,
                ),
                _ActionChip(
                  icon: Icons.attach_file_rounded,
                  label: 'Document',
                  isActive: _filePath != null,
                  onTap: _pickFile,
                ),
                _ActionChip(
                  icon: Icons.gesture_rounded,
                  label: 'Draw',
                  isActive: _drawingPath != null,
                  onTap: _openDraw,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Image preview ──
            if (_imagePath != null)
                      _PreviewCard(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageFromPath(
                                _imagePath!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorPlaceholder: _broken(cs, 'Image not found'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: _RemoveBtn(
                                  onTap: () => setState(() => _imagePath = null)),
                            ),
                          ],
                        ),
                      ),

            // ── Drawing preview ──
            if (_drawingPath != null)
              _PreviewCard(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: imageFromPath(
                          _drawingPath!,
                          height: 180,
                          fit: BoxFit.contain,
                          errorPlaceholder: _broken(cs, 'Drawing not found'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _RemoveBtn(
                          onTap: () => setState(() => _drawingPath = null)),
                    ),
                  ],
                ),
              ),

            // ── File indicator ──
            if (_fileName != null)
              _PreviewCard(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description_rounded,
                          size: 28, color: cs.onSecondaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName!,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Document attached',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: cs.onSecondaryContainer,
                        onPressed: () => setState(() {
                          _filePath = null;
                          _fileName = null;
                        }),
                        tooltip: 'Remove file',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 100), // space for keyboard
          ],
        ),
      ),
    );
  }

  /// Placeholder khi không tải được file
  Widget _broken(ColorScheme cs, String msg) => Container(
        height: 80,
        color: cs.surfaceContainerHighest,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, color: cs.outline),
            const SizedBox(width: 8),
            Text(msg,
                style: TextStyle(
                    color: cs.outline, fontSize: 12)),
          ],
        ),
      );
}

// ────────────────────────────────────────────
// SUB-WIDGETS
// ────────────────────────────────────────────

/// Chip nút hành động attachment
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = cs.primaryContainer;
    final inactiveColor = cs.surfaceContainerHighest;

    return AnimatedContainer(
      duration: AppConstants.shortAnim,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(AppConstants.chipRadius),
        border: Border.all(
          color: isActive ? cs.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.chipRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isActive ? cs.primary : cs.onSurfaceVariant,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle_rounded, size: 14, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Container bọc preview attachment
class _PreviewCard extends StatelessWidget {
  final Widget child;
  const _PreviewCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: child,
    );
  }
}

/// Nút tròn nhỏ để xóa attachment
class _RemoveBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
      ),
    );
  }
}
