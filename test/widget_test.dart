import 'package:flutter_test/flutter_test.dart';

import 'package:edutube_shorts/main.dart';

void main() {
  testWidgets('Home loads first course from seed data', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Communication'), findsOneWidget);
  });
}
