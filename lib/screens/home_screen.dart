import 'package:flutter/material.dart';
import '../routes/navigation_helper.dart';
import 'student_list_screen.dart';
import 'todo_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng Dụng Quản Lý'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: onToggleTheme,
            tooltip: 'Chuyển giao diện',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuCard(
                context,
                title: '👥 Quản Lý Sinh Viên',
                description: 'Quản lý danh sách sinh viên, điểm số',
                color: Colors.blue,
                icon: Icons.people,
                onTap: () {
                  NavigationHelper.navigateTo(
                    context,
                    (context) => const StudentListScreen(),
                    transitionType: TransitionType.slideRight,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildMenuCard(
                context,
                title: '✓ Ghi Chú',
                description: 'Quản lý các công việc cần làm',
                color: Colors.green,
                icon: Icons.task_alt,
                onTap: () {
                  NavigationHelper.navigateTo(
                    context,
                    (context) => const TodoListScreen(),
                    transitionType: TransitionType.sharedAxisVertical,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.85),
                        color.withOpacity(0.45),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            icon,
                            size: 32,
                            color: Colors.white,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
