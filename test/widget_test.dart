// Basic smoke test for Smart Note Pro
import 'package:flutter_test/flutter_test.dart';
import 'package:baisimplenote/app.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartNoteProApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Smart Note Pro'), findsOneWidget);
  });
}
