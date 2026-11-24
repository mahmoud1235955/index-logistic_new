import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/features/vehicle/data/local_vehicle_rules.dart';
import 'package:index_logistic/features/vehicle/domain/country_rule_provider.dart';
import 'package:index_logistic/features/vehicle/domain/customs_calculation.dart';
import 'package:index_logistic/features/vehicle/domain/import_eligibility.dart';
import 'package:index_logistic/features/vehicle/domain/legal_reference.dart';
import 'package:index_logistic/features/vehicle/domain/vehicle_profile.dart';

final _date = DateTime(2026, 11, 24);
final _profile = VehicleProfile({
  VehicleField.currency: Currency.egp.name,
  VehicleField.purchase: '10000',
  VehicleField.freight: '1000',
  VehicleField.insurance: '100',
  VehicleField.otherCosts: '50',
  VehicleField.handling: '200',
});

Future<VehicleRuleSet> _lookup(VehicleScenario scenario) =>
    const LocalVehicleRules().lookup(
      VehicleRuleQuery(
        destination: 'EG',
        date: _date,
        profile: _profile,
        scenario: scenario,
      ),
    );

void main() {
  test(
    'synthetic fixtures exercise all four outcomes and require opt-in',
    () async {
      const expected = {
        VehicleScenario.eligible: EligibilityStatus.eligible,
        VehicleScenario.notEligible: EligibilityStatus.notEligible,
        VehicleScenario.conditional: EligibilityStatus.conditional,
        VehicleScenario.missingRate: EligibilityStatus.undetermined,
        VehicleScenario.unverified: EligibilityStatus.undetermined,
      };
      for (final entry in expected.entries) {
        final set = await _lookup(entry.key);
        expect(
          EligibilityAssessment.evaluate(
            set.eligibility,
            _date,
            demonstration: entry.key != VehicleScenario.unverified,
          ).status,
          entry.value,
        );
        expect(
          EligibilityAssessment.evaluate(
            set.eligibility,
            _date,
            demonstration: false,
          ).status,
          EligibilityStatus.undetermined,
        );
      }
    },
  );

  test(
    'synthetic duty and VAT use different bases and total does not double-count valuation',
    () async {
      final set = await _lookup(VehicleScenario.eligible);
      final result = const CustomsCalculator().calculate(
        _profile,
        set.customs,
        _date,
        demonstration: true,
      );
      expect(result.customsValue, 11100);
      expect(result.charges[Charge.duty]!.amount, 1110);
      expect(result.charges[Charge.vat]!.base, 12210);
      expect(result.charges[Charge.vat]!.amount, 976.8);
      expect(result.total, 13436.8);
      expect(
        result.charges[Charge.development]!.status,
        ChargeStatus.zeroRated,
      );
      expect(
        result.charges[Charge.schedule]!.status,
        ChargeStatus.notApplicable,
      );
    },
  );

  test(
    'explicit exemption contributes zero to dependent charge calculation',
    () async {
      final set = await _lookup(VehicleScenario.conditional);
      final result = const CustomsCalculator().calculate(
        _profile,
        set.customs,
        _date,
        demonstration: true,
      );
      expect(result.charges[Charge.duty]!.status, ChargeStatus.exempt);
      expect(result.charges[Charge.vat]!.base, 11100);
      expect(result.total, 12238);
    },
  );

  test(
    'missing, unverified, expired and cyclic rules suppress the total',
    () async {
      final calc = const CustomsCalculator();
      final missing = await _lookup(VehicleScenario.missingRate);
      final partial = calc.calculate(
        _profile,
        missing.customs,
        _date,
        demonstration: true,
      );
      expect(partial.customsValue, 11100);
      expect(partial.charges[Charge.duty]!.status, ChargeStatus.unknown);
      expect(partial.charges[Charge.vat]!.status, ChargeStatus.unknown);
      expect(partial.total, isNull);

      final eligible = await _lookup(VehicleScenario.eligible);
      expect(
        calc
            .calculate(_profile, eligible.customs, _date, demonstration: false)
            .total,
        isNull,
      );
      expect(
        calc
            .calculate(
              _profile,
              eligible.customs,
              DateTime(2100),
              demonstration: true,
            )
            .total,
        isNull,
      );

      final cyclic = CustomsRules(
        reference: eligible.customs!.reference,
        charges: [
          for (final rule in eligible.customs!.charges)
            if (rule.charge != Charge.duty) rule,
          const ChargeRule(
            charge: Charge.duty,
            status: ChargeStatus.rated,
            rate: .1,
            dependencies: [Charge.vat],
          ),
        ],
      );
      final cycleResult = calc.calculate(
        _profile,
        cyclic,
        _date,
        demonstration: true,
      );
      expect(cycleResult.charges[Charge.duty]!.status, ChargeStatus.unknown);
      expect(cycleResult.total, isNull);
      final unverified = LegalReference(
        verification: Verification.unverified,
        effectiveFrom: _date,
      );
      final markedUnverified = CustomsRules(
        reference: unverified,
        charges: eligible.customs!.charges,
      );
      expect(
        calc
            .calculate(_profile, markedUnverified, _date, demonstration: false)
            .total,
        isNull,
      );
      final unverifiedCharge = CustomsRules(
        reference: eligible.customs!.reference,
        charges: [
          for (final rule in eligible.customs!.charges)
            if (rule.charge != Charge.duty) rule,
          ChargeRule(
            charge: Charge.duty,
            reference: unverified,
            status: ChargeStatus.exempt,
          ),
        ],
      );
      expect(
        calc
            .calculate(_profile, unverifiedCharge, _date, demonstration: true)
            .total,
        isNull,
      );
    },
  );

  test(
    'FX conversion accepts Arabic decimal input and missing FX remains unknown',
    () async {
      final set = await _lookup(VehicleScenario.eligible);
      final usd = {
        ..._profile.values,
        VehicleField.currency: Currency.usd.name,
      };
      final calc = const CustomsCalculator();
      final partial = calc.calculate(
        VehicleProfile(usd),
        set.customs,
        _date,
        demonstration: true,
      );
      expect(partial.costs[CostItem.purchase], isNull);
      expect(partial.total, isNull);
      final result = calc.calculate(
        VehicleProfile({...usd, VehicleField.exchangeRate: '٢٫٥'}),
        set.customs,
        _date,
        demonstration: true,
      );
      expect(result.customsValue, 27750);
      expect(result.total, 33592);
    },
  );

  test('dates and numeric separators are validated strictly', () {
    final profile = VehicleProfile({
      VehicleField.assessmentDate: '٢٠٢٦-٠٢-٣٠',
      VehicleField.exchangeDate: '2026-11-24',
      VehicleField.purchase: '1,234',
      VehicleField.freight: '-20',
    });
    expect(profile.date(VehicleField.assessmentDate), isNull);
    expect(profile.date(VehicleField.exchangeDate), _date);
    expect(profile.number(VehicleField.purchase), isNull);
    expect(profile.number(VehicleField.freight), isNull);
  });
}
