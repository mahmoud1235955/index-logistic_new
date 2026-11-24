import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/app/cubit/app_state.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/journeys/data/package_preferences.dart';
import 'package:index_logistic/features/journeys/domain/local_workspace.dart';
import 'package:index_logistic/features/journeys/domain/logistics_tools.dart';
import 'package:index_logistic/features/journeys/domain/meeting_time.dart';
import 'package:index_logistic/features/journeys/domain/package_group.dart';
import 'package:index_logistic/features/journeys/presentation/quote_comparison.dart';
import 'package:index_logistic/features/journeys/presentation/quote_workspace.dart';
import 'package:index_logistic/features/trade/domain/decimal.dart';
import 'package:index_logistic/features/vehicle/domain/customs_calculation.dart';
import 'package:index_logistic/features/vehicle/domain/vehicle_profile.dart';

Decimal d(String text) => Decimal.parse(text)!;
PackageInput group({
  String count = '3',
  String length = '20',
  String width = '40',
  String height = '65',
  String gross = '15',
  MeasureUnit measure = MeasureUnit.centimetre,
  MassUnit mass = MassUnit.kilogram,
}) => PackageInput(
  measure: measure,
  mass: mass,
  values: {
    PackageField.count: count,
    PackageField.length: length,
    PackageField.width: width,
    PackageField.height: height,
    PackageField.gross: gross,
  },
);

