import 'package:flutter/material.dart';
import 'dart:async';
import '../routes/navigation_helper.dart';
import '../managers/student_manager.dart';
import '../models/student.dart';

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
                  const SnackBar(
                      content: Text('❌ Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              try {
                final score = double.parse(scoreText);
                if (score < 0 || score > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('❌ Điểm phải từ 0 đến 10')),
                  );
                  return;
                }

                if (manager.addStudent(id, name, score)) {
                  setState(() {
                    _displayedStudents = manager.students;
                  });
                  _saveData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Thêm sinh viên thành công')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('❌ ID sinh viên đã tồn tại')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('❌ Điểm phải là một số hợp lệ')),
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
            Text(
                'Tổng điểm: ${manager.students.fold<double>(0, (sum, s) => sum + s.score).toStringAsFixed(2)}'),
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
              trailing: Text('${sorted[index].score}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                final moved =
                                    manager.students.removeAt(oldIndex);
                                manager.students.insert(newIndex, moved);
                                await _saveData();
                                setState(() =>
                                    _displayedStudents = manager.students);
                              },
                              children: List.generate(
                                  _displayedStudents.length, (index) {
                                final student = _displayedStudents[index];
                                return Card(
                                  key: ValueKey(student.id),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(student.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text('ID: ${student.id}'),
                                    trailing: Wrap(
                                      children: [
                                        Chip(
                                          label: Text('${student.score}'),
                                          backgroundColor: student.score >= 7
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteStudent(student.id),
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(student.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text('ID: ${student.id}'),
                                    trailing: Wrap(
                                      children: [
                                        Chip(
                                          label: Text('${student.score}'),
                                          backgroundColor: student.score >= 7
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteStudent(student.id),
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
