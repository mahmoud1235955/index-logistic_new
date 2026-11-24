import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/theme/app_theme.dart';
import 'package:index_logistic/features/catalog/presentation/catalog_screen.dart';
import 'package:index_logistic/features/trade/domain/shipment.dart';
import 'package:index_logistic/features/trade/presentation/trade_copy.dart';
import 'package:index_logistic/features/trade/presentation/trade_cubit.dart';
import 'package:index_logistic/features/trade/presentation/trade_screen.dart';

const _next = ValueKey('trade-next');
const _back = ValueKey('trade-back');

void main() {
  for (final (title, mode) in [
    ("I'm an Importer", TradeMode.landed),
    ("I'm an Exporter", TradeMode.export),
  ]) {
    testWidgets('$title journey opens its trade mode', (tester) async {
      _viewport(tester, 390);
      await tester.pumpWidget(const IndexLogisticsApp());
      await tester.pumpAndSettle();
      final entry = find.text(title);
      await tester.dragUntilVisible(
        entry.hitTestable(),
        find.byKey(const ValueKey('home-page-scroll')),
        const Offset(0, -280),
      );
      await tester.tap(entry);
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const ValueKey('home-journey-trade')));
      expect(tester.widget<TradeScreen>(find.byType(TradeScreen)).mode, mode);
    });
  }

  for (final (id, mode) in [
    ('CAT-27', TradeMode.freight),
    ('CAT-28', TradeMode.export),
    ('CAT-31', TradeMode.landed),
  ]) {
    testWidgets('$id opens the expected trade mode', (tester) async {
      _viewport(tester, 1280);
      await tester.pumpWidget(
        const MaterialApp(
          home: CatalogScreen(copy: AppCopy(AppLanguage.english)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('catalog-search')), id);
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(ValueKey(id)));
      if (id == 'CAT-31') {
        expect(
          find.byKey(const ValueKey('catalog-vehicle-import')),
          findsOneWidget,
        );
      }
      await _tap(
        tester,
        find.byKey(const ValueKey('catalog-trade-calculator')),
      );
      expect(tester.widget<TradeScreen>(find.byType(TradeScreen)).mode, mode);
    });
  }

  testWidgets(
    'validation, recalculation and local comparison preserve the earlier result',
    (tester) async {
      _viewport(tester, 1280);
      await _pump(tester, AppLanguage.english, TradeMode.export);
      final cubit = _cubit(tester);
      await _tap(tester, find.byKey(_next));
      expect(cubit.state.step, TradeStep.shipment);
      expect(find.text('Required.'), findsWidgets);
      await _tap(tester, find.byKey(const ValueKey('trade-demo')));
      await cubit.next();
      await cubit.next();
      cubit.editDraft(field: Field.goal, value: '100');
      await cubit.next();
      await tester.pumpAndSettle();
      expect(cubit.state.step, TradeStep.costs);
      expect(find.text('Margin must be below 100%.'), findsOneWidget);
      cubit.editDraft(field: Field.goal, value: '20');
      await cubit.next();
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(_next));
      expect(cubit.state.result!.price!.format(), '353.75');
      await _tap(tester, find.byKey(const ValueKey('trade-save')));
      await _tap(tester, find.byKey(_back));
      cubit.go(TradeStep.costs);
      cubit.editDraft(priceGoal: PriceGoal.markup);
      await cubit.next();
      await cubit.next();
      await tester.pumpAndSettle();
      cubit.toggleSaved();
      await tester.pumpAndSettle();
      expect(cubit.state.saved.map((result) => result.price!.format()), [
        '353.75',
        '339.60',
      ]);
      expect(find.text('Scenario 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'changing carrier basis clears prior price and incompatible terms are flagged',
    (tester) async {
      _viewport(tester, 390);
      await _pump(tester, AppLanguage.english, TradeMode.freight);
      final cubit = _cubit(tester)..loadDemo();
      cubit.editDraft(transport: Transport.sea, term: Incoterm.fob);
      cubit.editDraft(field: Field.rate, value: '100');
      cubit.editDraft(transport: Transport.road);
      await cubit.next();
      await tester.pumpAndSettle();
      expect(cubit.state.shipment.text(Field.rate), isEmpty);
      expect(
        find.text('Choose an Incoterm compatible with transport.'),
        findsOneWidget,
      );
    },
  );

  for (final language in [AppLanguage.english, AppLanguage.arabic]) {
    for (final width in [360.0, 390.0, 768.0, 1280.0, 1440.0]) {
      testWidgets(
        '${language.name} at $width px and 200% text through the trade flow',
        (tester) async {
          _viewport(tester, width, scale: 2);
          await _pump(tester, language, TradeMode.landed);
          final cubit = _cubit(tester)..loadDemo();
          final copy = TradeCopy(AppCopy(language));
          expect(
            Directionality.of(
              tester.element(find.byType(LinearProgressIndicator)),
            ),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          for (final step in TradeStep.values.take(4)) {
            await tester.pumpAndSettle();
            expect(find.text(copy.step(step)).first, findsOneWidget);
            expect(tester.takeException(), isNull);
            await cubit.next();
          }
          await tester.pumpAndSettle();
          expect(cubit.state.result!.total!.format(), '468.00');
          expect(find.text(copy.demo), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
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

Future<void> _pump(
  WidgetTester tester,
  AppLanguage language,
  TradeMode mode,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: IndexTheme.light,
      builder: (context, child) => Directionality(
        textDirection: language == AppLanguage.arabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child!,
      ),
      home: TradeScreen(copy: AppCopy(language), mode: mode),
    ),
  );
  await tester.pumpAndSettle();
}

TradeCubit _cubit(WidgetTester tester) =>
    tester.element(find.byType(LinearProgressIndicator)).read<TradeCubit>();

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
