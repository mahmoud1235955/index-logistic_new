import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';

void main() {
  testWidgets(
    'Discover opens dedicated sector filtering and searchable sample products',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const IndexLogisticsApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discover').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sector-filter-entry')));
      await tester.pumpAndSettle();
      expect(find.text('Industry sector filters'), findsOneWidget);
      await tester.tap(find.text('Companies'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('workspace-directory-search')),
        'DEMO-HS-01',
      );
      await tester.pumpAndSettle();
      expect(find.text('Sample strawberry product'), findsOneWidget);
      expect(find.text('Sample cotton fabric'), findsNothing);
      await tester.tap(find.text('Sample strawberry product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save locally'));
      await tester.pumpAndSettle();
      expect(find.text('Remove from saved'), findsOneWidget);
    },
  );
}
