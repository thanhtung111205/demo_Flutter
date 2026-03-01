# 📁 Tài Liệu Lưu Trữ Dữ Liệu - Flutter Demo

## Tổng Quan

Ứng dụng Flutter Demo lưu trữ dữ liệu ở vị trí được cấp quyền bởi hệ điều hành, gọi là **Application Documents Directory**. Đây là thư mục an toàn cho mỗi ứng dụng với quyền truy cập đầy đủ.

---

## 📍 Vị Trí Lưu Trữ Theo Nền Tảng

### 🤖 Android

**Thư mục chính:**
```
/data/user/0/com.example.flutter_demo/files/
```

**Chi tiết:**
- **Tuyệt đối:** `/data/user/0/[package_name]/files/`
- **Tương đối:** Được quản lý bởi `getApplicationDocumentsDirectory()`
- **Quyền truy cập:** Riêng tư (chỉ ứng dụng có thể truy cập)
- **Xóa dữ liệu:** Xóa khi gỡ cài đặt ứng dụng

### 🍎 iOS

**Thư mục chính:**
```
/var/mobile/Containers/Data/Application/[app_id]/Documents/
```

**Chi tiết:**
- **Tuyệt đối:** `/var/mobile/Containers/Data/Application/[app_id]/Documents/`
- **Tương đối:** Được quản lý bởi `getApplicationDocumentsDirectory()`
- **Quyền truy cập:** Riêng tư (chỉ ứng dụng có thể truy cập)
- **Xóa dữ liệu:** Xóa khi gỡ cài đặt ứng dụng
- **Sao lưu:** Tự động được sao lưu bởi iCloud

### 🪟 Windows

**Thư mục chính:**
```
C:\Users\[username]\AppData\Local\[app_name]\
```

**Chi tiết:**
- **Tuyệt đối:** `C:\Users\[username]\AppData\Local\flutter_demo\`
- **Tương đối:** Được quản lý bởi `getApplicationDocumentsDirectory()`
- **Quyền truy cập:** Riêng tư (chỉ người dùng hiện tại có thể truy cập)
- **Xóa dữ liệu:** Xóa khi gỡ cài đặt ứng dụng
- **Sao lưu:** Có thể được sao lưu bởi Windows Backup

### 🐧 Linux

**Thư mục chính:**
```
~/.local/share/[app_name]/
```

**Chi tiết:**
- **Tuyệt đối:** `/home/[username]/.local/share/flutter_demo/`
- **Tương đối:** Được quản lý bởi `getApplicationDocumentsDirectory()`
- **Quyền truy cập:** Riêng tư (chỉ người dùng hiện tại có thể truy cập)

---

## 📂 Cấu Trúc Thư Mục

```
ApplicationDocumentsDirectory/
├── tasks.json                    # Dữ liệu Ghi Chú (JSON)
├── students.json                 # Dữ liệu danh sách học sinh (JSON)
├── settings.json                 # Cấu hình ứng dụng (chủ đề, v.v.)
│
└── task_attachments/             # Thư mục lưu trữ file/ảnh đính kèm
    ├── [task_id_1]/              # Thư mục cho công việc 1
    │   ├── 1708934400000_photo.jpg
    │   ├── 1708934500000_notes.pdf
    │   └── 1708934600000_document.docx
    │
    ├── [task_id_2]/              # Thư mục cho công việc 2
    │   ├── 1708934700000_image.png
    │   └── 1708934800000_file.xlsx
    │
    └── [task_id_3]/              # Thư mục cho công việc 3
        └── ...
```

---

## 📋 Chi Tiết Các Tệp Dữ Liệu

### 1. **tasks.json** - Ghi Chú

**Vị trí:** `ApplicationDocumentsDirectory/tasks.json`

**Dung lượng:**
- Trung bình: 5-20 KB (100-500 công việc)
- Lớn nhất: Tùy theo số lượng công việc và ghi chú

**Cấu trúc dữ liệu:**
```json
[
  {
    "id": "1708934400000",
    "title": "Hoàn thành báo cáo",
    "isCompleted": false,
    "dueDate": "2024-02-27T10:00:00.000",
    "completedAt": null,
    "priority": "high",
    "notes": "Ghi chú chi tiết về công việc",
    "attachments": [
      {
        "id": "1708934400001",
        "name": "report.pdf",
        "type": "file",
        "filePath": "/data/user/0/com.example.flutter_demo/files/task_attachments/1708934400000/1708934400001_report.pdf",
        "addedDate": "2024-02-26T15:30:00.000"
      }
    ]
  }
]
```

**Mô tả trường:**
| Trường | Kiểu | Mô Tả |
|--------|------|-------|
| id | String | ID duy nhất (timestamp) |
| title | String | Tiêu đề công việc |
| isCompleted | Boolean | Trạng thái hoàn thành |
| dueDate | ISO8601 | Hạn chót (null nếu không có) |
| completedAt | ISO8601 | Thời gian hoàn thành (null nếu chưa xong) |
| priority | String | Mức độ ưu tiên: "low", "medium", "high" |
| notes | String | Ghi chú chi tiết |
| attachments | Array | Danh sách file/ảnh đính kèm |

### 2. **task_attachments/** - Thư Mục File/Ảnh Đính Kèm

**Vị trí:** `ApplicationDocumentsDirectory/task_attachments/[task_id]/`

**Cách tổ chức:**
- Mỗi công việc có một thư mục con riêng (ID của công việc)
- Các file được đặt tên theo: `[timestamp]_[tên_file_gốc]`
- Timestamp dùng để tránh trùng lặp tên file

**Ví dụ:**
```
task_attachments/
└── 1708934400000/          # ID công việc
    ├── 1708934401000_photo.jpg
    ├── 1708934402000_report.pdf
    └── 1708934403000_notes.txt
