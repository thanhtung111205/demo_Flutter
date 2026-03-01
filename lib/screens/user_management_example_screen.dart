import 'package:flutter/material.dart';
import '../routes/navigation_helper.dart';
import '../widgets/md3_components.dart';

/// Example demonstrating data passing between screens with animations

// Data model để truyền giữa các màn hình
class UserData {
  final String id;
  final String name;
  final String email;
  final String avatar;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });
}

/// Main screen - danh sách người dùng
class UserListExampleScreen extends StatefulWidget {
  const UserListExampleScreen({super.key});

  @override
  State<UserListExampleScreen> createState() => _UserListExampleScreenState();
}

class _UserListExampleScreenState extends State<UserListExampleScreen> {
  late List<UserData> users = [
    UserData(
      id: '1',
      name: 'Nguyễn Thị Hương',
      email: 'huong@example.com',
      avatar: '👩',
    ),
    UserData(
      id: '2',
      name: 'Trần Văn Anh',
      email: 'anh@example.com',
      avatar: '👨',
    ),
    UserData(
      id: '3',
      name: 'Phạm Minh Tuấn',
      email: 'tuan@example.com',
      avatar: '👨‍💼',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MD3AppBar(
        title: 'Danh Sách Người Dùng',
        showBackButton: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(
            user: user,
            onTap: () async {
              // Chuyển sang DetailScreen với dữ liệu người dùng
              // Và chờ kết quả (true = đã cập nhật, false = hủy)
              final updated = await NavigationHelper.navigateTo(
                context,
                (context) => UserDetailExampleScreen(user: user),
                transitionType: TransitionType.slideRight,
                duration: const Duration(milliseconds: 500),
              );

              if (updated == true) {
                // Refresh danh sách (trong thực tế, bạn sẽ gọi API)
                setState(() {
                  // Reload users
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Cập nhật thành công')),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Chuyển sang Create Screen
          final newUser = await NavigationHelper.navigateTo(
            context,
            (context) => const CreateUserExampleScreen(),
            transitionType: TransitionType.scaleFade,
            duration: const Duration(milliseconds: 500),
          );

          if (newUser is UserData) {
            setState(() => users.add(newUser));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Thêm người dùng mới thành công')),
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserData user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MD3Card(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(user.avatar, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

/// Detail screen - xem/chỉnh sửa thông tin người dùng
class UserDetailExampleScreen extends StatefulWidget {
  final UserData user;

  const UserDetailExampleScreen({required this.user});

  @override
  State<UserDetailExampleScreen> createState() =>
      _UserDetailExampleScreenState();
}

class _UserDetailExampleScreenState extends State<UserDetailExampleScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MD3AppBar(
        title: 'Chi Tiết Người Dùng',
        showBackButton: true,
        onLeadingPressed: () => NavigationHelper.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(widget.user.avatar,
                      style: const TextStyle(fontSize: 60)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Section
            Text(
              'Thông Tin Cá Nhân',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Name Input
            MD3TextField(
              labelText: 'Tên',
              controller: _nameController,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),

            // Email Input
            MD3TextField(
              labelText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: MD3OutlinedButton(
                    label: 'Hủy',
                    onPressed: () => NavigationHelper.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MD3ElevatedButton(
                    label: 'Lưu',
                    icon: Icons.save,
                    onPressed: () {
                      // Cập nhật dữ liệu
                      // widget.user.name = _nameController.text;
                      // widget.user.email = _emailController.text;

                      // Trả về true để chỉ dẫn cập nhật thành công
                      NavigationHelper.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

/// Create screen - thêm người dùng mới
class CreateUserExampleScreen extends StatefulWidget {
  const CreateUserExampleScreen({super.key});

  @override
  State<CreateUserExampleScreen> createState() =>
      _CreateUserExampleScreenState();
}

class _CreateUserExampleScreenState extends State<CreateUserExampleScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MD3AppBar(
        title: 'Thêm Người Dùng Mới',
        showBackButton: true,
        onLeadingPressed: () => NavigationHelper.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Selector (Simplified)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chọn avatar',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Section
            Text(
              'Thông Tin Mới',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Name Input
            MD3TextField(
              labelText: 'Tên',
              hintText: 'Nhập tên người dùng',
              controller: _nameController,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),

            // Email Input
            MD3TextField(
              labelText: 'Email',
              hintText: 'Nhập địa chỉ email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: MD3OutlinedButton(
                    label: 'Hủy',
                    onPressed: () => NavigationHelper.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MD3ElevatedButton(
                    label: 'Tạo',
                    icon: Icons.add,
                    onPressed: () {
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('⚠️ Vui lòng điền tất cả thông tin')),
                        );
                        return;
                      }

                      // Tạo người dùng mới
                      final newUser = UserData(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        email: _emailController.text,
                        avatar: '👨', // Có thể chọn từ danh sách
                      );

                      // Trả về dữ liệu người dùng mới
                      NavigationHelper.pop(context, newUser);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
