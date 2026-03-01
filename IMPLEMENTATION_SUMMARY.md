# 🎨 Tổng Hợp Hệ Thống Navigation & Animation Material Design 3

## 📋 Nội Dung Được Thêm

### 1. **Custom Route Transitions** (`lib/routes/custom_route_transitions.dart`)
Thư viện các custom page routes với nhiều hiệu ứng animation khác nhau:

- **FadePageRoute**: Fade in/out từ từ
- **SlideRightPageRoute**: Trượt từ phải sang trái
- **ScaleFadePageRoute**: Phóng to + fade đồng thời
- **SharedAxisVerticalPageRoute**: Material Design 3 style (trượt lên + scale)
- **RotateFadePageRoute**: Xoay + phóng to + fade

### 2. **Navigation Helper** (`lib/routes/navigation_helper.dart`)
Lớp tiện ích để quản lý navigation với animation:

```dart
// Sử dụng cơ bản
NavigationHelper.navigateTo(
  context,
  (context) => const NextScreen(),
  transitionType: TransitionType.scaleFade,
  duration: const Duration(milliseconds: 500),
);

// Pop với dữ liệu trả về
NavigationHelper.pop(context, resultData);
```

**Enum TransitionType:**
- `fade` - 400ms, tinh tế
- `slideRight` - 500ms, chuyên nghiệp
- `scaleFade` - 500ms, động
- `sharedAxisVertical` - 500ms, MD3 style
- `rotateFade` - 600ms, cuốn hút

### 3. **Material Design 3 Components** (`lib/widgets/md3_components.dart`)
Bộ sưu tập các widget MD3:

#### Button Components:
- **MD3ElevatedButton** - Nền đầy đủ với shadow
- **MD3TonalButton** - Tông màu nhẹ
- **MD3OutlinedButton** - Viền mảnh
- **MD3TextButton** - Chỉ text

#### Container Components:
- **MD3Card** - Card với outline variant
- **MD3AppBar** - AppBar MD3 style
- **MD3TextField** - Input field MD3 style
- **MD3Dialog** - Dialog MD3 style

#### Status Components:
- **MD3Badge** - Badge/chip cho status

### 4. **Demo & Example Screens**

#### a) `navigation_demo_screen.dart`
- Cho phép chọn loại transition
- Chọn thời lượng animation
- Hiển thị các MD3 components
- Interactive demo

#### b) `user_management_example_screen.dart`
- **UserListExampleScreen**: Danh sách người dùng
- **UserDetailExampleScreen**: Chi tiết + chỉnh sửa
- **CreateUserExampleScreen**: Tạo mới
- Demonstration đầy đủ về data passing

### 5. **Updated Navigation**
- `home_screen.dart` - Sử dụng NavigationHelper với animation
- `student_list_screen.dart` - Import navigation helper
- `todo_list_screen.dart` - Import navigation helper

## 🎯 Kỹ Năng Được Giới Thiệu

### ✅ Navigation Techniques
1. **Stack-based Navigation** - Push/Pop
2. **Custom Page Routes** - Animation tùy chỉnh
3. **Data Passing**:
   - Constructor parameters
   - Return values from pop
   - State management

### ✅ UI/UX Design
1. **Material Design 3**:
   - Color scheme system
   - Modern components
   - Smooth transitions
   
2. **Animation Patterns**:
   - Fade transitions
   - Scale transitions
   - Slide transitions
   - Combined animations

3. **Responsive Design**:
   - Flexible layouts
   - Proper spacing
   - Touch targets

## 🔧 Cách Sử Dụng

### Setup Ban Đầu
```dart
// main.dart đã được cập nhật
// Chỉ cần import navigation helper trong các screen
import '../routes/navigation_helper.dart';
```

### Chuyển Screen Cơ Bản
```dart
// Slide right transition
NavigationHelper.navigateTo(
  context,
  (context) => const StudentListScreen(),
  transitionType: TransitionType.slideRight,
);

// Hoặc scale fade
NavigationHelper.navigateTo(
  context,
  (context) => const TodoListScreen(),
  transitionType: TransitionType.scaleFade,
);
```

### Chuyển với Dữ Liệu
```dart
// Gửi dữ liệu qua constructor
NavigationHelper.navigateTo(
  context,
  (context) => UserDetailScreen(
    user: userData,
    id: '123',
  ),
);

// Hoặc trả dữ liệu khi pop
final result = await NavigationHelper.navigateTo(
  context,
  (context) => const EditScreen(),
);

if (result != null) {
  // Xử lý dữ liệu trả về
}
```

