import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/main.dart';

void main() {
  testWidgets('Mr. WashWala App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MrWashWalaApp());
    expect(find.byType(MrWashWalaApp), findsOneWidget);
  });
}
