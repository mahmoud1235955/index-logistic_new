import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/theme/app_theme.dart';
import 'package:index_logistic/features/catalog/presentation/catalog_screen.dart';
import 'package:index_logistic/features/vehicle/domain/country_rule_provider.dart';
import 'package:index_logistic/features/vehicle/domain/vehicle_profile.dart';
import 'package:index_logistic/features/vehicle/presentation/vehicle_copy.dart';
import 'package:index_logistic/features/vehicle/presentation/vehicle_cubit.dart';
import 'package:index_logistic/features/vehicle/presentation/vehicle_screen.dart';

const _next = ValueKey('vehicle-next');
const _back = ValueKey('vehicle-back');

void main() {
  testWidgets('Home Vehicles opens the shared form', (tester) async {
    _viewport(tester, 390);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();
    final button = find.text('Vehicles');
    await tester.dragUntilVisible(
      button.hitTestable(),
      find.byKey(const ValueKey('home-page-scroll')),
      const Offset(0, -250),
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(VehicleImportScreen), findsOneWidget);
  });

  for (final id in ['CAT-03', 'CAT-31']) {
    testWidgets('$id links to the same shared form', (tester) async {
      _viewport(tester, 1280);
      await tester.pumpWidget(
        const MaterialApp(
          home: CatalogScreen(copy: AppCopy(AppLanguage.english)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('catalog-search')), id);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey(id)));
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const ValueKey('catalog-vehicle-import')));
      expect(find.byType(VehicleImportScreen), findsOneWidget);
    });
  }

  testWidgets(
    'validates steps, changes conditional fields and preserves edits',
    (tester) async {
      _viewport(tester, 390);
      await _pump(tester, AppLanguage.english);
      final cubit = _cubit(tester);
      await _tap(tester, find.byKey(_next));
      expect(cubit.state.step, VehicleStep.vehicle);
      expect(find.text('Required.'), findsWidgets);

      final fuel = find.byKey(const ValueKey('vehicle-input-fuel'));
      await _tap(tester, fuel);
      await _tap(tester, find.text('Electric'));
      expect(find.byKey(const ValueKey(VehicleField.powerKw)), findsOneWidget);
      expect(find.byKey(const ValueKey(VehicleField.engineCc)), findsNothing);
      cubit.change(VehicleField.fuel, Fuel.hybrid.name);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(VehicleField.engineCc)), findsOneWidget);
      cubit.change(VehicleField.category, VehicleCategory.truck.name);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey(VehicleField.payloadKg)),
        findsOneWidget,
      );

      _fill(cubit);
      cubit.change(VehicleField.engineCc, '12.5');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(_next));
      expect(find.text('Enter a whole number.'), findsOneWidget);
      cubit.change(VehicleField.engineCc, '1500');
      await cubit.next();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey(VehicleField.residency)),
        findsOneWidget,
      );
      cubit.change(VehicleField.importer, ImporterKind.company.name);
      cubit.change(VehicleField.regime, ImportRegime.temporary.name);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(VehicleField.residency)), findsNothing);
      expect(
        find.byKey(const ValueKey(VehicleField.temporaryDays)),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey(VehicleField.preferenceProgram)),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey(VehicleField.documents)),
        findsOneWidget,
      );
      await cubit.next();
      cubit.change(VehicleField.currency, Currency.usd.name);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey(VehicleField.exchangeSource)),
        findsOneWidget,
      );
      cubit.change(VehicleField.purchase, '-20');
      await cubit.next();
      await tester.pumpAndSettle();
      expect(cubit.state.step, VehicleStep.finance);
      cubit.change(VehicleField.purchase, '10000');
      await cubit.next();
      await tester.pumpAndSettle();
      expect(find.text('Review your information'), findsOneWidget);
      await _tap(tester, find.byKey(_next));
      expect(find.text('Incomplete estimate'), findsOneWidget);
      expect(find.text('Unable to determine'), findsOneWidget);
      await _tap(tester, find.byKey(_back));
      expect(cubit.state.profile.text(VehicleField.purchase), '10000');
      expect(find.text('Review your information'), findsOneWidget);
    },
  );

  for (final language in [AppLanguage.english, AppLanguage.arabic]) {
    for (final width in [360.0, 390.0, 768.0, 1280.0, 1440.0]) {
      testWidgets('${language.name} $width at 200% across all steps', (
        tester,
      ) async {
        _viewport(tester, width, scale: 2);
        await _pump(tester, language);
        final copy = VehicleCopy(AppCopy(language));
        final cubit = _cubit(tester);
        expect(
          Directionality.of(
            tester.element(find.byType(LinearProgressIndicator)),
          ),
          language == AppLanguage.arabic
              ? TextDirection.rtl
              : TextDirection.ltr,
        );
        _fill(cubit);
        for (var step = 0; step < 3; step++) {
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await cubit.next();
        }
        cubit.selectScenario(VehicleScenario.conditional);
        await tester.pumpAndSettle();
        expect(find.text(copy.synthetic), findsOneWidget);
        await cubit.next();
        await tester.pumpAndSettle();
        expect(find.text(copy.synthetic), findsOneWidget);
        expect(
          find.text(copy.eligibility(cubit.state.assessment!.status)),
          findsOneWidget,
        );
        expect(cubit.state.estimate!.total, 12238);
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

Future<void> _pump(WidgetTester tester, AppLanguage language) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: IndexTheme.light,
      builder: (context, child) => Directionality(
        textDirection: language == AppLanguage.arabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child!,
      ),
      home: VehicleImportScreen(copy: AppCopy(language)),
    ),
  );
  await tester.pumpAndSettle();
}

VehicleCubit _cubit(WidgetTester tester) =>
    tester.element(find.byType(LinearProgressIndicator)).read<VehicleCubit>();

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  if (finder.hitTestable().evaluate().isEmpty) {
    await tester.dragUntilVisible(
      finder.hitTestable(),
      find.byType(ListView).last,
      const Offset(0, -300),
    );
  }
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _fill(VehicleCubit cubit) {
  const draft = {
    VehicleField.category: 'passenger',
    VehicleField.manufacturer: 'Demo Motors',
    VehicleField.model: 'Sample',
    VehicleField.manufacturingYear: '2024',
    VehicleField.modelYear: '2025',
    VehicleField.condition: 'used',
    VehicleField.fuel: 'hybrid',
    VehicleField.engineCc: '1500',
    VehicleField.origin: 'Japan',
    VehicleField.exportCountry: 'United Arab Emirates',
    VehicleField.importer: 'individual',
    VehicleField.use: 'personal',
    VehicleField.regime: 'preferential',
    VehicleField.residency: 'resident',
    VehicleField.currency: 'egp',
    VehicleField.purchase: '10000',
    VehicleField.freight: '1000',
    VehicleField.insurance: '100',
    VehicleField.otherCosts: '50',
    VehicleField.handling: '200',
  };
  for (final entry in draft.entries) {
    cubit.change(entry.key, entry.value);
  }
}
