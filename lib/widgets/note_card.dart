// ============================================================
// NOTE CARD WIDGET
// ============================================================
// Card hiển thị một note trong danh sách Home.
// Hiển thị: tiêu đề, nội dung preview, thumbnail ảnh/vẽ,
//           badge file đính kèm, thời gian cập nhật.
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/image_utils.dart';

/// Card hiển thị thông tin tóm tắt của một Note
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      // Hero tag dùng cho Hero animation khi chuyển sang chi tiết
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Title + Delete button ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.trim().isEmpty ? 'Untitled' : note.title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Delete button nhỏ gọn
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: cs.error, size: 18),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),

              // ── Row 2: Content preview ──
              if (note.content.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  note.content.length > AppConstants.contentPreviewLength
                      ? '${note.content.substring(0, AppConstants.contentPreviewLength)}…'
                      : note.content,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ── Row 3: Image thumbnail ──
              if (note.imagePath != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageFromPath(
                    note.imagePath!,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorPlaceholder: Container(
                      height: 90,
                      color: cs.surfaceContainerHighest,
                      child: Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: cs.outline)),
                    ),
                  ),
                ),
              ],

              // ── Row 4: Drawing thumbnail ──
              if (note.drawingPath != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 72,
                    width: double.infinity,
                    color: Colors.white,
                    child: imageFromPath(
                      note.drawingPath!,
                      fit: BoxFit.contain,
                      errorPlaceholder: _AttachBadge(
                        icon: Icons.gesture_rounded,
                        label: 'Drawing attached',
                        cs: cs,
                        tt: tt,
                      ),
                    ),
                  ),
                ),
              ],

              // ── Row 5: File badge ──
              if (note.fileName != null) ...[
                const SizedBox(height: 8),
                _AttachBadge(
                  icon: Icons.attach_file_rounded,
                  label: note.fileName!,
                  cs: cs,
                  tt: tt,
                ),
              ],

              // ── Row 6: Footer – timestamp ──
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 11, color: cs.outlineVariant),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.relative(note.updatedAt),
                    style: tt.labelSmall?.copyWith(
                      color: cs.outline,
                      fontSize: 11,
                    ),
                  ),

                  // Attachment indicator dots
                  const Spacer(),
                  if (note.imagePath != null)
                    _dot(cs.primary, context),
                  if (note.drawingPath != null)
                    _dot(cs.secondary, context),
                  if (note.fileName != null)
                    _dot(cs.tertiary, context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color, BuildContext context) => Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Badge nhỏ hiển thị attachment
class _AttachBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  const _AttachBadge({
    required this.icon,
    required this.label,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.onSecondaryContainer),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: cs.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
