// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import '../managers/todo_manager.dart';
// import '../models/task.dart';
// import '../routes/navigation_helper.dart';

// class TodoListScreen extends StatefulWidget {
//   const TodoListScreen({super.key});

//   @override
//   State<TodoListScreen> createState() => _TodoListScreenState();
// }

// class _TodoListScreenState extends State<TodoListScreen> {
//   final TodoManager manager = TodoManager();
//   final TextEditingController _taskController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//   DateTime? _selectedDueDate;
//   bool _isLoading = true;
//   TaskPriority? _filterPriority;
//   bool _filterCompleted = true;
//   bool _filterPending = true;
//   Timer? _searchDebounce;
//   List<Task> _searchResults = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//     await manager.loadFromJson();
//     setState(() => _isLoading = false);
//   }

//   Future<void> _saveData() async {
//     await manager.saveToJson();
//   }

//   void _addTask() {
//     final title = _taskController.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('❌ Vui lòng nhập công việc')),
//       );
//       return;
//     }
//     if (manager.addTask(title)) {
//       if (_selectedDueDate != null && manager.tasks.isNotEmpty) {
//         manager.tasks.last.dueDate = _selectedDueDate;
//         _selectedDueDate = null;
//       }
//       _taskController.clear();
//       setState(() {});
//       _saveData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Thêm công việc thành công')),
//       );
//     }
//   }

//   Future<void> _showAddTaskDialog() async {
//     final titleCtrl = TextEditingController();
//     DateTime? due;
//     TaskPriority selectedPriority = TaskPriority.medium;

//     await showDialog<void>(
//       context: context,
//       builder: (context) => StatefulBuilder(builder: (context, setSt) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title:
//               const Text('Thêm công việc mới', style: TextStyle(fontWeight: FontWeight.bold)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: titleCtrl,
//                 decoration: InputDecoration(
//                   labelText: 'Công việc',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   prefixIcon: const Icon(Icons.task_alt),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2000),
//                           lastDate: DateTime(2100),
//                         );
//                         if (picked != null) {
//                           final time = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.now(),
//                           );
//                           if (time != null) {
//                             setSt(() {
//                               due = DateTime(picked.year, picked.month, picked.day,
//                                   time.hour, time.minute);
//                             });
//                           } else {
//                             setSt(() {
//                               due = DateTime(picked.year, picked.month, picked.day);
//                             });
//                           }
//                         }
//                       },
//                       icon: const Icon(Icons.calendar_today),
//                       label: const Text('Chọn hạn'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               if (due != null)
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     'Hạn: ${due!.toLocal().toString().split('.')[0]}',
//                     style: TextStyle(
//                         color: Colors.blue[700], fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Text('Mức độ: ', style: TextStyle(fontWeight: FontWeight.w500)),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: SegmentedButton<TaskPriority>(
//                       segments: TaskPriority.values.map((p) {
//                         return ButtonSegment(
//                           value: p,
//                           label: Text(p.name),
//                           icon: Icon(
//                             p == TaskPriority.high
//                                 ? Icons.priority_high
//                                 : p == TaskPriority.medium
//                                     ? Icons.equalizer
//                                     : Icons.low_priority,
//                           ),
//                         );
//                       }).toList(),
//                       selected: {selectedPriority},
//                       onSelectionChanged: (v) {
//                         setSt(() => selectedPriority = v.first);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
//             FilledButton(
//               onPressed: () {
//                 final t = titleCtrl.text.trim();
//                 if (t.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('❌ Vui lòng nhập công việc')));
//                   return;
//                 }
//                 manager.addTaskWithPriority(t, selectedPriority);
//                 if (due != null && manager.tasks.isNotEmpty) {
//                   manager.tasks.last.dueDate = due;
//                 }
//                 _saveData();
//                 setState(() {});
//                 Navigator.pop(context);
//               },
//               child: const Text('Thêm'),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   void _deleteTask(String id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
//         content: const Text('Bạn có chắc muốn xóa công việc này?\n\n(Tất cả file/ảnh đính kèm cũng sẽ bị xóa)'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Hủy'),
//           ),
//           FilledButton(
//             onPressed: () async {
//               if (manager.deleteTask(id)) {
//                 // Xóa tất cả file/ảnh đính kèm
//                 await manager.deleteTaskAttachments(id);
//                 setState(() {});
//                 _saveData();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('✅ Xóa công việc thành công')),
//                 );
//               }
//               Navigator.pop(context);
//             },
//             child: const Text('Xóa'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleTaskCompletion(String id) {
//     manager.toggleTaskCompletion(id);
//     setState(() {});
//     _saveData();
//   }