```

**Dung lượng:**
- Tùy theo loại file (ảnh, PDF, tài liệu)
- Không có giới hạn cứng, nhưng nên giữ dưới 100MB mỗi công việc

**Loại file hỗ trợ:**
- **Ảnh:** `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`
- **Tài liệu:** `.pdf`, `.docx`, `.xlsx`, `.pptx`, `.txt`
- **Khác:** Hầu hết các định dạng file thông dụng

### 3. **students.json** - Danh Sách Học Sinh

**Vị trí:** `ApplicationDocumentsDirectory/students.json`

**Cấu trúc:**
```json
[
  {
    "id": "STU001",
    "name": "Nguyễn Văn A",
    "score": 8.5
  }
]
```

### 4. **settings.json** - Cấu Hình Ứng Dụng

**Vị trí:** `ApplicationDocumentsDirectory/settings.json`

**Cấu trúc:**
```json
{
  "isDark": false
}
```

---

## 🔄 Quy Trình Lưu/Tải Dữ Liệu

### Lưu Dữ Liệu (Save)

```dart
// 1. Lấy thư mục tài liệu
final dir = await getApplicationDocumentsDirectory();

// 2. Tạo đường dẫn file
final file = File('${dir.path}/tasks.json');

// 3. Chuyển đối tượng thành JSON
final jsonData = jsonEncode(tasks.map((t) => t.toJson()).toList());

// 4. Ghi file
await file.writeAsString(jsonData, encoding: utf8);
```

### Tải Dữ Liệu (Load)

```dart
// 1. Lấy thư mục tài liệu
final dir = await getApplicationDocumentsDirectory();

// 2. Tạo đường dẫn file
final file = File('${dir.path}/tasks.json');

// 3. Kiểm tra file tồn tại
if (!await file.exists()) {
  return; // Chưa có dữ liệu
}

// 4. Đọc file
final jsonString = await file.readAsString(encoding: utf8);

// 5. Parse JSON
final jsonData = jsonDecode(jsonString) as List;
tasks = jsonData.map((data) => Task.fromJson(data)).toList();
```

### Thêm File Đính Kèm

```dart
// 1. Lấy thư mục attachments
final attachmentsDir = await getAttachmentsDirectory();

// 2. Tạo thư mục cho task (nếu chưa có)
final taskDir = Directory('${attachmentsDir.path}/$taskId');
await taskDir.create(recursive: true);

// 3. Copy file nguồn vào thư mục
final destFile = File('${taskDir.path}/${timestamp}_${fileName}');
await sourceFile.copy(destFile.path);

// 4. Lưu thông tin vào task object
task.attachments.add(TaskAttachment(
  id: attachmentId,
  name: fileName,
  type: 'image', // hoặc 'file'
  filePath: destFile.path,
  addedDate: DateTime.now(),
));

// 5. Lưu lại tasks.json
await manager.saveToJson();
```

---

## 🔐 Bảo Mật Dữ Liệu

### Hiện Tại
- ✅ **Dữ liệu được lưu cục bộ:** Không tải lên cloud
- ✅ **Quyền riêng tư:** Chỉ ứng dụng có thể truy cập
- ❌ **Không mã hóa:** Các file JSON có thể đọc được (Plain text)
- ✅ **Tự động xóa:** Xóa khi gỡ cài đặt

### Khuyến Nghị Bảo Mật
1. **Mã hóa nhạy cảm:** Nên mã hóa những dữ liệu nhạy cảm
2. **Quyền yêu cầu:** Yêu cầu quyền truy cập file (iOS 14+)
3. **Sao lưu:** Hỗ trợ sao lưu dữ liệu

---

## 📊 Kích Thước & Hiệu Suất

### Dung Lượng Lưu Trữ

| Mục | Kích Thước (Ước Tính) | Ghi Chú |
|-----|----------------------|--------|
| 100 công việc | 10-15 KB | Chỉ JSON, không có ảnh |
| 1000 công việc | 100-150 KB | Danh sách lớn |
| 1 ảnh 2MB | 2 MB | Ảnh từ camera |
| 10 PDF 500KB mỗi cái | 5 MB | Tài liệu PDF |

### Khuyến Nghị
- **Dữ liệu JSON:** Giữ dưới 10MB
- **File đính kèm:** Tối đa 500MB toàn bộ
- **Ảnh:** Nên nén trước khi lưu (dùng image compression)

---

## 🗑️ Xóa Dữ Liệu

### Xóa Một Công Việc

```dart
// 1. Xóa file ảnh/tài liệu
await manager.deleteTaskAttachments(taskId);

