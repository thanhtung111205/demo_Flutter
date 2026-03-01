enum TaskPriority { low, medium, high }

/// Lớp biểu diễn file/ảnh đính kèm trong task
class TaskAttachment {
  final String id; // ID duy nhất
  final String name; // Tên file
  final String type; // Loại "image" hoặc "file"
  final String filePath; // Đường dẫn lưu trữ cục bộ
  final DateTime addedDate;

  TaskAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.addedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'filePath': filePath,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      filePath: json['filePath'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String).toLocal(),
    );
  }
}

class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  DateTime? completedAt;
  TaskPriority priority;
  String notes; // Ghi chú chi tiết (mở rộng từ title)
  List<TaskAttachment> attachments; // Danh sách file/ảnh đính kèm

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.notes = '',
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.name,
      'notes': notes,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String).toLocal()
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String).toLocal()
          : null,
      priority: json['priority'] != null
          ? TaskPriority.values.firstWhere(
              (e) => e.name == (json['priority'] as String),
              orElse: () => TaskPriority.medium,
            )
          : TaskPriority.medium,
      notes: json['notes'] as String? ?? '',
      attachments: (json['attachments'] as List?)
              ?.map((a) => TaskAttachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
