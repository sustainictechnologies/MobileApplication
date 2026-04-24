import 'package:flutter_test/flutter_test.dart';
import 'package:jal_smart_water_refill/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JalApp());
    expect(find.byType(JalApp), findsOneWidget);
  });
}
