import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/catalog/data/local_category_repository.dart';
import 'package:index_logistic/features/journeys/domain/local_workspace.dart';
import 'package:index_logistic/features/journeys/presentation/category_workspace.dart';
import 'package:index_logistic/features/journeys/presentation/leopard_workspace.dart';

const copy = AppCopy(AppLanguage.english);

void main() {
  for (final (id, label, proof) in [
    ('CAT-16', 'Container planner', 'Container and doorway'),
    ('CAT-25', 'Time and meetings', 'World clock'),
    ('CAT-28', 'International payment methods', 'Documentary credit'),
    ('CAT-30', 'Emissions and CBAM', 'Product embedded-emissions preparation'),
    ('CAT-33', 'Special cargo preparation', 'Oversized cargo'),
    ('CAT-34', 'Cold chain preparation', 'Readiness for specialist review'),
  ]) {
    testWidgets(
      '$id opens its standalone tool at narrow width and 200% scaling',
      (tester) async {
        _mobile(tester, scale: 2);
        final local = LocalWorkspace();
        addTearDown(local.close);
        final category = const LocalCategoryRepository().categories.singleWhere(
          (entry) => entry.id == id,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryWorkspaceEntry(
                copy: copy,
                category: category,
                workspace: (session: local, sectors: [], companies: []),
              ),
            ),
          ),
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(proof), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'feed narrow layout switches supplier and buyer tabs without invented participants',
    (tester) async {
      _mobile(tester);
      final local = LocalWorkspace();
      addTearDown(local.close);
      await tester.pumpWidget(
        MaterialApp(
          home: LeopardWorkspace(copy: copy, workspace: local),
        ),
      );
      final feed = find.text('Feed trade preparation');
      await tester.ensureVisible(feed);
      await tester.pumpAndSettle();
      await tester.tap(feed);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Corn (maize)'));
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
      final buyer = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Buyers'),
      );
      await tester.ensureVisible(buyer);
      await tester.pumpAndSettle();
      await tester.tap(buyer);
      await tester.pumpAndSettle();
      expect(find.text('Buyers'), findsNWidgets(2));
      expect(find.text('Suppliers'), findsOneWidget);
      expect(local.state.quote, isNull);
    },
  );
}

void _mobile(WidgetTester tester, {double scale = 1}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 900);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