void main() {
  test(
    'persisted templates contain only package metrics and reject damaged data',
    () {
      final encoded = PackagePreferences.encode([group(), group(count: '2')])!;
      expect(encoded, isNot(contains('cargo')));
      expect(encoded, isNot(contains('origin')));
      final restored = PackagePreferences.decode(encoded)!;
      expect(CargoTotals.fromInputs(restored)!.kg.format(), '75.00');
      expect(PackagePreferences.decode('[{"type":"carton"}]'), isNull);
      expect(PackagePreferences.encode([group(), group(count: '-2')]), isNull);
    },
  );
  test(
    'vehicle money rounds exactly at EGP half-cent boundaries and preserves missing rules',
    () {
      final input = VehicleProfile({
        VehicleField.currency: 'egp',
        VehicleField.purchase: '١٫٠٠٥',
      });
      final result = const CustomsCalculator().calculate(
        input,
        null,
        DateTime(2026),
        demonstration: false,
      );
      expect(result.costsExact[CostItem.purchase]!.format(), '1.01');
      expect(result.totalExact, isNull);
    },
  );

  test('multi-group cargo normalizes units and rejects incomplete groups', () {
    final single = CargoTotals.fromInputs([group()])!;
    expect(single.cbm.format(3), '0.156');
    expect(single.kg.format(), '45.00');
    final combined = CargoTotals.fromInputs([
      group(),
      group(
        count: '1',
        length: '1',
        width: '1',
        height: '1',
        gross: '1',
        measure: MeasureUnit.metre,
        mass: MassUnit.pound,
      ),
    ])!;
    expect(combined.cbm.format(3), '1.156');
    expect(combined.kg.format(8), '45.45359237');
    expect(CargoTotals.fromInputs([group(), group(count: '1.2')]), isNull);
  });

  test(
    'container utilization alone cannot show door fit; rotations and payload are checked',
    () {
      final box = (
        length: d('5'),
        width: d('2'),
        height: d('2'),
        doorWidth: d('1'),
        doorHeight: d('1'),
        payloadKg: d('100'),
      );
      final rotated = containerFit(box, [
        group(
          count: '1',
          length: '0.5',
          width: '1.5',
          height: '0.5',
          measure: MeasureUnit.metre,
        ),
      ]);
      expect(rotated.status, FitStatus.individualFitOnly);
      final blocked = containerFit(box, [
        group(
          count: '1',
          length: '1.01',
          width: '1.01',
          height: '0.5',
          gross: '101',
          measure: MeasureUnit.metre,
        ),
      ]);
      expect(blocked.status, FitStatus.outsideLimits);
      expect(blocked.failingGroups, [1]);
      expect(blocked.payloadExceeded, isTrue);
      expect(blocked.volumeExceeded, isFalse);
    },
  );

  test(
    'IANA timezone comparison handles repeated and nonexistent wall times',
    () {
      expect(
        MeetingTime.resolve('2025-03-09 02:30', 'America/New_York'),
        isEmpty,
      );
      expect(MeetingTime.resolve('2025-11-02 01:30', 'America/New_York'), [
        DateTime.utc(2025, 11, 2, 5, 30),
        DateTime.utc(2025, 11, 2, 6, 30),
      ]);
      expect(
        MeetingTime.at(
          DateTime.utc(2025, 7, 1),
          'Europe/London',
        ).timeZoneOffset,
        const Duration(hours: 1),
      );
      expect(
        MeetingTime.at(
          DateTime.utc(2025, 1, 1),
          'Europe/London',
        ).timeZoneOffset,
        Duration.zero,
      );
    },
  );

  test(
    'emissions requires sourced factor and cold chain cannot complete an invalid range',
    () {
      expect(
        transportEmissions(
          tonnes: '2',
          kilometres: '10',
          factor: '',
          source: 'worksheet',
          effectiveDate: '2026-01-01',
        ),
        isNull,
      );
      expect(
        transportEmissions(
          tonnes: '2',
          kilometres: '10',
          factor: '0.5',
          source: 'worksheet',
          effectiveDate: '2026-02-30',
        ),
        isNull,
      );
      expect(
        transportEmissions(
          tonnes: '2',
          kilometres: '10',
          factor: '0.5',
          source: 'worksheet',
          effectiveDate: '2026-01-01',
        )!.format(),
        '10.00',
      );
      expect(
        coldReadiness(
          commodity: 'Training cargo',
          min: '5',
          max: '0',
          source: 'example',
          packaging: true,
          equipment: true,
          monitoring: true,
          documentation: true,
        ),
        ColdStatus.invalidRange,
      );
      expect(
        coldReadiness(
          commodity: 'Training cargo',
          min: '-20',
          max: '-10',
          source: 'example',
          packaging: true,
          equipment: true,
          monitoring: false,
          documentation: true,
        ),
        ColdStatus.needsPreparation,
      );
    },
  );

  testWidgets(
    'switching direction mid-RFQ retains cargo input and package groups',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 1100);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final workspace = LocalWorkspace();
      addTearDown(workspace.close);
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => AppCubit(),
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) => MaterialApp(
              builder: (context, child) => Directionality(
                textDirection: state.language == AppLanguage.arabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              ),
              home: QuoteWorkspace(
                copy: const AppCopy(AppLanguage.english),
                workspace: workspace,
              ),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('quote-origin')),
        'Cairo',
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('quote-destination')),
        'Amman',
      );
      await tester.pump();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sea'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quote-next')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('quote-cargo')),
        'Sample goods',
      );
      await tester.pump();
      await tester.tap(find.text('Add package group'));
      await tester.pumpAndSettle();
      final count = find.byKey(const ValueKey((0, PackageField.count)));
      await tester.enterText(count, '3');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('quote-language')));
      await tester.pumpAndSettle();
      expect(find.text('Sample goods'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('مجموعة الطرود 1'), findsOneWidget);
      expect(Directionality.of(tester.element(count)), TextDirection.rtl);
    },
  );

  testWidgets('comparison displays comparable examples with synthetic status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuoteComparison(copy: AppCopy(AppLanguage.english)),
      ),
    );
    expect(find.text('Synthetic offer A'), findsOneWidget);
    expect(find.text('Synthetic offer B'), findsOneWidget);
    expect(find.text('210 USD'), findsOneWidget);
    expect(find.text('215 USD'), findsOneWidget);
  });
}
