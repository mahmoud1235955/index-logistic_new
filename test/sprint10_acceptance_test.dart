import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/theme/app_theme.dart';
import 'package:index_logistic/features/journeys/domain/local_workspace.dart';
import 'package:index_logistic/features/journeys/presentation/commercial_board.dart';

void main() {
  testWidgets(
    'catalog event scope exposes specific filters and honest unavailable results',
    (tester) async {
      _viewport(tester, 1280);
      await tester.pumpWidget(const IndexLogisticsApp());
      await tester.pumpAndSettle();
      final shortcut = find.descendant(
        of: find.byKey(const ValueKey('home-catalog-shortcut')),
        matching: find.byType(FilledButton),
      );
      await tester.ensureVisible(shortcut);
      await tester.pumpAndSettle();
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('catalog-search')),
        'CAT-15',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('CAT-15')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('category-workspace-entry')));
      await tester.pumpAndSettle();
      expect(find.text('Organizer'), findsOneWidget);
      expect(find.text('Port or entry point'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('category-lookup-check')));
      await tester.pumpAndSettle();
      expect(find.text('Verified data unavailable'), findsOneWidget);
    },
  );

  for (final language in [AppLanguage.english, AppLanguage.arabic]) {
    for (final width in [360.0, 390.0, 768.0, 1280.0, 1440.0]) {
      testWidgets('community fits ${language.name} at $width and 200% text', (
        tester,
      ) async {
        _viewport(tester, width, scale: 2);
        final local = LocalWorkspace();
        addTearDown(local.close);
        await tester.pumpWidget(
          MaterialApp(
            theme: IndexTheme.light,
            builder: (context, child) => Directionality(
              textDirection: language == AppLanguage.arabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            ),
            home: CommercialBoard(copy: AppCopy(language), workspace: local),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CommercialBoard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

void _viewport(WidgetTester tester, double width, {double scale = 1}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
