import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

void main() {
  runApp(const StudentManagerApp());
}

class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  DateTime? completedAt;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.priority = TaskPriority.medium,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.name,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String).toLocal() : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String).toLocal() : null,
      priority: json['priority'] != null ? TaskPriority.values.firstWhere((e) => e.name == (json['priority'] as String), orElse: () => TaskPriority.medium) : TaskPriority.medium,
    );
  }
}

enum TaskPriority { low, medium, high }

class Student {
  String id;
  String name;
  double score;

  Student({
    required this.id,
    required this.name,
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'ID: $id | Tên: $name | Điểm: $score';
}

class StudentManager {
  List<Student> students = [];

  // Thêm sinh viên mới
  bool addStudent(String id, String name, double score) {
    if (students.any((s) => s.id == id)) {
      return false;
    }
    students.add(Student(id: id, name: name, score: score));
    return true;
  }

  // Xóa sinh viên theo ID
  bool deleteStudent(String id) {
    final initialLength = students.length;
    students.removeWhere((s) => s.id == id);
    return students.length < initialLength;
  }

  // Tìm kiếm sinh viên theo ID hoặc tên
  List<Student> searchStudent(String keyword) {
    return students.where((s) =>
        s.id.toLowerCase().contains(keyword.toLowerCase()) ||
        s.name.toLowerCase().contains(keyword.toLowerCase())).toList();
  }

  // Tính điểm trung bình
  double getAverageScore() {
    if (students.isEmpty) return 0;
    double sum = students.fold(0, (prev, student) => prev + student.score);
    return sum / students.length;
  }

  // Lưu danh sách sinh viên vào JSON
  Future<bool> saveToJson() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/students.json');
      final jsonData = jsonEncode(students.map((s) => s.toJson()).toList());
      await file.writeAsString(jsonData, encoding: utf8);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Đọc danh sách sinh viên từ JSON
  Future<bool> loadFromJson() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/students.json');
      if (!await file.exists()) {
        return true;
      }
      final jsonString = await file.readAsString(encoding: utf8);
      final jsonData = jsonDecode(jsonString) as List;
      students = jsonData.map((data) => Student.fromJson(data)).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  List<Student> getSortedByScore() {
    final sorted = List<Student>.from(students);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }
}

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

  List<Task> getSortedTasks() {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      // Incomplete first
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      // Same completion state -> higher priority first
      if (a.priority != b.priority) return b.priority.index.compareTo(a.priority.index);
      // Both same priority: earliest due date first (nulls last)
      if (a.dueDate == null && b.dueDate == null) return tasks.indexOf(a).compareTo(tasks.indexOf(b));
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
  }

  int countByPriority(TaskPriority priority) => tasks.where((t) => t.priority == priority).length;

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

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

class StudentManagerApp extends StatefulWidget {
  const StudentManagerApp({super.key});

  @override
  State<StudentManagerApp> createState() => _StudentManagerAppState();
}

class _StudentManagerAppState extends State<StudentManagerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/settings.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        if (data.containsKey('isDark')) {
          setState(() {
            _themeMode = data['isDark'] == true ? ThemeMode.dark : ThemeMode.light;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveTheme(bool isDark) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/settings.json');
      await file.writeAsString(jsonEncode({'isDark': isDark}));
    } catch (_) {}
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    _saveTheme(_themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Ứng Dụng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: HomeScreen(themeMode: _themeMode, onToggleTheme: _toggleTheme),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.themeMode, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng Dụng Quản Lý'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: onToggleTheme,
            tooltip: 'Chuyển giao diện',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              _buildMenuCard(
              context,
              title: '👥 Quản Lý Sinh Viên',
              description: 'Quản lý danh sách sinh viên, điểm số',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildMenuCard(
              context,
              title: '✓ Ghi Chú',
              description: 'Quản lý các công việc cần làm',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodoListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final StudentManager manager = StudentManager();
  final TextEditingController _searchController = TextEditingController();
  List<Student> _displayedStudents = [];
  bool _isLoading = true;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await manager.loadFromJson();
    setState(() {
      _displayedStudents = manager.students;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    await manager.saveToJson();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Lưu dữ liệu thành công')),
    );
  }

  void _deleteStudent(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa sinh viên này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (manager.deleteStudent(id)) {
                setState(() {
                  _displayedStudents = manager.students;
                });
                _saveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Xóa sinh viên thành công')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final scoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Sinh Viên Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sinh viên'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Điểm (0-10)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final id = idController.text.trim();
              final name = nameController.text.trim();
              final scoreText = scoreController.text.trim();

              if (id.isEmpty || name.isEmpty || scoreText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              try {
                final score = double.parse(scoreText);
                if (score < 0 || score > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Điểm phải từ 0 đến 10')),
                  );
                  return;
                }

                if (manager.addStudent(id, name, score)) {
                  setState(() {
                    _displayedStudents = manager.students;
                  });
                  _saveData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Thêm sinh viên thành công')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ ID sinh viên đã tồn tại')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Điểm phải là một số hợp lệ')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (value.isEmpty) {
          _displayedStudents = manager.students;
        } else {
          _displayedStudents = manager.searchStudent(value);
        }
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showAverageScore() {
    final average = manager.getAverageScore();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Thống Kê Điểm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lượng sinh viên: ${manager.students.length}'),
            const SizedBox(height: 8),
            Text('Tổng điểm: ${manager.students.fold<double>(0, (sum, s) => sum + s.score).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              'Điểm trung bình: ${average.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSortedList() {
    final sorted = manager.getSortedByScore();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📈 Sắp xếp theo Điểm'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) => ListTile(
              leading: Text('${index + 1}.'),
              title: Text(sorted[index].name),
              subtitle: Text('ID: ${sorted[index].id}'),
              trailing: Text('${sorted[index].score}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Danh Sách Sinh Viên'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo ID hoặc tên...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _displayedStudents.isEmpty
                      ? const Center(
                          child: Text('Không có sinh viên nào'),
                        )
                      : (_searchController.text.isEmpty
                          ? ReorderableListView(
                              onReorder: (oldIndex, newIndex) async {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final moved = manager.students.removeAt(oldIndex);
                                manager.students.insert(newIndex, moved);
                                await _saveData();
                                setState(() => _displayedStudents = manager.students);
                              },
                              children: List.generate(_displayedStudents.length, (index) {
                                final student = _displayedStudents[index];
                                return Card(
                                  key: ValueKey(student.id),
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('ID: ${student.id}'),
                                    trailing: Wrap(
                                      children: [
                                        Chip(
                                          label: Text('${student.score}'),
                                          backgroundColor: student.score >= 7 ? Colors.green[100] : Colors.orange[100],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteStudent(student.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            )
                          : ListView.builder(
                              itemCount: _displayedStudents.length,
                              itemBuilder: (context, index) {
                                final student = _displayedStudents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('ID: ${student.id}'),
                                    trailing: Wrap(
                                      children: [
                                        Chip(
                                          label: Text('${student.score}'),
                                          backgroundColor: student.score >= 7 ? Colors.green[100] : Colors.orange[100],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteStudent(student.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'stats',
            onPressed: _showAverageScore,
            tooltip: 'Thống kê',
            child: const Icon(Icons.bar_chart),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'sort',
            onPressed: _showSortedList,
            tooltip: 'Sắp xếp',
            child: const Icon(Icons.sort),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'save',
            onPressed: _saveData,
            tooltip: 'Lưu',
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showAddStudentDialog,
            tooltip: 'Thêm sinh viên',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoManager manager = TodoManager();
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;
  bool _isLoading = true;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await manager.loadFromJson();
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    await manager.saveToJson();
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Vui lòng nhập công việc')),
      );
      return;
    }
    if (manager.addTask(title)) {
      // if a due date was selected, assign it to the last task
      if (_selectedDueDate != null && manager.tasks.isNotEmpty) {
        manager.tasks.last.dueDate = _selectedDueDate;
        _selectedDueDate = null;
      }
      _taskController.clear();
      setState(() {});
      _saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Thêm công việc thành công')),
      );
    }
  }

  Future<void> _showAddTaskDialog() async {
    final titleCtrl = TextEditingController();
    DateTime? due;
    TaskPriority selectedPriority = TaskPriority.medium;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setSt) {
        return AlertDialog(
          title: const Text('Thêm công việc mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Công việc'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setSt(() {
                            due = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          });
                        } else {
                          setSt(() {
                            due = DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Chọn hạn'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(due == null ? 'Không có hạn' : due!.toLocal().toString().split('.')[0]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Mức độ: '),
                  const SizedBox(width: 12),
                  DropdownButton<TaskPriority>(
                    value: selectedPriority,
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setSt(() => selectedPriority = v);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            TextButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Vui lòng nhập công việc')));
                  return;
                }
                manager.addTaskWithPriority(t, selectedPriority);
                if (due != null && manager.tasks.isNotEmpty) manager.tasks.last.dueDate = due;
                _saveData();
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _deleteTask(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (manager.deleteTask(id)) {
                setState(() {});
                _saveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Xóa công việc thành công')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(String id) {
    manager.toggleTaskCompletion(id);
    setState(() {});
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Chú'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _showCompleted = !_showCompleted);
            },
            tooltip: _showCompleted ? 'Ẩn hoàn thành' : 'Hiển thị hoàn thành',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Input Task
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: InputDecoration(
                            hintText: 'Nhập công việc cần làm...',
                            prefixIcon: const Icon(Icons.edit),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSubmitted: (_) => _addTask(),
                        ),
                      ),
                      const SizedBox(width: 12),
                                  FloatingActionButton(
                                    mini: true,
                                    onPressed: _showAddTaskDialog,
                                    tooltip: 'Thêm',
                                    child: const Icon(Icons.add),
                                  ),
                    ],
                  ),
                ),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        title: 'Tổng cộng',
                        count: manager.tasks.length,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        title: 'Chưa làm',
                        count: manager.pendingCount,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        title: 'Hoàn thành',
                        count: manager.completedCount,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Priority Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallStat(title: 'Cao', count: manager.countByPriority(TaskPriority.high), color: Colors.red),
                      _buildSmallStat(title: 'Trung bình', count: manager.countByPriority(TaskPriority.medium), color: Colors.orange),
                      _buildSmallStat(title: 'Thấp', count: manager.countByPriority(TaskPriority.low), color: Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Task List
                Expanded(
                  child: manager.tasks.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView(
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final moved = manager.tasks.removeAt(oldIndex);
                            manager.tasks.insert(newIndex, moved);
                            await _saveData();
                            setState(() {});
                          },
                          children: List.generate(
                            manager.tasks.length,
                            (index) {
                              final task = manager.tasks[index];
                              return Card(
                                key: ValueKey(task.id),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) => _toggleTaskCompletion(task.id),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      color: task.isCompleted ? Colors.grey : Colors.black,
                                      fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành'),
                                      const SizedBox(height: 4),
                                      if (task.dueDate != null)
                                        Text('Hạn: ${task.dueDate!.toLocal().toString().split('.')[0]}', style: TextStyle(color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted ? Colors.red : Colors.grey[700])),
                                      if (task.completedAt != null)
                                        Text('Xong lúc: ${task.completedAt!.toLocal().toString().split('.')[0]}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    ],
                                  ),
                                  trailing: Wrap(
                                    children: [
                                      Chip(
                                        label: Text(task.priority.name.toUpperCase()),
                                        backgroundColor: task.priority == TaskPriority.high
                                            ? Colors.red[100]
                                            : task.priority == TaskPriority.medium
                                                ? Colors.orange[100]
                                                : Colors.blue[100],
                                      ),
                                      const SizedBox(width: 6),
                                      Chip(
                                        label: task.isCompleted ? const Icon(Icons.check) : const Icon(Icons.pending),
                                        backgroundColor: task.isCompleted ? Colors.green[100] : Colors.orange[100],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteTask(task.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat({required String title, required int count, required Color color}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 20,
          child: Text('$count', style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTaskTile(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => _toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành'),
            const SizedBox(height: 4),
            if (task.dueDate != null)
              Text('Hạn: ${task.dueDate!.toLocal().toString().split('.')[0]}', style: TextStyle(color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted ? Colors.red : Colors.grey[700])),
            if (task.completedAt != null)
              Text('Xong lúc: ${task.completedAt!.toLocal().toString().split('.')[0]}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        trailing: Wrap(
          children: [
            Chip(
              label: Text(task.priority.name.toUpperCase()),
              backgroundColor: task.priority == TaskPriority.high
                  ? Colors.red[100]
                  : task.priority == TaskPriority.medium
                      ? Colors.orange[100]
                      : Colors.blue[100],
            ),
            const SizedBox(width: 6),
            Chip(
              label: task.isCompleted ? const Icon(Icons.check) : const Icon(Icons.pending),
              backgroundColor: task.isCompleted ? Colors.green[100] : Colors.orange[100],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có công việc nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm một công việc mới để bắt đầu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