//   void _onSearchChanged(String value) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 300), () {
//       setState(() {
//         if (value.isEmpty) {
//           _searchResults = [];
//         } else {
//           _searchResults = manager.searchTasks(value);
//         }
//       });
//     });
//   }

//   Future<void> _pickAndAddImage(Task task) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         final File imageFile = File(image.path);
//         final added = await manager.addAttachmentToTask(
//           task.id,
//           image.name,
//           'image',
//           imageFile,
//         );

//         if (added) {
//           await _saveData();
//           setState(() {});
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('✅ Thêm ảnh thành công')),
//             );
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('❌ Không thể thêm ảnh')),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Lỗi: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _pickAndAddFile(Task task) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//         allowMultiple: false,
//       );

//       if (result != null && result.files.isNotEmpty) {
//         final PlatformFile platformFile = result.files.first;
//         final File file = File(platformFile.path!);
        
//         final added = await manager.addAttachmentToTask(
//           task.id,
//           platformFile.name,
//           'file',
//           file,
//         );

//         if (added) {
//           await _saveData();
//           setState(() {});
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('✅ Thêm file thành công')),
//             );
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('❌ Không thể thêm file')),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Lỗi: $e')),
//         );
//       }
//     }
//   }

//   void _showEditNotesDialog(Task task) {
//     final notesController = TextEditingController(text: task.notes);
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Chỉnh Sửa Ghi Chú', style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//           controller: notesController,
//           maxLines: 5,
//           decoration: InputDecoration(
//             hintText: 'Nhập ghi chú chi tiết...',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             prefixIcon: const Icon(Icons.notes),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Hủy'),
//           ),
//           FilledButton(
//             onPressed: () {
//               task.notes = notesController.text.trim();
//               _saveData();
//               setState(() {});
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('✅ Cập nhật ghi chú thành công')),
//               );
//             },
//             child: const Text('Lưu'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAttachmentsDialog(Task task) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text(
//           'Tệp Đính Kèm',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (task.attachments.isEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Icon(Icons.attachment_rounded, 
//                         size: 48, 
//                         color: Colors.grey[400]
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'Chưa có tệp đính kèm',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: task.attachments.length,
//                     itemBuilder: (context, index) {
//                       final attachment = task.attachments[index];
//                       return ListTile(
//                         leading: Icon(
//                           attachment.type == 'image'
//                               ? Icons.image
//                               : Icons.description,
//                           color: Colors.blue,
//                         ),
//                         title: Text(
//                           attachment.name,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         subtitle: Text(
//                           attachment.addedDate.toLocal().toString().split('.')[0],
//                           style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () async {
//                             final confirmed = await showDialog<bool>(
//                               context: context,
//                               builder: (ctx) => AlertDialog(
//                                 title: const Text('Xác nhận xóa'),
//                                 content: const Text('Bạn có chắc muốn xóa file này?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(ctx, false),
//                                     child: const Text('Hủy'),
//                                   ),
//                                   FilledButton(
//                                     onPressed: () => Navigator.pop(ctx, true),
//                                     child: const Text('Xóa'),
//                                   ),
//                                 ],
//                               ),
//                             );
                            
