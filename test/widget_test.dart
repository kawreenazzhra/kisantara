import 'package:flutter_test/flutter_test.dart';
import 'package:kisantara/main.dart';

void main() {
  testWidgets('KisantaraApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KisantaraApp());
    expect(find.text('Kisantara'), findsOneWidget);
  });
}
