import 'dart:convert';
import 'dart:io';

class Student {
  String id;
  String name;
  double score;

  Student({
    required this.id,
    required this.name,
    required this.score,
  });

  // Convert Student to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
    };
  }

  // Create Student from JSON
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
  final String filename = 'students.json';

  // Thêm sinh viên mới
  void addStudent(String id, String name, double score) {
    if (students.any((s) => s.id == id)) {
      print('❌ Lỗi: Sinh viên với ID "$id" đã tồn tại!');
      return;
    }
    students.add(Student(id: id, name: name, score: score));
    print('✅ Thêm sinh viên thành công: $name');
  }

  // Xóa sinh viên theo ID
  void deleteStudent(String id) {
    final initialLength = students.length;
    students.removeWhere((s) => s.id == id);
    if (students.length < initialLength) {
      print('✅ Xóa sinh viên thành công (ID: $id)');
    } else {
      print('❌ Không tìm thấy sinh viên với ID "$id"');
    }
  }

  // Tìm kiếm sinh viên theo ID hoặc tên
  void searchStudent(String keyword) {
    final results = students.where((s) =>
        s.id.toLowerCase().contains(keyword.toLowerCase()) ||
        s.name.toLowerCase().contains(keyword.toLowerCase())).toList();

    if (results.isEmpty) {
      print('❌ Không tìm thấy sinh viên nào với từ khóa: "$keyword"');
      return;
    }

    print('\n📋 Kết quả tìm kiếm cho "$keyword":');
    for (var student in results) {
      print(student);
    }
    print('');
  }

  // Tính điểm trung bình
  void calculateAverageScore() {
    if (students.isEmpty) {
      print('❌ Danh sách sinh viên trống!');
      return;
    }

    double sum = students.fold(0, (prev, student) => prev + student.score);
    double average = sum / students.length;
    print('\n📊 Thống kê điểm:');
    print('   Số lượng sinh viên: ${students.length}');
    print('   Tổng điểm: ${sum.toStringAsFixed(2)}');
    print('   Điểm trung bình: ${average.toStringAsFixed(2)}');
    print('');
  }

  // Lưu danh sách sinh viên vào JSON
  Future<void> saveToJson() async {
    try {
      final jsonData = jsonEncode(students.map((s) => s.toJson()).toList());
      final file = File(filename);
      await file.writeAsString(jsonData, encoding: utf8);
      print('✅ Lưu dữ liệu thành công vào file: $filename');
    } catch (e) {
      print('❌ Lỗi khi lưu dữ liệu: $e');
    }
  }

  // Đọc danh sách sinh viên từ JSON
  Future<void> loadFromJson() async {
    try {
      final file = File(filename);
      if (!await file.exists()) {
        print('⚠️ File $filename không tồn tại. Tạo danh sách mới.');
        return;
      }

      final jsonString = await file.readAsString(encoding: utf8);
      final jsonData = jsonDecode(jsonString) as List;
      students = jsonData.map((data) => Student.fromJson(data)).toList();
      print('✅ Tải dữ liệu thành công từ file: $filename (${students.length} sinh viên)');
    } catch (e) {
      print('❌ Lỗi khi tải dữ liệu: $e');
    }
  }

  // Hiển thị tất cả sinh viên
  void displayAllStudents() {
    if (students.isEmpty) {
      print('❌ Danh sách sinh viên trống!');
      return;
    }

    print('\n📚 Danh sách tất cả sinh viên:');
    print('-' * 50);
    for (var student in students) {
      print(student);
    }
    print('-' * 50);
    print('Tổng cộng: ${students.length} sinh viên\n');
  }

  // Sắp xếp theo điểm
  void sortByScore() {
    if (students.isEmpty) {
      print('❌ Danh sách sinh viên trống!');
      return;
    }

    final sorted = List<Student>.from(students);
    sorted.sort((a, b) => b.score.compareTo(a.score));

    print('\n📈 Danh sách sinh viên sắp xếp theo điểm (cao → thấp):');
    print('-' * 50);
    for (var student in sorted) {
      print(student);
    }
    print('-' * 50 + '\n');
  }
}

void main() async {
  final manager = StudentManager();

  // Tải dữ liệu từ file khi khởi động
  await manager.loadFromJson();

  bool running = true;

  while (running) {
    print('\n╔════════════════════════════════════════╗');
    print('║     QUẢN LÝ DANH SÁCH SINH VIÊN        ║');
    print('╠════════════════════════════════════════╣');
    print('║ 1. Xem tất cả sinh viên                ║');
    print('║ 2. Thêm sinh viên mới                  ║');
    print('║ 3. Xóa sinh viên                       ║');
    print('║ 4. Tìm kiếm sinh viên                  ║');
    print('║ 5. Tính điểm trung bình                ║');
    print('║ 6. Sắp xếp theo điểm                   ║');
    print('║ 7. Lưu dữ liệu vào JSON                ║');
    print('║ 8. Tải dữ liệu từ JSON                 ║');
    print('║ 0. Thoát chương trình                  ║');
    print('╚════════════════════════════════════════╝');
    print('Chọn chức năng (0-8): ');

    final choice = stdin.readLineSync()?.trim() ?? '';

    switch (choice) {
      case '1':
        manager.displayAllStudents();
        break;

      case '2':
        print('Nhập ID sinh viên: ');
        final id = stdin.readLineSync()?.trim() ?? '';
        if (id.isEmpty) {
          print('❌ ID không được bỏ trống!');
          break;
        }

        print('Nhập tên sinh viên: ');
        final name = stdin.readLineSync()?.trim() ?? '';
        if (name.isEmpty) {
          print('❌ Tên không được bỏ trống!');
          break;
        }

        print('Nhập điểm (0-10): ');
        try {
          final score = double.parse(stdin.readLineSync()?.trim() ?? '');
          if (score < 0 || score > 10) {
            print('❌ Điểm phải từ 0 đến 10!');
            break;
          }
          manager.addStudent(id, name, score);
        } catch (e) {
          print('❌ Điểm phải là một số hợp lệ!');
        }
        break;

      case '3':
        print('Nhập ID sinh viên cần xóa: ');
        final id = stdin.readLineSync()?.trim() ?? '';
        if (id.isEmpty) {
          print('❌ ID không được bỏ trống!');
          break;
        }
        manager.deleteStudent(id);
        break;

      case '4':
        print('Nhập ID hoặc tên sinh viên cần tìm: ');
        final keyword = stdin.readLineSync()?.trim() ?? '';
        if (keyword.isEmpty) {
          print('❌ Từ khóa tìm kiếm không được bỏ trống!');
          break;
        }
        manager.searchStudent(keyword);
        break;

      case '5':
        manager.calculateAverageScore();
        break;

      case '6':
        manager.sortByScore();
        break;

      case '7':
        await manager.saveToJson();
        break;

      case '8':
        await manager.loadFromJson();
        break;

      case '0':
        print('\n👋 Cảm ơn bạn đã sử dụng chương trình. Tạm biệt!');
        running = false;
        break;

      default:
        print('❌ Lựa chọn không hợp lệ! Vui lòng chọn từ 0-8.');
    }
  }
}
