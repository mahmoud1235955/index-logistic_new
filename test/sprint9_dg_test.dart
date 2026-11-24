import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/theme/app_theme.dart';
import 'package:index_logistic/features/catalog/presentation/catalog_screen.dart';
import 'package:index_logistic/features/dangerous_goods/domain/dg_models.dart';
import 'package:index_logistic/features/dangerous_goods/presentation/dg_copy.dart';
import 'package:index_logistic/features/dangerous_goods/presentation/dg_cubits.dart';
import 'package:index_logistic/features/dangerous_goods/presentation/dg_hub.dart';
import 'package:index_logistic/features/trade/domain/shipment.dart';
import 'package:index_logistic/features/trade/presentation/trade_screen.dart';

const _english = AppCopy(AppLanguage.english);

void main() {
  for (final (id, mode) in [
    ('CAT-33', null),
    ('CAT-09', DgMode.sea),
    ('CAT-10', DgMode.air),
    ('CAT-11', DgMode.road),
    ('CAT-18', null),
    ('CAT-34', null),
  ]) {
    testWidgets('$id opens shared hub with the relevant mode', (tester) async {
      _viewport(tester, 1280);
      await tester.pumpWidget(
        const MaterialApp(home: CatalogScreen(copy: _english)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('catalog-search')), id);
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(ValueKey(id)));
      await _tap(tester, find.byKey(const ValueKey('catalog-dg-hub')));
      expect(
        tester.widget<DangerousGoodsHub>(find.byType(DangerousGoodsHub)).mode,
        mode,
      );
    });
  }

  testWidgets('trade flow opens the same hub with shipment transport context', (
    tester,
  ) async {
    _viewport(tester, 1280);
    await tester.pumpWidget(
      MaterialApp(
        theme: IndexTheme.light,
        home: const TradeScreen(copy: _english, mode: TradeMode.freight),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('trade-dg-hub')));
    expect(
      tester.widget<DangerousGoodsHub>(find.byType(DangerousGoodsHub)).mode,
      DgMode.sea,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(TradeScreen), findsOneWidget);
  });

  testWidgets(
    'search shows unavailable, validates UN and opens a labeled synthetic record',
    (tester) async {
      _viewport(tester, 390);
      await _hub(tester, AppLanguage.english);
      await _tap(tester, find.byKey(const ValueKey('dg-search-action')));
      const copy = DgCopy(_english);
      expect(find.text(copy.unavailable), findsOneWidget);
      final search = find.byKey(const ValueKey('dg-search'));
      await tester.enterText(search, 'UN 99');
      await tester.pumpAndSettle();
      expect(find.text(copy.invalidUn), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('dg-toggle-demo')));
      await tester.enterText(search, 'UN ٩٩٠٩');
      await tester.pumpAndSettle();
      await _tap(
        tester,
        find.byKey(const ValueKey('dg-record-9909-Fictional training entry 9')),
      );
      expect(find.text(copy.demo), findsOneWidget);
      expect(find.text(copy.unavailable), findsNWidgets(3));
    },
  );

  testWidgets(
    'battery choice opens conditional fields and transport selection is retained',
    (tester) async {
      _viewport(tester, 1280);
      await _hub(tester, AppLanguage.english);
      await _tap(tester, find.byKey(const ValueKey('dg-wizard-action')));
      final battery = find.byKey(const ValueKey('dg-input-battery'));
      expect(find.byKey(const ValueKey('dg-input-chemistry')), findsNothing);
      await _tap(
        tester,
        find.descendant(of: battery, matching: find.byType(OutlinedButton)),
      );
      await _tap(tester, find.text('Contains batteries'));
      expect(find.byKey(const ValueKey('dg-input-chemistry')), findsOneWidget);
      final mode = find.byKey(const ValueKey('dg-input-mode'));
      await _tap(
        tester,
        find.descendant(of: mode, matching: find.byType(OutlinedButton)),
      );
      await _tap(tester, find.text('Road'));
      await _tap(tester, find.byKey(const ValueKey('dg-next')));
      expect(
        find.byKey(const ValueKey('dg-input-batteryTests')),
        findsOneWidget,
      );
      final cubit = tester
          .element(find.byType(LinearProgressIndicator))
          .read<DgWizardCubit>();
      expect(cubit.state.draft.mode, DgMode.road);
    },
  );

  for (final language in [AppLanguage.english, AppLanguage.arabic]) {
    for (final width in [360.0, 390.0, 768.0, 1280.0, 1440.0]) {
      testWidgets(
        '${language.name} at $width px and 200% text through readiness',
        (tester) async {
          _viewport(tester, width, scale: 2);
          await _hub(tester, language);
          final copy = DgCopy(AppCopy(language));
          await _tap(tester, find.byKey(const ValueKey('dg-wizard-action')));
          final context = tester.element(find.byType(LinearProgressIndicator));
          expect(
            Directionality.of(context),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          final cubit = context.read<DgWizardCubit>()..example();
          for (var i = 0; i < 3; i++) {
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await cubit.next();
          }
          await tester.pumpAndSettle();
          expect(
            find.text(copy.status(cubit.state.assessment!.status)),
            findsOneWidget,
          );
          expect(find.text(copy.demo), findsOneWidget);
          expect(find.text(copy.disclaimer), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

void _viewport(WidgetTester tester, double width, {double scale = 1}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 920);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _hub(WidgetTester tester, AppLanguage language) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: IndexTheme.light,
      builder: (context, child) => Directionality(
        textDirection: language == AppLanguage.arabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child!,
      ),
      home: DangerousGoodsHub(copy: AppCopy(language)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  if (target.hitTestable().evaluate().isEmpty) {
    await tester.dragUntilVisible(
      target.hitTestable(),
      find.byType(ListView).last,
      const Offset(0, -280),
    );
  }
  await tester.tap(target);
  await tester.pumpAndSettle();
}
