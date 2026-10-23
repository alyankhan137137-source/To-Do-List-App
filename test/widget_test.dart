import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_listapp/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initialization test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('TaskFlow Pro'), findsOneWidget);
  });
}
