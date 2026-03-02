#  Smart Note Pro

> **Flutter  Material Design 3  Clean Architecture  Production Ready**

Ứng dụng ghi chú thông minh với thiết kế hiện đại, hỗ trợ ảnh, tài liệu và vẽ tay.

---

##  Tính năng

| Tính năng | Chi tiết |
|---|---|
|  Quản lý ghi chú | Thêm  Sửa  Xóa với animation mượt |
|  Đính kèm ảnh | Chọn từ gallery, preview inline |
|  Đính kèm file | PDF  DOC  TXT  XLSX |
|  Vẽ tay | Canvas tự do, nhiều màu, lưu PNG |
|  Dark / Light Mode | Tự động theo hệ thống |
|  Lưu trữ cục bộ | SharedPreferences + External App Dir |
|  Material Design 3 | ColorScheme.fromSeed, bo góc 16dp |
|  Navigation | PageRouteBuilder với Slide + Fade |

---

##  Cấu trúc dự án

```
lib/
 main.dart                      # Entry point
 app.dart                       # MaterialApp root (M3 theme)
 models/
    note_model.dart            # Data model + JSON serialization
 services/
    note_service.dart          # CRUD via SharedPreferences
    file_service.dart          # Image / File / Drawing I/O
 screens/
    home_screen.dart           # Danh sách notes (AnimatedList)
    add_edit_note_screen.dart  # Thêm / Chỉnh sửa note
    note_detail_screen.dart    # Xem chi tiết
    draw_note_screen.dart      # Canvas vẽ tay (CustomPainter)
 widgets/
    note_card.dart             # Card hiển thị 1 note
    empty_state.dart           # UI khi chưa có note
 utils/
     app_theme.dart             # Light + Dark theme M3
     constants.dart             # Hằng số toàn cục
     date_formatter.dart        # Format ngày giờ (intl)
```

---

##  Dependencies

```yaml
dependencies:
  shared_preferences: ^2.3.2   # Lưu text data
  image_picker: ^1.1.2         # Chọn ảnh từ gallery
  file_picker: ^8.1.2          # Chọn tài liệu
  path_provider: ^2.1.4        # Đường dẫn thư mục
  intl: ^0.19.0                # Format ngày giờ
  uuid: ^4.5.1                 # Tạo unique ID
```

---

##  Lưu trữ dữ liệu  Giải thích chi tiết

### 1. Text Data (Tiêu đề  Nội dung  Metadata)

**Package:** `shared_preferences`
**Cơ chế:** Android lưu dưới dạng XML file tại:

```
/data/data/com.example.baisimplenote/shared_prefs/
 FlutterSharedPreferences.xml       chứa JSON của tất cả notes
```

**Đây là INTERNAL STORAGE:**
-  Không cần xin permission
-  Chỉ app này đọc được (bảo mật tuyệt đối)
-  Tồn tại qua các lần restart app
-  Bị xóa khi người dùng uninstall app
-  Không thấy trong File Manager

---

### 2. File đính kèm (Ảnh  Tài liệu  Hình vẽ)

**Package:** `path_provider`  `getExternalStorageDirectories()`
**Vị trí thực tế trên thiết bị Android:**

```
/storage/emulated/0/Android/data/com.example.baisimplenote/files/
 images/
    img_1709123456789.jpg       Ảnh từ gallery
 documents/
    1709123456789_report.pdf    Tài liệu đính kèm
 drawings/
     draw_1709123456789.png      Hình vẽ tay
```

**Đây là EXTERNAL APP-SPECIFIC DIRECTORY:**
-  KHÔNG cần permission trên Android 10+ (Scoped Storage)
-  Có thể xem bằng File Manager (dễ debug)
-  Không bị giới hạn dung lượng như internal storage
-  Tự động xóa khi uninstall (không để lại rác)
-  Bị xóa nếu người dùng "Clear Cache" trong Settings

---

###  Tại sao KHÔNG dùng root `/sdcard/`?

| | External App Dir  | Root /sdcard/  |
|---|---|---|
| Permission Android 10+ | Không cần | MANAGE_EXTERNAL_STORAGE (rất khó xin) |
| Dọn dẹp khi uninstall | Tự động | Để lại rác |
| Bảo mật | Tốt hơn | App khác đọc được |
| Play Store policy | Đạt chuẩn | Có thể bị từ chối |

---

##  Design System  Material Design 3

### ColorScheme

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4),  // Material Purple seed
  brightness: Brightness.light,  // hoặc Brightness.dark
)
// Flutter tự động generate: primary, secondary, tertiary,
// container colors, surface variants... đảm bảo WCAG AA contrast
```

### Spacing & Shape Standards

| Token | Giá trị |
|---|---|
| Page padding | 16 dp |
| Card border radius | 16 dp |
| Input border radius | 12 dp |
| Chip border radius | 24 dp |
| Card elevation | 12 |
| FAB elevation | 3 |

---

##  Navigation & Data Passing Flow

```
HomeScreen
  AddEditNoteScreen (slide từ dưới + fade)
       Navigator.pop(context, newNote)     trả NoteModel về

  NoteDetailScreen (slide từ phải + fade)
       AddEditNoteScreen (slide từ phải)
            Navigator.pop(context, updatedNote)
       Navigator.pop(context, updatedNote)

 AddEditNoteScreen  DrawNoteScreen (fade)
        Navigator.pop(context, pngFilePath)    trả String path
