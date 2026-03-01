// ============================================================
// NOTE DETAIL SCREEN
// ============================================================
// Màn hình xem chi tiết một ghi chú.
//
// Tính năng:
//  • Hiển thị đầy đủ: tiêu đề, nội dung, ngày tạo/sửa
//  • Hiển thị ảnh toàn chiều rộng (nếu có)
//  • Hiển thị hình vẽ tay (nếu có)
//  • Hiển thị thông tin file đính kèm (nếu có)
//  • Nút Edit → navigate sang AddEditNoteScreen
//  • Khi save xong trong Edit → Navigator.pop về Home với note đã cập nhật
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import 'add_edit_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;
  final int index; // để Home biết index nào cần cập nhật

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.index,
  });

  // ────────────────────────────────────────────
  // NAVIGATE TO EDIT
  // ────────────────────────────────────────────

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.push<NoteModel>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, sec) => AddEditNoteScreen(note: note),
        transitionsBuilder: (_, anim, sec, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
          return SlideTransition(position: slide, child: child);
        },
        transitionDuration: AppConstants.normalAnim,
      ),
    );

    // Trả kết quả edit về Home (nếu có thay đổi)
    if (updated != null && context.mounted) {
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit note',
            onPressed: () => _edit(context),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Text(
              note.title.trim().isEmpty ? 'Untitled' : note.title,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            // ── Metadata ──
            _MetaRow(
              icon: Icons.add_circle_outline_rounded,
              text: 'Created  ${DateFormatter.full(note.createdAt)}',
            ),
            if (note.updatedAt.difference(note.createdAt).inSeconds > 5) ...[
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.update_rounded,
                text: 'Edited  ${DateFormatter.full(note.updatedAt)}',
              ),
            ],

            const SizedBox(height: 20),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 16),

            // ── Content ──
            note.content.trim().isEmpty
                ? Text(
                    'No content.',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : SelectableText(
                    note.content,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurface,
                      height: 1.75,
                    ),
                  ),

            // ── Image ──
            if (note.imagePath != null) ...[
              const SizedBox(height: 28),
              _SectionLabel(label: 'Photo', icon: Icons.image_outlined),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(note.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, _) => _brokenPlaceholder(cs),
                ),
              ),
            ],

            // ── Drawing ──
            if (note.drawingPath != null) ...[
              const SizedBox(height: 28),
              _SectionLabel(
                  label: 'Handwriting', icon: Icons.gesture_rounded),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(note.drawingPath!),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, e, _) => _brokenPlaceholder(cs),
                  ),
                ),
              ),
            ],

            // ── File ──
            if (note.fileName != null) ...[
              const SizedBox(height: 28),
              _SectionLabel(
                  label: 'Attachment', icon: Icons.attach_file_rounded),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description_rounded,
                        size: 36, color: cs.onSecondaryContainer),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.fileName!,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Document attached',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: cs.onSecondaryContainer.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),

      // ── Floating Edit Button ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context),
        tooltip: 'Edit',
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _brokenPlaceholder(ColorScheme cs) => Container(
        height: 100,
        color: cs.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: cs.outline, size: 36),
        ),
      );
}

// ────────────────────────────────────────────
// SMALL WIDGETS
// ────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 13, color: cs.outline),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.outline,
                ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
        ),
      ],
    );
  }
}
