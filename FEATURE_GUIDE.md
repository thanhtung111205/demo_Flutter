# 🎯 Hướng Dẫn Sử Dụng Tính Năng Mới

## ✨ Tính Năng Vừa Bổ Sung

### 1. 🔍 **Tìm Kiếm Công Việc**

**Vị Trí:** Dưới trường "Nhập công việc cần làm..."

**Cách Sử Dụng:**
- Nhập từ khóa vào trường tìm kiếm
- Tìm kiếm theo **tiêu đề** công việc
- Tìm kiếm theo **ghi chú** chi tiết
- Nhấn nút **✕** để xóa tìm kiếm

**Ví dụ:**
```
Nhập: "báo cáo"
→ Hiển thị tất cả công việc có "báo cáo" trong tiêu đề hoặc ghi chú
```

---

### 2. 📝 **Ghi Chú Chi Tiết (Notes)**

**Cách Sử Dụng:**
1. Nhấn nút **⋮** (3 chấm) trên công việc
2. Chọn **"Ghi chú"**
3. Nhập ghi chú chi tiết (có thể nhiều dòng)
4. Nhấn **"Lưu"**

**Ví dụ Ghi Chú:**
```
- Hoàn thành báo cáo tháng 2
- Cần kiểm tra lại dữ liệu
- Gửi cho quản lý trước 28/02
```

**Hiển Thị:**
- Khi có ghi chú, sẽ xuất hiện icon 📝 trên công việc
- Click để xem chi tiết ghi chú

---

### 3. 📎 **Tệp/Ảnh Đính Kèm**

**Cách Thêm File:**
1. Nhấn nút **⋮** (3 chấm) trên công việc
2. Chọn **"Tệp đính kèm"**
3. Xuất hiện dialog với 2 nút:
   - **Thêm Ảnh** 🖼️ - Chọn ảnh từ gallery
   - **Thêm File** 📄 - Chọn file từ thiết bị

**Loại File Hỗ Trợ:**
- ✅ **Ảnh:** JPG, PNG, GIF, WebP
- ✅ **Tài Liệu:** PDF, Word, Excel, PowerPoint, TXT
- ✅ **Khác:** Hầu hết file thông dụng

**Cách Xóa File:**
1. Mở dialog "Tệp đính kèm"
2. Nhấn icon **🗑️** (xóa) trên file
3. Xác nhận xóa

**Hiển Thị:**
- Khi có file đính kèm, xuất hiện **📎 [số file]** trên công việc
- Ví: "📎 2 file đính kèm"

---

### 4. 📁 **Vị Trí Lưu Trữ**

**Các Tệp & Thư Mục:**

```
📱 Thiết Bị (ApplicationDocumentsDirectory)
├── 📄 tasks.json          ← Ghi Chú + ghi chú
├── 📄 students.json       ← Danh sách học sinh
├── 📄 settings.json       ← Cấu hình ứng dụng
│
└── 📁 task_attachments/   ← Thư mục file/ảnh đính kèm
    ├── 📁 [task_id_1]/
    │   ├── 📸 1708934400000_photo.jpg
    │   └── 📄 1708934500000_notes.pdf
    │
    ├── 📁 [task_id_2]/
    │   └── 📊 1708934700000_report.xlsx
    │
    └── 📁 [task_id_3]/
        └── ...
```

**Lưu Ở Đâu Theo Nền Tảng:**

