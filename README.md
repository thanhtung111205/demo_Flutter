# Flutter Demo — Kiến trúc Source Code

Tài liệu này tóm tắt cấu trúc mã nguồn của project Flutter `flutter_demo` để giúp nhanh nắm bắt và tiếp tục phát triển.

**Mục tiêu**: mô tả các thư mục chính, điểm vào chương trình, dữ liệu mẫu và các hướng dẫn chạy nhanh.

**Cấu trúc chính**
- **Root files**: `pubspec.yaml` (khai báo dependencies và assets), `students.json` (dữ liệu mẫu), `bin/student_manager.dart` (tiện ích/CLI nếu có).
- **`lib/`**: mã nguồn Dart chính của ứng dụng.
  - **`lib/main.dart`**: điểm vào ứng dụng (entrypoint). Xử lý khởi tạo và `runApp()`.
  - Gợi ý cấu trúc bên trong `lib/`: tách thành `models/`, `services/`, `screens/`, `widgets/`, `utils/` để giữ code có tổ chức.
- **Platform folders:** `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` — mã và cấu hình platform-specific do Flutter tạo.
- **`build/`**: artefacts do build sinh ra (không commit).

**Dữ liệu & Assets**
- Assets (fonts, icons...) được khai báo trong `pubspec.yaml`.
- `students.json` nằm ở root, dùng làm dữ liệu mẫu hoặc fixtures cho demo.

**Luồng chính của ứng dụng**
- `lib/main.dart` khởi tạo app và các dependency cơ bản (services, storage, ...).
- UI tách thành screens/pages; logic nghiệp vụ đặt trong services hoặc controllers để dễ test.
- Models định nghĩa cấu trúc dữ liệu (ví dụ `Student`) và mapping từ `students.json`.

**Hướng dẫn chạy nhanh**
```bash
flutter pub get
flutter run -d <device>
```

Build release:
```bash
flutter build apk --release
```

**Gợi ý cải tiến kiến trúc**
- Khi project lớn, cân nhắc tổ chức theo feature: `lib/features/<feature>/...`.
- Thêm `lib/repositories/` để trừu tượng nguồn dữ liệu (local vs remote).
- Bổ sung thư mục `test/` và viết unit/integration tests cho `services` và `models`.

**Tài liệu tham khảo nhanh**
- Điểm vào: [lib/main.dart](lib/main.dart)
- CLI helper: [bin/student_manager.dart](bin/student_manager.dart)
- Dữ liệu mẫu: [students.json](students.json)
- Khai báo dependency & assets: [pubspec.yaml](pubspec.yaml)

Muốn mình mở rộng README (thêm sơ đồ thư mục chi tiết, luồng dữ liệu, hoặc ví dụ code cụ thể) không? Mình sẽ làm tiếp nếu bạn đồng ý.
# flutter_demo

A new Flutter project.