### Sử Dụng MD3 Components
```dart
// Button
MD3ElevatedButton(
  label: 'Lưu',
  icon: Icons.save,
  onPressed: () {},
)

// Card
MD3Card(
  onTap: () {},
  child: Text('Content'),
)

// TextField
MD3TextField(
  labelText: 'Tên',
  prefixIcon: Icons.person,
  onChanged: (value) {},
)
```

## 📁 Cấu Trúc Thư Mục

```
lib/
├── routes/
│   ├── custom_route_transitions.dart    (5 custom transitions)
│   └── navigation_helper.dart           (Navigation utility)
├── widgets/
│   └── md3_components.dart              (MD3 component library)
├── screens/
│   ├── home_screen.dart                 (Updated)
│   ├── navigation_demo_screen.dart      (New - demo screen)
│   ├── user_management_example_screen.dart (New - full example)
│   ├── student_list_screen.dart         (Updated)
│   └── todo_list_screen.dart            (Updated)
└── ...

NAVIGATION_GUIDE.md                      (Hướng dẫn chi tiết)
```

## 🚀 Advanced Features

### 1. Conditional Navigation
```dart
if (isLoggedIn) {
  NavigationHelper.navigateTo(context, (c) => const DashboardScreen());
} else {
  NavigationHelper.navigateTo(context, (c) => const LoginScreen());
}
```

### 2. Navigation with Replace
```dart
NavigationHelper.navigateTo(
  context,
  (context) => const SplashScreen(),
  replace: true, // Thay thế màn hình hiện tại
);
```

### 3. Pop Until
```dart
NavigationHelper.popUntil(context, '/home');
```

### 4. Check Can Pop
```dart
if (NavigationHelper.canPop(context)) {
  NavigationHelper.pop(context);
}
```

## 💡 Best Practices

### ✅ DO
- ✅ Sử dụng NavigationHelper cho toàn bộ navigation
- ✅ Chọn transition type phù hợp với ngữ cảnh
- ✅ Giới hạn animation duration (200-600ms)
- ✅ Truyền dữ liệu qua constructor parameters
- ✅ Sử dụng MD3 components cho consistency

### ❌ DON'T
- ❌ Không sử dụng Navigator.push trực tiếp
- ❌ Không lạm dụng animation (quá phức tạp)
- ❌ Không hardcode duration values
- ❌ Không truyền dữ liệu lớn qua pop result
- ❌ Không quên handle nullability khi pop

## 📊 Performance Tips

1. **Animation Duration**:
   - Fast (200-300ms): Subtle transitions
   - Normal (400-500ms): Recommended
   - Slow (600-800ms): For special effects

2. **Memory Management**:
   - Navigator popping tự động cleanup
   - Dispose controllers trong StatefulWidget
   - Avoid memory leaks

3. **Smooth Performance**:
   - Sử dụng CurvedAnimation
   - Optimize widget rebuilds
   - Use const constructors

## 🎓 Learning Path

### Beginner
1. Learn basic navigation (push/pop)
2. Understand MaterialPageRoute
3. Simple data passing

### Intermediate
1. Custom route transitions
2. Animation curves
3. Navigation helper pattern

### Advanced
1. Complex data flows
2. Conditional routing
3. State management integration

## 📖 Tài Liệu Tham Khảo

- [Navigation_Guide.md](NAVIGATION_GUIDE.md) - Chi tiết từng transition type
- `navigation_demo_screen.dart` - Interactive demo
- `user_management_example_screen.dart` - Complete example

## 🎉 Key Takeaways

1. **5 Loại Transition** khác nhau để lựa chọn
2. **MaterialDesign 3** đầy đủ components
3. **Reusable Navigation Helper** cho toàn bộ app
4. **Data Passing Patterns** đa dạng
5. **Best Practices** cho performance và UX

## 🔄 Tiếp Theo

Bạn có thể:
- Tích hợp State Management (Provider, Riverpod, Bloc)
- Thêm navigation deep linking
- Implement route guards (authentication)
- Add page transitions customization
- Create animated widgets library

---

## 🆕 Mới: Tính Năng Tìm Kiếm & Đính Kèm File (Phiên Bản Mở Rộng)