| Nền Tảng | Đường Dẫn |
|----------|---------|
| 🤖 **Android** | `/data/user/0/com.example.flutter_demo/files/` |
| 🍎 **iOS** | `/var/mobile/Containers/Data/Application/.../Documents/` |
| 🪟 **Windows** | `C:\Users\[user]\AppData\Local\flutter_demo\` |
| 🐧 **Linux** | `~/.local/share/flutter_demo/` |

---

## 🎮 Giao Diện Mới

### Ghi Chú

```
┌─────────────────────────┐
│ Ghi Chú    │
├─────────────────────────┤
│ 🔧 Nhập công việc...   │  [+]  ← Nút thêm
├─────────────────────────┤
│ 🔍 Tìm kiếm công việc   │  [✕]  ← Xóa tìm kiếm
├─────────────────────────┤
│ Thống Kê:               │
│ [5 Tổng] [4 Chưa] [1 Xong]
│ [1 Cao] [4 TB] [0 Thấp]
├─────────────────────────┤
│ 📝 Hoàn thành báo cáo   │
│    Hạn: 2026-02-28      │
│    📎 1 file đính kèm   │  [⋮]
│    MEDIUM [✓] [🗑️]      │
├─────────────────────────┤
│ ☐ eh2e (Chưa hoàn)      │
│    Hạn: 2026-02-11      │
│    MEDIUM [🗑️] [⋮]      │
└─────────────────────────┘
```

### Dialog Ghi Chú

```
┌──────────────────────────┐
│ Chỉnh Sửa Ghi Chú        │
├──────────────────────────┤
│ ┌────────────────────┐  │
│ │ Nhập ghi chú...    │  │
│ │ • Điểm cần chú ý   │  │
│ │ • Deadline là...   │  │
│ └────────────────────┘  │
├──────────────────────────┤
│ [Hủy]           [Lưu]   │
└──────────────────────────┘
```

### Dialog Tệp Đính Kèm

```
┌──────────────────────────┐
│ Tệp Đính Kèm             │
├──────────────────────────┤
│ 🖼️ photo.jpg             │
│    02-26 15:30    [🗑️]   │
│                          │
│ 📄 report.pdf            │
│    02-26 15:35    [🗑️]   │
│                          │
│ ℹ️ Lưu tại:              │
│ ApplicationDocuments.../ │
│ task_attachments/[id]/   │
│                          │
│ [Thêm Ảnh] [Thêm File]   │
├──────────────────────────┤
│              [Đóng]      │
└──────────────────────────┘
```

---

## ⚙️ Popup Menu (⋮) Các Tùy Chọn

1. **📝 Ghi Chú** - Thêm/chỉnh sửa ghi chú chi tiết
2. **📎 Tệp đính kèm** - Quản lý ảnh, file
3. **🗑️ Xóa** - Xóa công việc (xóa cả file đính kèm)

---

## 💡 Tips & Thủ Thuật

### ✅ Tối Ưu Hóa
- **Nén ảnh:** Ứng dụng tự động nén ảnh (imageQuality: 85%)
- **Tìm kiếm nhanh:** Debounce 300ms, không cần nhấn Enter
- **Xóa nhanh:** Nút ✕ trên tìm kiếm để xóa ngay

### 🚨 Lưu Ý
- **Xóa công việc = Xóa file:** Khi xóa công việc, toàn bộ file sẽ bị xóa
- **Không sao lưu tự động:** Cần bật backup trong cài đặt thiết bị
- **Giới hạn dung lượng:** Nên giữ tổng file < 500MB

---

## ❓ Câu Hỏi Thường Gặp (FAQ)

### Q: Tôi không thấy nút thêm ảnh/file?
**A:** Cần rebuild ứng dụng:
```bash
flutter clean
flutter pub get
flutter run
```

### Q: File/ảnh bị lỗi khi thêm?
**A:** Kiểm tra:
- ✅ Quyền truy cập file
- ✅ Dung lượng thiết bị
- ✅ Kích thước file không quá lớn

### Q: Làm sao xem lại file đã lưu?
**A:**
- Mở dialog "Tệp đính kèm"
- Xem danh sách file + ngày thêm
- Các file được lưu ở: `task_attachments/[task_id]/`

### Q: Làm sao xóa tất cả dữ liệu?
**A:**
1. Gỡ cài đặt ứng dụng
2. Hoặc xóa thủ công thư mục `/data/user/0/com.example.flutter_demo/files/`

---

## 📚 Tài Liệu Thêm

Xem chi tiết tại:
- 📄 [STORAGE_DOCUMENTATION.md](./STORAGE_DOCUMENTATION.md)
- 📄 [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)

---

**Cập nhật:** 26-02-2026 | **Phiên bản:** 2.0
