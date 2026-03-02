// ============================================================
// DRAW NOTE SCREEN – Freehand Drawing Canvas
// ============================================================
// Màn hình vẽ tay sử dụng CustomPainter + GestureDetector.
//
// Tính năng:
//  • Vẽ tự do với nhiều màu sắc
//  • Điều chỉnh độ dày nét vẽ bằng Slider
//  • Tẩy (Eraser) mode
//  • Undo từng stroke
//  • Clear tất cả
//  • Lưu canvas thành ảnh PNG (dùng RepaintBoundary + toImage)
//  • Navigator.pop với đường dẫn ảnh PNG
//
// Cơ chế lưu ảnh:
//  RepaintBoundary → RenderRepaintBoundary.toImage() → Uint8List PNG
//  → FileService.saveDrawing() → /files/drawings/draw_xxx.png
// ============================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/file_service.dart';
import '../utils/constants.dart';

class DrawNoteScreen extends StatefulWidget {
  /// Đường dẫn đến drawing cũ (nếu đang edit, không dùng để load lại)
  final String? existingPath;

  const DrawNoteScreen({super.key, this.existingPath});

  @override
  State<DrawNoteScreen> createState() => _DrawNoteScreenState();
}

class _DrawNoteScreenState extends State<DrawNoteScreen> {
  // ── Drawing data ──────────────────────────────
  /// Danh sách tất cả các stroke đã hoàn thành
  final List<_Stroke> _strokes = [];

  /// Stroke đang được vẽ (chưa nhấc tay)
  _Stroke? _activeStroke;

  // ── Tool settings ─────────────────────────────
  Color _penColor = Colors.black;
  double _penWidth = 3.5;
  bool _isEraserOn = false;

  // ── Key để capture canvas thành ảnh ──────────
  final _canvasKey = GlobalKey();

  bool _isSaving = false;

  final _fileService = FileService();

  // ── Color palette ─────────────────────────────
  static const _palette = [
    Colors.black,
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFB8C00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFF00ACC1), // Cyan
    Color(0xFF6D4C41), // Brown
  ];

  // ────────────────────────────────────────────
  // GESTURE HANDLERS
  // ────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _activeStroke = _Stroke(
        points: [d.localPosition],
        color: _isEraserOn ? Colors.white : _penColor,
        width: _isEraserOn ? 22.0 : _penWidth,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_activeStroke == null) return;
    setState(() {
      _activeStroke!.points.add(d.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_activeStroke == null) return;
    setState(() {
      _strokes.add(_activeStroke!);
      _activeStroke = null;
    });
  }

  // ────────────────────────────────────────────
  // SAVE
  // ────────────────────────────────────────────

  Future<void> _saveDrawing() async {
    if (_strokes.isEmpty) {
      Navigator.pop(context); // Không lưu nếu chưa vẽ gì
      return;
    }

    setState(() => _isSaving = true);

    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Canvas not found');

      // Render canvas ra image với pixel ratio 2.0 (Retina quality)
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to encode PNG');

      final pngBytes = byteData.buffer.asUint8List();
      final savedPath = await _fileService.saveDrawing(pngBytes);

      if (mounted) Navigator.pop(context, savedPath);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // ────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Draw Note'),
        actions: [
          // Undo
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
            onPressed:
                _strokes.isEmpty ? null : () => setState(() => _strokes.removeLast()),
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear all',
            onPressed: _strokes.isEmpty
                ? null
                : () => showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Canvas?'),
                        content:
                            const Text('All drawings will be removed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ).then((v) {
                      if (v == true) setState(() => _strokes.clear());
                    }),
          ),
          // Save
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : FilledButton.icon(
                    onPressed: _saveDrawing,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save'),
                  ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Drawing Canvas ──────────────────
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  color: Colors.white,
                  child: CustomPaint(
                    painter: _CanvasPainter(
                      strokes: _strokes,
                      activeStroke: _activeStroke,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // ── Toolbar ─────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                  top: BorderSide(color: cs.outlineVariant, width: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stroke width slider
                Row(
                  children: [
                    Icon(Icons.line_weight_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                    Expanded(
                      child: Slider(
                        value: _penWidth,
                        min: 1.0,
                        max: 16.0,
                        divisions: 15,
                        onChanged: _isEraserOn
                            ? null
                            : (v) => setState(() => _penWidth = v),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        _penWidth.toStringAsFixed(0),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Color palette + eraser
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ..._palette.map((c) => _ColorDot(
                          color: c,
                          isSelected: !_isEraserOn && _penColor == c,
                          onTap: () => setState(() {
                            _penColor = c;
                            _isEraserOn = false;
                          }),
                        )),
                    // Eraser
                    _EraserBtn(
                      isActive: _isEraserOn,
                      onTap: () =>
                          setState(() => _isEraserOn = !_isEraserOn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────
// DATA
// ────────────────────────────────────────────

/// Một stroke = tập hợp điểm liên tiếp với cùng màu/độ dày
class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _Stroke({required this.points, required this.color, required this.width});
}

// ────────────────────────────────────────────
// CUSTOM PAINTER
// ────────────────────────────────────────────

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? activeStroke;

  const _CanvasPainter({required this.strokes, this.activeStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (activeStroke != null) _drawStroke(canvas, activeStroke!);
  }

  void _drawStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      // Chấm đơn khi chỉ tap
      canvas.drawCircle(stroke.points.first, stroke.width / 2,
          paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path()..moveTo(stroke.points[0].dx, stroke.points[0].dy);
    for (int i = 1; i < stroke.points.length - 1; i++) {
      // Dùng quadratic bezier để nét vẽ mượt hơn
      final mid = Offset(
        (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
        (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(
        stroke.points[i].dx,
        stroke.points[i].dy,
        mid.dx,
        mid.dy,
      );
    }
    // Điểm cuối
    path.lineTo(
      stroke.points.last.dx,
      stroke.points.last.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.strokes != strokes || old.activeStroke != activeStroke;
}

// ────────────────────────────────────────────
// TOOLBAR WIDGETS
// ────────────────────────────────────────────

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnim,
        width: isSelected ? 34 : 28,
        height: isSelected ? 34 : 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}

class _EraserBtn extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _EraserBtn({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnim,
        width: isActive ? 34 : 28,
        height: isActive ? 34 : 28,
        decoration: BoxDecoration(
          color: isActive ? cs.primaryContainer : cs.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? cs.primary : cs.outlineVariant,
            width: isActive ? 2.5 : 1.0,
          ),
        ),
        child: Icon(
          Icons.auto_fix_normal_rounded,
          size: 16,
          color: isActive ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
