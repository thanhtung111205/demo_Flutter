// ============================================================
// HOME SCREEN
// ============================================================
// Màn hình chính – hiển thị danh sách tất cả ghi chú.
//
// Tính năng:
//  • AnimatedList: animation thêm/xóa item mượt mà
//  • EmptyState khi chưa có note
//  • FAB với scale animation để thêm note
//  • Navigator.push với PageRouteBuilder (slide + fade)
//  • AlertDialog xác nhận trước khi xóa
//  • Dark/Light mode support thông qua colorScheme
// ============================================================

import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/file_service.dart';
import '../services/note_service.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Services ──────────────────────────────────
  final _noteService = NoteService();
  final _fileService = FileService();

  // ── State ─────────────────────────────────────
  final List<NoteModel> _notes = [];
  bool _isLoading = true;

  // ── Search ────────────────────────────────────
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  // ── AnimatedList key – dùng để gọi insertItem / removeItem ──
  final _listKey = GlobalKey<AnimatedListState>();

  // ── FAB animation ─────────────────────────────
  late final AnimationController _fabCtrl;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut);
    _loadNotes();
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // LOAD
  // ────────────────────────────────────────────

  Future<void> _loadNotes() async {
    final notes = await _noteService.loadNotes();
    if (!mounted) return;
    setState(() {
      _notes
        ..clear()
        ..addAll(notes);
      _isLoading = false;
    });
    _fabCtrl.forward();
  }

  // ────────────────────────────────────────────
  // NAVIGATION – Add Note
  // ────────────────────────────────────────────

  Future<void> _goToAddNote() async {
    // Slide từ dưới lên + fade – Material 3 bottom sheet feel
    final newNote = await Navigator.push<NoteModel>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, sec) => const AddEditNoteScreen(),
        transitionsBuilder: (_, anim, sec, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        transitionDuration: AppConstants.normalAnim,
      ),
    );

    if (newNote == null) return;

    // Lưu vào storage
    await _noteService.addNote(newNote);

    // Thêm vào đầu danh sách và trigger rebuild để ẩn EmptyStateWidget
    setState(() => _notes.insert(0, newNote));
    // Thông báo cho AnimatedList biết có item mới ở index 0
    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 400),
    );
  }

  // ────────────────────────────────────────────
  // NAVIGATION – Note Detail / Edit
  // ────────────────────────────────────────────

  Future<void> _goToDetail(int index) async {
    // Slide từ phải sang – horizontal page transition
    final updatedNote = await Navigator.push<NoteModel>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, sec) =>
            NoteDetailScreen(note: _notes[index], index: index),
        transitionsBuilder: (_, anim, sec, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(anim),
              child: child,
            ),
          );
        },
        transitionDuration: AppConstants.normalAnim,
      ),
    );

    if (updatedNote == null) return;

    // Cập nhật storage và UI
    await _noteService.updateNote(updatedNote);

    // Tìm note theo ID (vì index có thể thay đổi nếu sort lại)
    final idx = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (idx != -1) setState(() => _notes[idx] = updatedNote);
  }

  // ────────────────────────────────────────────
  // DELETE
  // ────────────────────────────────────────────

  /// Xóa note ngay (dùng cho swipe-to-delete) + hiện SnackBar undo
  Future<void> _deleteNote(int index) async {
    final note = _notes[index];

    // Lưu snapshot để undo
    final snapshot = note;
    final snapshotIndex = index;

    // Xóa khỏi storage
    await _noteService.deleteNote(note.id);
    await Future.wait([
      _fileService.deleteFile(note.imagePath),
      _fileService.deleteFile(note.drawingPath),
      _fileService.deleteFile(note.filePath),
    ]);

    // Cập nhật danh sách và AnimatedList
    setState(() => _notes.removeAt(index));
    _listKey.currentState?.removeItem(
      index,
      (ctx, anim) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: FadeTransition(
          opacity: anim,
          child: NoteCard(
            note: snapshot,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"${snapshot.title.isEmpty ? 'Untitled' : snapshot.title}" deleted',
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              // Khôi phục note vào storage và danh sách
              await _noteService.addNote(snapshot);
              setState(() => _notes.insert(snapshotIndex, snapshot));
              _listKey.currentState?.insertItem(
                snapshotIndex,
                duration: const Duration(milliseconds: 300),
              );
            },
          ),
        ),
      );
  }

  Future<void> _confirmDelete(int index) async {
    final note = _notes[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_forever_rounded,
            color: Theme.of(ctx).colorScheme.error, size: 32),
        title: const Text('Delete Note?'),
        content: Text(
          '"${note.title.isEmpty ? 'Untitled' : note.title}"\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Xóa khỏi storage
    await _noteService.deleteNote(note.id);
    // Xóa file đính kèm
    await Future.wait([
      _fileService.deleteFile(note.imagePath),
      _fileService.deleteFile(note.drawingPath),
      _fileService.deleteFile(note.filePath),
    ]);

    // Giữ reference để dùng trong animation builder
    final removedNote = _notes[index];
    setState(() => _notes.removeAt(index));

    // AnimatedList tạo animation exit
    _listKey.currentState?.removeItem(
      index,
      (ctx, anim) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: FadeTransition(
          opacity: anim,
          child: NoteCard(
            note: removedNote,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }

  // ────────────────────────────────────────────
  // SEARCH HELPERS
  // ────────────────────────────────────────────

  List<NoteModel> get _filteredNotes {
    if (_searchQuery.trim().isEmpty) return _notes;
    final q = _searchQuery.trim().toLowerCase();
    return _notes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  Widget _buildSearchResults(ColorScheme cs, TextTheme tt) {
    final results = _filteredNotes;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: cs.outline),
            const SizedBox(height: 12),
            Text(
              'No notes found for\n"$_searchQuery"',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${results.length} result${results.length > 1 ? 's' : ''}',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 120),
            itemCount: results.length,
            itemBuilder: (ctx, i) {
              final note = results[i];
              final realIdx = _notes.indexWhere((n) => n.id == note.id);
              return NoteCard(
                note: note,
                onTap: () => _goToDetail(realIdx),
                onDelete: () => _confirmDelete(realIdx),
              );
            },
          ),
        ),
      ],
    );
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

      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: tt.titleMedium,
                decoration: InputDecoration(
                  hintText: 'Search by title…',
                  border: InputBorder.none,
                  hintStyle:
                      tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConstants.appName,
                    style: tt.titleLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _isLoading
                          ? 'Loading…'
                          : _notes.isEmpty
                              ? 'Start writing!'
                              : '${_notes.length} note${_notes.length > 1 ? 's' : ''}',
                      key: ValueKey(_notes.length),
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close search',
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchCtrl.clear();
              }),
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search notes',
              onPressed: () => setState(() => _isSearching = true),
            ),
          const SizedBox(width: 4),
        ],
      ),

      // ── Body ──
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSearching
              ? _buildSearchResults(cs, tt)
              : Stack(
              children: [
                // AnimatedList (luôn mount để tránh re-create khi từ 0→1 note)
                AnimatedList(
                  key: _listKey,
                  padding: const EdgeInsets.only(top: 8, bottom: 120),
                  initialItemCount: _notes.length,
                  itemBuilder: (ctx, index, animation) {
                    // Mỗi item slide + fade từ phải vào khi được insert
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.4, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: animation,
                        child: Dismissible(
                          key: ValueKey(_notes[index].id),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (_) async {
                            final note = _notes[index];
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                icon: Icon(
                                  Icons.delete_forever_rounded,
                                  color: Theme.of(ctx).colorScheme.error,
                                  size: 32,
                                ),
                                title: const Text('Delete Note?'),
                                content: Text(
                                  '"${note.title.isEmpty ? 'Untitled' : note.title}"\n\nThis action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(ctx).colorScheme.error,
                                      foregroundColor:
                                          Theme.of(ctx).colorScheme.onError,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (_) => _deleteNote(index),
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 24),
                            child: Icon(
                              Icons.delete_sweep_rounded,
                              color:
                                  Theme.of(context).colorScheme.onError,
                              size: 28,
                            ),
                          ),
                          child: NoteCard(
                            note: _notes[index],
                            onTap: () => _goToDetail(index),
                            onDelete: () => _confirmDelete(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Empty state nằm trên khi list trống
                if (_notes.isEmpty) const EmptyStateWidget(),
              ],
            ),

      // ── FAB ──
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: _goToAddNote,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Note',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
