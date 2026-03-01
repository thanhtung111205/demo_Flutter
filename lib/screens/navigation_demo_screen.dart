import 'package:flutter/material.dart';
import '../routes/navigation_helper.dart';
import '../widgets/md3_components.dart';

/// Demo screen to showcase all navigation animations and Material Design 3 components
class NavigationDemoScreen extends StatefulWidget {
  const NavigationDemoScreen({super.key});

  @override
  State<NavigationDemoScreen> createState() => _NavigationDemoScreenState();
}

class _NavigationDemoScreenState extends State<NavigationDemoScreen> {
  String? _selectedTransition;
  Duration _selectedDuration = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MD3AppBar(
        title: 'Navigation & Animation Demo',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Transition Type Selection
            Text(
              'Chọn Loại Transition',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildTransitionSelection(),
            const SizedBox(height: 24),

            // Section 2: Duration Selection
            Text(
              'Chọn Thời Lượng Animation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildDurationSlider(),
            const SizedBox(height: 24),

            // Section 3: Button Examples
            Text(
              'Material Design 3 Components',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildComponentExamples(),
            const SizedBox(height: 24),

            // Section 4: Demo Button
            Center(
              child: MD3ElevatedButton(
                label: 'Demo Navigation với Animation',
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (_selectedTransition != null) {
                    _navigateToDemo();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⚠️ Vui lòng chọn loại transition')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitionSelection() {
    final transitions = {
      'Fade': TransitionType.fade,
      'Slide Right': TransitionType.slideRight,
      'Scale Fade': TransitionType.scaleFade,
      'Shared Axis': TransitionType.sharedAxisVertical,
      'Rotate Fade': TransitionType.rotateFade,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: transitions.entries.map((entry) {
        final isSelected = _selectedTransition == entry.key;
        return FilterChip(
          label: Text(entry.key),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedTransition = selected ? entry.key : null);
          },
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          selectedColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildDurationSlider() {
    final durations = [
      (200, '200ms - Nhanh'),
      (400, '400ms - Bình thường'),
      (600, '600ms - Chậm'),
      (1000, '1000ms - Rất chậm'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: _selectedDuration.inMilliseconds.toDouble(),
          min: 200,
          max: 1000,
          divisions: 8,
          label: '${_selectedDuration.inMilliseconds}ms',
          onChanged: (value) {
            setState(() {
              _selectedDuration = Duration(milliseconds: value.toInt());
            });
          },
        ),
        Wrap(
          spacing: 8,
          children: durations.map((d) {
            final isSelected = _selectedDuration.inMilliseconds == d.$1;
            return InkWell(
              onTap: () => setState(() => _selectedDuration = Duration(milliseconds: d.$1)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d.$2,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildComponentExamples() {
    return Column(
      spacing: 12,
      children: [
        MD3Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'Button Variations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MD3ElevatedButton(
                    label: 'Elevated',
                    icon: Icons.check,
                    onPressed: () {},
                  ),
                  MD3TonalButton(
                    label: 'Tonal',
                    icon: Icons.info,
                    onPressed: () {},
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MD3OutlinedButton(
                    label: 'Outlined',
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                  MD3TextButton(
                    label: 'Text',
                    icon: Icons.delete,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        MD3Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'Badge & Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MD3Badge(label: 'Active', backgroundColor: Colors.green),
                  MD3Badge(label: 'Pending', backgroundColor: Colors.orange),
                  MD3Badge(label: 'Completed', backgroundColor: Colors.blue),
                  // MD3Badge(count: 5, backgroundColor: Colors.red),
                ],
              ),
            ],
          ),
        ),
        MD3Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'Text Input',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              MD3TextField(
                labelText: 'Nhập tên',
                hintText: 'Ví dụ: Nguyễn Văn A',
                prefixIcon: Icons.person,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToDemo() {
    final transitionMap = {
      'Fade': TransitionType.fade,
      'Slide Right': TransitionType.slideRight,
      'Scale Fade': TransitionType.scaleFade,
      'Shared Axis': TransitionType.sharedAxisVertical,
      'Rotate Fade': TransitionType.rotateFade,
    };

    final transitionType = transitionMap[_selectedTransition!]!;

    NavigationHelper.navigateTo(
      context,
      (context) => _DemoDetailScreen(transitionType: transitionType),
      transitionType: transitionType,
      duration: _selectedDuration,
    );
  }
}

class _DemoDetailScreen extends StatelessWidget {
  final TransitionType transitionType;

  const _DemoDetailScreen({required this.transitionType});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: MD3AppBar(
        title: 'Detail Screen',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transition Type:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getTransitionName(transitionType),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              '✨ Animation berhasil ditampilkan!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            MD3ElevatedButton(
              label: 'Kembali Lại',
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransitionName(TransitionType type) {
    return switch (type) {
      TransitionType.fade => 'Fade Transition',
      TransitionType.slideRight => 'Slide Right Transition',
      TransitionType.scaleFade => 'Scale Fade Transition',
      TransitionType.sharedAxisVertical => 'Shared Axis Vertical',
      TransitionType.rotateFade => 'Rotate Fade Transition',
    };
  }
}
