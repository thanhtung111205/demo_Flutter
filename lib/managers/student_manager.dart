import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';

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
    return students
        .where((s) =>
            s.id.toLowerCase().contains(keyword.toLowerCase()) ||
            s.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
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