// 2. Xóa task từ danh sách
manager.deleteTask(taskId);

// 3. Lưu lại JSON
await manager.saveToJson();
```

### Xóa Toàn Bộ Ứng Dụng (Factory Reset)

```dart
// Lưu ý: Điều này xóa mọi dữ liệu ứng dụng!
final dir = await getApplicationDocumentsDirectory();
if (await Directory(dir.path).exists()) {
  await Directory(dir.path).delete(recursive: true);
}
```

---

## 🔄 Sao Lưu & Khôi Phục

### Android

**Sao lưu tự động:**
- Android 12+: Bật "Sao lưu ứng dụng" trong Cài đặt
- Dữ liệu được sao lưu lên Google Account

**Thủ công:**
```bash
adb backup -f backup.ab com.example.flutter_demo
adb restore backup.ab
```

### iOS

**Sao lưu tự động:**
- Bật iCloud Backup trong Cài đặt
- Dữ liệu trong Documents/ được sao lưu

**iTunes:**
- Kết nối iPhone → iTunes → Sao lưu

### Windows

**Sao lưu thủ công:**
```powershell
Copy-Item -Path "C:\Users\[user]\AppData\Local\flutter_demo" `
          -Destination "D:\Backup\flutter_demo_backup" -Recurse
```

---

## ⚠️ Vấn Đề Thường Gặp

### ❌ File/Ảnh không lưu được

**Nguyên nhân:**
- Hết dung lượng lưu trữ
- Quyền lưu tệp bị từ chối
- Đường dẫn không hợp lệ

**Giải pháp:**
- Kiểm tra dung lượng thiết bị
- Cấp quyền trong `pubspec.yaml`:
  ```yaml
  permissions:
    - WRITE_EXTERNAL_STORAGE
    - READ_EXTERNAL_STORAGE
  ```

### ❌ Dữ liệu bị mất sau cập nhật

**Nguyên nhân:**
- Cập nhật ứng dụng xóa dữ liệu
- Sao lưu không được bật

**Giải pháp:**
- Bật sao lưu trước khi cập nhật
- Xuất dữ liệu thường xuyên

### ❌ Ứng dụng chậm khi tải nhiều file

**Nguyên nhân:**
- Quá nhiều file trong một thư mục
- Ảnh không được nén

**Giải pháp:**
- Nén ảnh trước khi lưu
- Xóa file cũ không dùng
- Implement lazy loading

---

## 📝 Debugging Storage

### Xem đường dẫn thực tế

```dart
import 'package:path_provider/path_provider.dart';

Future<void> printStoragePath() async {
  final dir = await getApplicationDocumentsDirectory();
  print('Documents Dir: ${dir.path}');
  
  // Liệt kê các file
  dir.list().listen((file) {
    print('File: ${file.path}');
  });
}
```

### Kiểm tra file tồn tại

```dart
Future<void> checkFiles() async {
  final dir = await getApplicationDocumentsDirectory();
  final tasksFile = File('${dir.path}/tasks.json');
  
  if (await tasksFile.exists()) {
    final size = await tasksFile.length();
    print('tasks.json exists, size: ${size} bytes');
  }
}
```

### Xem nội dung file (chỉ phát triển)

```dart
Future<void> debugPrintData() async {
  final dir = await getApplicationDocumentsDirectory();
  final tasksFile = File('${dir.path}/tasks.json');
  
  if (await tasksFile.exists()) {
    final content = await tasksFile.readAsString();
    print('Tasks data: $content');
  }
}
```

---

## 🔗 Tài Liệu Tham Khảo

- [path_provider Package](https://pub.dev/packages/path_provider)
- [Android App Storage](https://developer.android.com/training/data-storage)
- [iOS File System](https://developer.apple.com/documentation/foundation/file_system)
- [Flutter Data & Backend](https://docs.flutter.dev/data-and-backend)

---

**Cập nhật lần cuối:** 26 Tháng 2, 2026
