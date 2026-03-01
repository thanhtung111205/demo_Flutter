## 🎨 Hướng Dẫn Sử Dụng Hệ Thống Navigation và Animation

### 📱 Các Loại Transition Animation Có Sẵn

#### 1. **Fade Transition** (Phổ biến, tinh tế)
```dart
NavigationHelper.navigateTo(
  context,
  (context) => const ScreenB(),
  transitionType: TransitionType.fade,
  duration: const Duration(milliseconds: 400),
);
```
Hiệu ứng: Màn hình mới dần dần xuất hiện bằng cách thay đổi độ trong suốt.

#### 2. **Slide Right Transition** (Slide từ phải)
```dart
NavigationHelper.navigateTo(
  context,
  (context) => const ScreenB(),
  transitionType: TransitionType.slideRight,
  duration: const Duration(milliseconds: 500),
);
```
Hiệu ứng: Màn hình mới trượt vào từ bên phải.

#### 3. **Scale Fade Transition** (Phổ biến, động lực)
```dart
NavigationHelper.navigateTo(
  context,
  (context) => const ScreenB(),
  transitionType: TransitionType.scaleFade,
  duration: const Duration(milliseconds: 500),
);
```
Hiệu ứng: Màn hình mới phóng to từ nhỏ đồng thời bắn mờ dần.

#### 4. **Shared Axis Vertical** (Material Design 3 Style)
```dart
NavigationHelper.navigateTo(
  context,
  (context) => const ScreenB(),
  transitionType: TransitionType.sharedAxisVertical,
  duration: const Duration(milliseconds: 500),
);
```
Hiệu ứng: Màn hình mới trượt lên từ dưới với hiệu ứng scale.

#### 5. **Rotate Fade Transition** (Đặc biệt, cuốn hút)
```dart
NavigationHelper.navigateTo(
  context,
  (context) => const ScreenB(),
  transitionType: TransitionType.rotateFade,
  duration: const Duration(milliseconds: 600),
);
```
Hiệu ứng: Màn hình mới xoay vào và phóng to đồng thời bắn mờ dần.

---

### 🔄 Truyền Dữ Liệu Giữa Các Màn Hình

#### **Cách 1: Constructor Parameter**
```dart
// Từ HomeScreen
NavigationHelper.navigateTo(
  context,
  (context) => DetailScreen(
    studentId: '123',
    studentName: 'Nguyễn Văn A',
  ),
  transitionType: TransitionType.scaleFade,
);

// DetailScreen
class DetailScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  
  const DetailScreen({
    required this.studentId,
    required this.studentName,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('ID: $studentId, Tên: $studentName'),
    );
  }
}
```

#### **Cách 2: Trả Dữ Liệu Khi Pop**
```dart
// Từ HomeScreen, chờ kết quả từ DetailScreen
final result = await NavigationHelper.navigateTo(
  context,
  (context) => const EditScreen(),
  transitionType: TransitionType.slideRight,
);

if (result != null) {
  // Xử lý dữ liệu trả về
  print('Dữ liệu trả về: $result');
}

// Trong DetailScreen, khi pop
NavigationHelper.pop(context, 'Dữ liệu để gửi về');
```

#### **Cách 3: Sử Dụng Provider/Bloc (Cách hiện đại)**
```dart
// Provider example
final studentProvider = StateNotifierProvider<StudentNotifier, Student>((ref) {
  return StudentNotifier();
});

// Sử dụng trong màn hình
final student = ref.watch(studentProvider);
```

---

### ✨ Material Design 3 Best Practices

#### **AppBar Enhancement**
```dart
AppBar(
  title: const Text('Danh Sách Sinh Viên'),
  centerTitle: true,
  elevation: 0,
  scrolledUnderElevation: 4,
  backgroundColor: Colors.transparent,
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)
```

#### **Card dengan Material Design 3**
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
    padding: const EdgeInsets.all(16),
    child: Text('Content'),
  ),
)
```

#### **Button dengan Material Design 3**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  onPressed: () {},
  child: const Text('Thêm'),
)
```

---

### 🎯 Ví Dụ Thực Tế: Complete Flow

```dart
// 1. HomeScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          NavigationHelper.navigateTo(
            context,
            (context) => const StudentListScreen(),
            transitionType: TransitionType.slideRight,
            duration: const Duration(milliseconds: 500),
          );
        },
        child: const Text('Đi đến danh sách sinh viên'),
      ),
    );
  }
}

// 2. StudentListScreen
class StudentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh Sách Sinh Viên')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              // Chuyển và chờ kết quả
              final updated = await NavigationHelper.navigateTo(
                context,
                (context) => StudentDetailScreen(
                  student: students[index],
                ),
                transitionType: TransitionType.scaleFade,
              );
              
              if (updated == true) {
                // Refresh list
                setState(() {});
              }
            },
            child: StudentCard(student: students[index]),
          );
        },
      ),
    );
  }
}

// 3. StudentDetailScreen
class StudentDetailScreen extends StatefulWidget {
  final Student student;
  
  const StudentDetailScreen({required this.student});
  
  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late TextEditingController _nameController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sinh viên'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sinh viên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Cập nhật và trả về
                widget.student.name = _nameController.text;
                NavigationHelper.pop(context, true);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
```

---

### 🛠️ Configuration Tips

#### **Customize Animation Duration**
```dart
// Nhanh (200ms)
duration: const Duration(milliseconds: 200)

// Bình thường (500ms)
duration: const Duration(milliseconds: 500)

// Chậm (800ms)
duration: const Duration(milliseconds: 800)
```

#### **Replace vs Push Navigation**
```dart
// Push: Stack navigation (có thể quay lại)
NavigationHelper.navigateTo(context, builder);

// Replace: Thay thế màn hình hiện tại
NavigationHelper.navigateTo(
  context,
  builder,
  replace: true,
);
```

---

### 📊 So Sánh Các Transition Type

| Type | Tốc độ | Kiểu | Phù hợp |
|------|--------|------|---------|
| Fade | 400ms | Mờ dần | Chi tiết, dialog, modal |
| SlideRight | 500ms | Trượt từ phải | Chuyển sang screen khác |
| ScaleFade | 500ms | Phóng + mờ | Menu, nội dung chính |
| SharedAxisVertical | 500ms | Material Design 3 | Phân cấp, danh sách |
| RotateFade | 600ms | Xoay + phóng | Đặc biệt, cuốn hút |

---

### 🎁 Bonus: Animated Button Widget

```dart
class AnimatedMenuButton extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const AnimatedMenuButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  
  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(height: 8),
              Text(widget.title, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

Hệ thống này cung cấp **flexible, reusable, và maintainable** navigation với animations đẹp mắt! 🚀
