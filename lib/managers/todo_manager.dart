import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class TodoManager {
  List<Task> tasks = [];

  bool addTask(String title) {
    if (title.trim().isEmpty) {
      return false;
    }
    tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    ));
    return true;
  }

  bool addTaskWithPriority(String title, TaskPriority priority) {
    if (title.trim().isEmpty) return false;
    tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      priority: priority,
    ));
    return true;
  }

  bool deleteTask(String id) {
    final initialLength = tasks.length;
    tasks.removeWhere((t) => t.id == id);
    return tasks.length < initialLength;
  }

  void toggleTaskCompletion(String id) {
    final task = tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      task.completedAt = DateTime.now();
    } else {
      task.completedAt = null;
    }
  }

  /// Tìm kiếm task theo tiêu đề, ghi chú hoặc công ty
  List<Task> searchTasks(String keyword) {
    if (keyword.trim().isEmpty) {
      return tasks;
    }
    final lowerKeyword = keyword.toLowerCase();
    return tasks
        .where((task) =>
            task.title.toLowerCase().contains(lowerKeyword) ||
            task.notes.toLowerCase().contains(lowerKeyword))
        .toList();
  }

  /// Tìm kiếm task theo trạng thái
  List<Task> filterByCompletion(bool isCompleted) {
    return tasks.where((t) => t.isCompleted == isCompleted).toList();
  }

  /// Tìm kiếm task theo mức độ ưu tiên
  List<Task> filterByPriority(TaskPriority priority) {
    return tasks.where((t) => t.priority == priority).toList();
  }

  /// Tìm kiếm task với hạn chót
  List<Task> filterByDeadline(DateTime fromDate, DateTime toDate) {
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return !t.dueDate!.isBefore(fromDate) && !t.dueDate!.isAfter(toDate);
    }).toList();
  }

  /// Tìm kiếm task có file/ảnh đính kèm
  List<Task> searchTasksWithAttachments() {
    return tasks.where((t) => t.attachments.isNotEmpty).toList();
  }

  List<Task> getSortedTasks() {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      // Incomplete first
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      // Same completion state -> higher priority first
      if (a.priority != b.priority) return b.priority.index.compareTo(a.priority.index);
      // Both same priority: earliest due date first (nulls last)
      if (a.dueDate == null && b.dueDate == null) {
        return tasks.indexOf(a).compareTo(tasks.indexOf(b));
      }
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
  }

  int countByPriority(TaskPriority priority) =>
      tasks.where((t) => t.priority == priority).length;

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

  /// Lấy đường dẫn thư mục lưu trữ file/ảnh đính kèm
  /// Vị trí: /data/user/0/[package]/files/task_attachments/ (Android)
  /// Vị trí: /var/mobile/Containers/Data/Application/[app_id]/Documents/task_attachments/ (iOS)
  /// Vị trí: C:\Users\[user]\AppData\Local\flutter_demo\task_attachments\ (Windows)
  Future<Directory> getAttachmentsDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${docDir.path}/task_attachments');
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }
    return attachmentsDir;
  }

  /// Thêm file/ảnh đính kèm vào task
  Future<bool> addAttachmentToTask(
    String taskId,
    String fileName,
    String attachmentType, // "image" hoặc "file"
    File sourceFile,
  ) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final attachmentsDir = await getAttachmentsDirectory();
      
      // Tạo thư mục con cho từng task
      final taskAttachmentDir = Directory('${attachmentsDir.path}/$taskId');
      if (!await taskAttachmentDir.exists()) {
        await taskAttachmentDir.create(recursive: true);
      }

      // Copy file vào thư mục lưu trữ
      final destFile = File(
        '${taskAttachmentDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await sourceFile.copy(destFile.path);

      // Thêm attachment vào task
      task.attachments.add(TaskAttachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        type: attachmentType,
        filePath: destFile.path,
        addedDate: DateTime.now(),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Xóa file/ảnh đính kèm khỏi task
  Future<bool> removeAttachmentFromTask(String taskId, String attachmentId) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final attachment =
          task.attachments.firstWhere((a) => a.id == attachmentId);

      // Xóa file vật lý
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Xóa khỏi danh sách
      task.attachments.removeWhere((a) => a.id == attachmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Xóa tất cả file/ảnh của task khi xóa task
  Future<void> deleteTaskAttachments(String taskId) async {
    try {
      final attachmentsDir = await getAttachmentsDirectory();
      final taskDir = Directory('${attachmentsDir.path}/$taskId');
      if (await taskDir.exists()) {
        await taskDir.delete(recursive: true);
      }
    } catch (e) {
      // Bỏ qua lỗi
    }
  }

  Future<bool> saveToJson() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tasks.json');
      final jsonData = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await file.writeAsString(jsonData, encoding: utf8);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loadFromJson() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tasks.json');
      if (!await file.exists()) {
        return true;
      }
      final jsonString = await file.readAsString(encoding: utf8);
      final jsonData = jsonDecode(jsonString) as List;
      tasks = jsonData.map((data) => Task.fromJson(data)).toList();
      return true;
    } catch (e) {
      return false;
    }
  }
}