```

**Pattern sử dụng:**

```dart
// Gửi và CHỜ kết quả từ màn hình mới
final result = await Navigator.push<NoteModel>(
  context,
  PageRouteBuilder(pageBuilder: ..., transitionsBuilder: ...),
);
if (result != null) { /* xử lý */ }

// Trả kết quả về
Navigator.pop(context, noteModel);
```

---

##  Animations

| Animation | Nơi dùng | Curve |
|---|---|---|
| FAB scale ElasticOut | HomeScreen init | Curves.elasticOut |
| Slide (dưới lên) + Fade | Add Note route | Curves.easeOutCubic |
| Slide (phải sang) + Fade | Detail/Edit route | Curves.easeOutCubic |
| AnimatedList insert | Thêm note mới | 400ms |
| SizeTransition + Fade exit | Xóa note | 300ms |
| Scale + Fade intro | EmptyState widget | Curves.elasticOut |
| AnimatedContainer | Chip active state | 200ms |
| Quadratic Bezier stroke | Drawing canvas | realtime |

---



| Test case | Thao tác |
|---|---|
| Thêm note | Tap FAB "New Note"  nhập  Save |
| Xem chi tiết | Tap vào card  xem detail |
| Sửa note | Chi tiết  Edit (icon bút)  sửa  Save |
| Xóa note | Tap icon thùng rác trên card  Confirm |
| Thêm ảnh | New Note  tap "Photo"  chọn ảnh từ gallery |
| Thêm file | New Note  tap "Document"  chọn file |
| Vẽ tay | New Note  tap "Draw"  vẽ  Save |
| Dark mode | Emulator Settings  Display  Dark Theme |

### Thêm ảnh vào emulator gallery

```bash
# Push ảnh từ máy tính vào emulator
adb push C:\path\to\photo.jpg /storage/emulated/0/Pictures/

# Làm mới media scan
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
    -d file:///storage/emulated/0/Pictures/photo.jpg
```

### Kiểm tra file đã lưu

```bash
# Xem thư mục lưu file
adb shell ls -la \
  /storage/emulated/0/Android/data/com.example.baisimplenote/files/

# Xem SharedPreferences (text notes)
adb shell run-as com.example.baisimplenote \
  cat /data/data/com.example.baisimplenote/shared_prefs/FlutterSharedPreferences.xml

# Pull toàn bộ files về máy tính
adb pull \
  /storage/emulated/0/Android/data/com.example.baisimplenote/files/ \
  ./pulled_files/
```

---

##  Kiến trúc

```

                   UI LAYER                          
  HomeScreen  AddEditScreen  DetailScreen            
  DrawScreen  NoteCard  EmptyStateWidget             

                     gọi service

                SERVICE LAYER                        
  NoteService (CRUD)      FileService (I/O)          

                     lưu/đọc

                DATA LAYER                           
  SharedPreferences         File System              
  (JSON text)        (images / docs / drawings)      

                    

                MODEL LAYER                          
  NoteModel  (id, title, content, paths, dates)     

```

**State Management hiện tại:** `setState()`  đủ dùng cho app nhỏ/trung bình.
**Để scale lên production lớn:** thay bằng **Riverpod** hoặc **flutter_bloc**.

---

##  Checklist kỹ năng Flutter

- [x] Navigator.push / pop với data passing
- [x] PageRouteBuilder + custom transitions
- [x] AnimatedList (insert / remove item)
- [x] setState() state management
- [x] SharedPreferences (local storage)
- [x] image_picker + file_picker (file handling)
- [x] CustomPainter (drawing canvas)
- [x] RepaintBoundary.toImage() (export PNG)
- [x] Material Design 3 (ColorScheme.fromSeed, useMaterial3: true)
- [x] Dark mode / Light mode
- [x] Null safety (Dart 3.x)
- [x] Clean architecture (model / service / screen / widget / utils)
- [x] Form validation
- [x] AlertDialog confirmation
- [x] Android permissions (Scoped Storage)

---

##  Ghi chú kỹ thuật

### Vấn đề copyWith + nullable fields

`NoteModel.copyWith()` sử dụng pattern **Sentinel Object** (`_Undefined`) để phân biệt:
- "Không truyền giá trị"  giữ nguyên giá trị cũ
- "Truyền null"  xóa attachment

```dart
// Xóa ảnh đính kèm:
note.copyWith(imagePath: null)  //  works với sentinel pattern

// Giữ ảnh cũ (không truyền gì):
note.copyWith(title: 'New title')  // imagePath giữ nguyên
```

### Drawing performance

Canvas sử dụng **Quadratic Bezier** thay vì lineTo thẳng để nét vẽ mượt mà hơn:
```dart
path.quadraticBezierTo(
  controlPoint.dx, controlPoint.dy,
  midPoint.dx, midPoint.dy,
);
```

---

*Smart Note Pro  Built with Flutter  & Material Design 3*