### 1. **Tìm Kiếm Công Việc** (`lib/screens/todo_list_screen.dart`)

**Tính năng:**
- ✅ Tìm kiếm theo tiêu đề công việc
- ✅ Tìm kiếm theo ghi chú chi tiết
- ✅ Tối ưu hóa với debounce (300ms)
- ✅ Hiển thị kết quả thời gian thực
- ✅ Nút xóa nhanh trên trường tìm kiếm

**Cách sử dụng:**
```dart
// Tìm kiếm từ TodoManager
final results = manager.searchTasks('keyword');

// Lọc theo trạng thái
final pending = manager.filterByCompletion(false);

// Lọc theo mức độ ưu tiên
final highPriority = manager.filterByPriority(TaskPriority.high);
```

### 2. **Ghi Chú Chi Tiết** (`lib/models/task.dart`)

**Mở rộng Task model:**
- `String notes` - Ghi chú dài, nhiều dòng
- `List<TaskAttachment> attachments` - Danh sách file/ảnh

**Dialog chỉnh sửa:**
- Mở từ nút ⋮ (More) trên công việc
- Hỗ trợ nhập text đa dòng
- Lưu tự động vào JSON

### 3. **Tệp/Ảnh Đính Kèm** (`lib/models/task.dart`)

**Lớp TaskAttachment:**
```dart
class TaskAttachment {
  final String id;           // ID duy nhất
  final String name;         // Tên file
  final String type;         // "image" hoặc "file"
  final String filePath;     // Đường dẫn cục bộ
  final DateTime addedDate;  // Thời gian thêm
}
```

**Vị trí lưu trữ:**
```
ApplicationDocumentsDirectory/
└── task_attachments/
    ├── [task_id_1]/
    │   ├── 1708934400000_photo.jpg
    │   └── 1708934500000_document.pdf
    └── [task_id_2]/
        └── 1708934700000_image.png
```

### 4. **TodoManager API Mở Rộng** (`lib/managers/todo_manager.dart`)

**Phương thức mới:**
```dart
// Tìm kiếm
List<Task> searchTasks(String keyword);
List<Task> filterByCompletion(bool isCompleted);
List<Task> filterByPriority(TaskPriority priority);
List<Task> filterByDeadline(DateTime from, DateTime to);
List<Task> searchTasksWithAttachments();

// Quản lý file
Future<Directory> getAttachmentsDirectory();
Future<bool> addAttachmentToTask(...);
Future<bool> removeAttachmentFromTask(...);
Future<void> deleteTaskAttachments(String taskId);
```

### 5. **UI/UX Cập Nhật**

**Trường tìm kiếm:**
- Vị trí: Dưới trường "Thêm công việc"
- Tìm kiếm theo tiêu đề và ghi chú
- Xóa nhanh bằng nút ✕

**Popup menu công việc (⋮):**
- 📝 Ghi chú - Chỉnh sửa ghi chú
- 📎 Tệp đính kèm - Quản lý file/ảnh
- 🗑️ Xóa - Xóa công việc

**Hiển thị thông tin:**
- 📝 Icon ghi chú (nếu có nội dung)
- 📎 Icon attachment + số lượng file
- ⏰ Thời gian hoàn thành

### 6. **Lưu Trữ Dữ Liệu**

**Tài liệu chi tiết:** Xem [STORAGE_DOCUMENTATION.md](./STORAGE_DOCUMENTATION.md)

| File | Nơi lưu | Nội dung |
|------|---------|---------|
| tasks.json | Documents/ | Công việc + ghi chú + attachments |
| task_attachments/ | Documents/ | File/ảnh đính kèm |
| students.json | Documents/ | Danh sách học sinh |
| settings.json | Documents/ | Cấu hình ứng dụng |

**Đường dẫn theo nền tảng:**
- **Android:** `/data/user/0/com.example.flutter_demo/files/`
- **iOS:** `/var/mobile/Containers/Data/Application/.../Documents/`
- **Windows:** `C:\Users\[user]\AppData\Local\flutter_demo\`
- **Linux:** `~/.local/share/flutter_demo/`

---

**Cảm ơn vì đã sử dụng hệ thống này!** 🚀

Nếu có câu hỏi, hãy tham khảo NAVIGATION_GUIDE.md hoặc STORAGE_DOCUMENTATION.md.
