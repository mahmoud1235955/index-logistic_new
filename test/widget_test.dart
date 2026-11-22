// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:index_logistic/app.dart';

void main() {
  testWidgets('shows the Index Logistics preview and can switch language', (WidgetTester tester) async {
    await tester.pumpWidget(const IndexLogisticsApp());

    expect(find.text('Trade, connected.\nBusiness without borders.'), findsOneWidget);
    await tester.tap(find.text('عربي'));
    await tester.pumpAndSettle();
    expect(find.text('تجارة أكثر ترابطًا.\nوأعمال تتجاوز الحدود.'), findsOneWidget);
  });
}
