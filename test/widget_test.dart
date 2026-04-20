import 'package:flutter_test/flutter_test.dart';

import 'package:zelby/app.dart';

void main() {
  testWidgets('App redirects to inbox', (WidgetTester tester) async {
    await tester.pumpWidget(const ZelbyApp());
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsWidgets);
  });
}
