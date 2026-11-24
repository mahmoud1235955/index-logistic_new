import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/features/dangerous_goods/data/local_dg_repository.dart';
import 'package:index_logistic/features/dangerous_goods/domain/dg_assessment.dart';
import 'package:index_logistic/features/dangerous_goods/domain/dg_models.dart';
import 'package:index_logistic/features/dangerous_goods/domain/dg_providers.dart';
import 'package:index_logistic/features/dangerous_goods/presentation/dg_cubits.dart';

final _date = DateTime(2026, 11, 24);

ShipmentDraft draft([Map<DgField, String> values = const {}]) => ShipmentDraft({
  DgField.description: 'Test article',
  DgField.un: '9909',
  DgField.physical: PhysicalState.article.name,
  DgField.quantity: '٢٫٥',
  DgField.unit: 'kg',
  DgField.packages: '2',
  DgField.mode: DgMode.air.name,
  DgField.origin: 'Test origin',
  DgField.destination: 'Test destination',
  DgField.battery: BatteryFlag.no.name,
  DgField.sds: Readiness.available.name,
  DgField.classification: Readiness.available.name,
  DgField.packaging: Readiness.available.name,
  ...values,
});

void main() {
  test(
    'UN search normalizes identifiers and filters synthetic data only on opt-in',
    () async {
      final cubit = DgSearchCubit(const LocalDgRepository());
      addTearDown(cubit.close);
      await cubit.update(text: 'UN ٩٩٠٩');
      expect(cubit.state.status, SearchStatus.unavailable);
      await cubit.update(demo: true);
      expect(cubit.state.results.single.un, '9909');
      await cubit.update(text: 'Sample battery profile');
      expect(cubit.state.results.single.verification, DgVerification.synthetic);
      await cubit.update(hazard: HazardClass.corrosive);
      expect(cubit.state.status, SearchStatus.empty);
      await cubit.update(text: '', clearHazard: true, mode: DgMode.road);
      expect(cubit.state.results.length, 3);
      expect(
        cubit.state.results.every(
          (item) => item.demoModes.contains(DgMode.road),
        ),
        isTrue,
      );
      await cubit.update(text: 'UN 333');
      expect(cubit.state.status, SearchStatus.invalid);
      expect(unNumber('UN 0000'), isNull);
      expect(unNumber('un ٩٩٠٩'), '9909');
      expect(HazardClass.values, hasLength(9));
    },
  );

  test(
    'search ignores stale results and publishes repository errors',
    () async {
      final first = Completer<List<Classification>>();
      final repo = _Repository((query) {
        if (query.text == 'first') return first.future;
        throw StateError('unavailable');
      });
      final cubit = DgSearchCubit(repo);
      addTearDown(cubit.close);
      final pending = cubit.update(text: 'first', demo: true);
      await cubit.update(text: 'second');
      expect(cubit.state.status, SearchStatus.error);
      first.complete(samples);
      await pending;
      expect(cubit.state.status, SearchStatus.error);
      expect(cubit.state.query.text, 'second');
    },
  );

  test(
    'checklist outcomes distinguish missing, unresolved and specialist review',
    () async {
      const service = DgAssessmentService(LocalDgRepository(), RuleProviders());
      final complete = await service.evaluate(draft(), _date);
      expect(complete.status, DgStatus.informationComplete);
      expect(complete.restriction, isNull);
      final missing = await service.evaluate(
        draft({DgField.sds: 'missing', DgField.packages: '-1'}),
        _date,
      );
      expect(missing.status, DgStatus.additionalInformation);
      expect(missing.missing, {DgField.sds, DgField.packages});
      final unresolved = await service.evaluate(draft({DgField.un: ''}), _date);
      expect(unresolved.status, DgStatus.undetermined);
      final specialist = await service.evaluate(
        draft({
          DgField.battery: BatteryFlag.yes.name,
          DgField.chemistry: Chemistry.lithiumIon.name,
          DgField.configuration: Configuration.inEquipment.name,
          DgField.capacity: 'Example value',
          DgField.condition: BatteryCondition.damagedOrRecalled.name,
          DgField.batteryTests: Readiness.available.name,
        }),
        _date,
      );
      expect(specialist.status, DgStatus.specialistReview);
      expect(specialist.restriction, isNull);
    },
  );

  test(
    'only verified, dated, mode-specific and query-bound evidence can flag a restriction',
    () async {
      final good = _source();
      var record = _entry(DgVerification.verified, good);
      var source = good;
      var exact = true;
      var calls = 0;
      final service = DgAssessmentService(
        _Repository((_) async => [record]),
        RuleProviders(
          icao: _Icao((query) async {
            calls++;
            return [
              VerifiedRestriction(
                query: exact
                    ? query
                    : RuleQuery(
                        query.shipment,
                        query.classification,
                        query.date,
                      ),
                source: source,
                english: 'Test-only marker',
                arabic: 'علامة اختبار',
              ),
            ];
          }),
        ),
      );
      final matched = await service.evaluate(draft(), _date);
      expect(matched.status, DgStatus.verifiedRestriction);
      expect(matched.restriction!.source, good);
      final demo = await service.evaluate(draft(), _date, demonstration: true);
      expect(demo.restriction, isNull);
      expect(calls, 1);
      exact = false;
      expect((await service.evaluate(draft(), _date)).restriction, isNull);
      exact = true;
      source = _source(until: DateTime(2025));
      expect((await service.evaluate(draft(), _date)).restriction, isNull);
      source = _source(framework: Framework.iata);
      expect((await service.evaluate(draft(), _date)).restriction, isNull);
      record = _entry(DgVerification.unverified, good);
      final previousCalls = calls;
      expect((await service.evaluate(draft(), _date)).restriction, isNull);
      expect(calls, previousCalls);
    },
  );

  test(
    'failed source lookup is undetermined and never authorizes shipment',
    () async {
      final service = DgAssessmentService(
        _Repository((_) async => throw StateError('failed')),
        const RuleProviders(),
      );
      final result = await service.evaluate(draft(), _date);
      expect(result.status, DgStatus.undetermined);
      expect(result.lookupFailed, isTrue);
      expect(result.restriction, isNull);
      expect(
        DgStatus.values.any(
          (item) => item.name.toLowerCase().contains('approv'),
        ),
        isFalse,
      );
    },
  );
}

Classification _entry(DgVerification status, RegulatorySource source) =>
    Classification(
      un: '9909',
      name: 'Test fixture',
      arabicName: 'اختبار',
      hazard: HazardClass.miscellaneous,
      verification: status,
      sources: [source],
    );

RegulatorySource _source({
  Framework framework = Framework.icao,
  DateTime? until,
}) => RegulatorySource(
  framework: framework,
  edition: 'Test edition',
  jurisdiction: 'Test jurisdiction',
  citation: 'https://example.invalid/test-record',
  effectiveFrom: DateTime(2024),
  effectiveThrough: until,
  verification: DgVerification.verified,
);

class _Repository implements ClassificationRepository {
  _Repository(this.call);
  final Future<List<Classification>> Function(ClassificationQuery) call;
  @override
  Future<List<Classification>> search(ClassificationQuery query) => call(query);
}

class _Icao implements IcaoRuleProvider {
  _Icao(this.call);
  final Future<List<VerifiedRestriction>> Function(RuleQuery) call;
  @override
  Future<List<VerifiedRestriction>> restrictions(RuleQuery query) =>
      call(query);
}