//                             if (confirmed == true) {
//                               await manager.removeAttachmentFromTask(
//                                 task.id,
//                                 attachment.id,
//                               );
//                               _saveData();
//                               setState(() {});
//                               if (context.mounted) Navigator.pop(context);
//                             }
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       children: [
//                         Icon(Icons.info, size: 16, color: Colors.blue),
//                         SizedBox(width: 8),
//                         Text(
//                           'Thông tin lưu trữ',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Các tệp đính kèm được lưu tại:\n'
//                       'ApplicationDocumentsDirectory/task_attachments/${task.id}/',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       _pickAndAddImage(task);
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.image),
//                     label: const Text('Thêm Ảnh'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       _pickAndAddFile(task);
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Thêm File'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Đóng'),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Task> _getDisplayedTasks() {
//     // Nếu có tìm kiếm, dùng kết quả tìm kiếm, nếu không dùng danh sách gốc
//     final baseList = _searchResults.isNotEmpty ? _searchResults : manager.getSortedTasks();
    
//     return baseList.where((task) {
//       if (_filterPriority != null && task.priority != _filterPriority) {
//         return false;
//       }
//       if (!_filterCompleted && task.isCompleted) return false;
//       if (!_filterPending && !task.isCompleted) return false;
//       return true;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayedTasks = _getDisplayedTasks();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ghi Chú',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // Input Task
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _taskController,
//                           decoration: InputDecoration(
//                             hintText: 'Nhập công việc cần làm...',
//                             prefixIcon: const Icon(Icons.add_task),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             contentPadding:
//                                 const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onSubmitted: (_) => _addTask(),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       FloatingActionButton.extended(
//                         onPressed: _showAddTaskDialog,
//                         icon: const Icon(Icons.add),
//                         label: const Text('Thêm'),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Search Field
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                   child: StatefulBuilder(
//                     builder: (context, setState) => TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         _onSearchChanged(value);
//                         setState(() {}); // Update suffix icon
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Tìm kiếm công việc hoặc ghi chú...',
//                         prefixIcon: const Icon(Icons.search),
//                         suffixIcon: _searchController.text.isNotEmpty
//                             ? IconButton(
//                                 icon: const Icon(Icons.clear),
//                                 onPressed: () {
//                                   _searchController.clear();
//                                   this.setState(() => _searchResults = []);
//                                   setState(() {}); // Update suffix icon
//                                 },
//                               )
//                             : null,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Stats Cards - Compact Row
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: _buildCompactStatCard(
//                           title: 'Tổng',
//                           count: manager.tasks.length,
//                           icon: Icons.assignment,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _buildCompactStatCard(
//                           title: 'Chưa',
//                           count: manager.pendingCount,
//                           icon: Icons.pending_actions,
//                           color: Colors.orange,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: _buildCompactStatCard(
//                           title: 'Xong',
//                           count: manager.completedCount,
//                           icon: Icons.check_circle,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 // Filter Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Bộ lọc',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                       const SizedBox(height: 6),
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             FilterChip(
//                               label: const Text('Cao'),
//                               selected: _filterPriority == TaskPriority.high,
//                               onSelected: (selected) {
//                                 setState(() {
//                                   _filterPriority =
//                                       selected ? TaskPriority.high : null;
//                                 });
//                               },
//                               backgroundColor: Colors.red[50],
//                               selectedColor: Colors.red[200],
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                             ),
//                             const SizedBox(width: 6),
//                             FilterChip(
//                               label: const Text('TB'),
//                               selected: _filterPriority == TaskPriority.medium,
//                               onSelected: (selected) {
//                                 setState(() {
//                                   _filterPriority =
//                                       selected ? TaskPriority.medium : null;
//                                 });
//                               },
//                               backgroundColor: Colors.orange[50],
//                               selectedColor: Colors.orange[200],
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                             ),
//                             const SizedBox(width: 6),
//                             FilterChip(
//                               label: const Text('Thấp'),
//                               selected: _filterPriority == TaskPriority.low,
//                               onSelected: (selected) {
//                                 setState(() {
//                                   _filterPriority =
//                                       selected ? TaskPriority.low : null;
//                                 });
//                               },
//                               backgroundColor: Colors.blue[50],
//                               selectedColor: Colors.blue[200],
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                             ),
//                             const SizedBox(width: 6),
//                             FilterChip(
//                               label: const Text('Chưa'),
//                               selected: _filterPending,
//                               onSelected: (selected) {
//                                 setState(() => _filterPending = selected);
//                               },
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                             ),
//                             const SizedBox(width: 6),
//                             FilterChip(
//                               label: const Text('Xong'),
//                               selected: _filterCompleted,
//                               onSelected: (selected) {
//                                 setState(() => _filterCompleted = selected);
//                               },
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 // Task List
//                 Expanded(
//                   child: displayedTasks.isEmpty
//                       ? _buildEmptyState()
//                       : ReorderableListView(
//                           onReorder: (oldIndex, newIndex) async {
//                             if (newIndex > oldIndex) newIndex -= 1;
//                             final moved = manager.tasks.removeAt(oldIndex);
//                             manager.tasks.insert(newIndex, moved);
//                             await _saveData();
//                             setState(() {});
//                           },
//                           children: List.generate(
//                             displayedTasks.length,
//                             (index) {
//                               final task = displayedTasks[index];
//                               return _buildTaskCard(task);
//                             },
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildCompactStatCard({
//     required String title,
//     required int count,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(icon, color: color, size: 16),
//           const SizedBox(width: 4),
//           Flexible(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$count',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 9,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMD3StatCard({
//     required String title,
//     required int count,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: color.withOpacity(0.1),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 18),
//             const SizedBox(height: 2),
//             Text(
//               '$count',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 1),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     return Card(
//       key: ValueKey(task.id),
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: task.isCompleted ? Colors.grey[50] : Colors.white,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: task.isCompleted ? Colors.grey[200]! : Colors.grey[200]!,
//           ),
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           leading: Checkbox(
//             value: task.isCompleted,
//             onChanged: (_) => _toggleTaskCompletion(task.id),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//           ),
//           title: Text(
//             task.title,
//             style: TextStyle(
//               decoration: task.isCompleted ? TextDecoration.lineThrough : null,
//               color: task.isCompleted ? Colors.grey[500] : Colors.black87,
//               fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w600,
//               fontSize: 15,
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 6),
//               if (task.dueDate != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.access_time,
//                         size: 14,
//                         color:
//                             task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
//                                 ? Colors.red
//                                 : Colors.grey[600],
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           'Hạn: ${task.dueDate!.toLocal().toString().split('.')[0]}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: task.dueDate!.isBefore(DateTime.now()) &&
//                                     !task.isCompleted
//                                 ? Colors.red
//                                 : Colors.grey[600],
//                             fontWeight: task.dueDate!.isBefore(DateTime.now()) &&
//                                     !task.isCompleted
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (task.completedAt != null && task.isCompleted)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         size: 14,
//                         color: Colors.green[600],
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           'Xong lúc: ${task.completedAt!.toLocal().toString().split('.')[0]}',
//                           style: TextStyle(fontSize: 11, color: Colors.green[700]),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (task.attachments.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.attach_file,
//                         size: 14,
//                         color: Colors.blue[600],
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${task.attachments.length} file đính kèm',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.blue[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (task.notes.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.notes,
//                         size: 14,
//                         color: Colors.purple[600],
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           task.notes,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.purple[700],
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//           trailing: SizedBox(
//             width: 96,
//             child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: task.priority == TaskPriority.high
//                       ? Colors.red[100]
//                       : task.priority == TaskPriority.medium
//                           ? Colors.orange[100]
//                           : Colors.blue[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: task.priority == TaskPriority.high
//                         ? Colors.red[300]!
//                         : task.priority == TaskPriority.medium
//                             ? Colors.orange[300]!
//                             : Colors.blue[300]!,
//                   ),
//                 ),
//                 child: Text(
//                   task.priority == TaskPriority.high
//                       ? 'HIGH'
//                       : task.priority == TaskPriority.medium
//                           ? 'MEDIUM'
//                           : 'LOW',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: task.priority == TaskPriority.high
//                         ? Colors.red[700]
//                         : task.priority == TaskPriority.medium
//                             ? Colors.orange[700]
//                             : Colors.blue[700],
//                   ),
//                 ),
//               ),
//               PopupMenuButton(
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     onTap: () => _showEditNotesDialog(task),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.notes, size: 18),
//                         SizedBox(width: 8),
//                         Text('Ghi chú'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     onTap: () => _showAttachmentsDialog(task),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.attach_file, size: 18),
//                         SizedBox(width: 8),
//                         Text('Tệp đính kèm'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuDivider(),
//                   PopupMenuItem(
//                     onTap: () => _deleteTask(task.id),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.delete, size: 18, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text('Xóa', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                 ],
//                 icon: const Icon(Icons.more_vert, size: 18),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(minWidth: 24),
//               ),
//             ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.task_alt,
//               size: 60,
//               color: Colors.blue[300],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Không có công việc nào',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Hãy thêm một công việc mới để bắt đầu',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _taskController.dispose();
//     _searchController.dispose();
//     _searchDebounce?.cancel();
//     super.dispose();
//   }
// }
