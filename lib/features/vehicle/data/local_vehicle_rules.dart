import '../domain/country_rule_provider.dart';
import '../domain/customs_calculation.dart';
import '../domain/import_eligibility.dart';
import '../domain/legal_reference.dart';
import '../domain/vehicle_profile.dart';

class LocalVehicleRules implements CountryRuleProvider {
  const LocalVehicleRules();

  @override
  Future<VehicleRuleSet> lookup(VehicleRuleQuery query) async {
    final scenario = query.scenario;
    if (query.destination != 'EG' || scenario == VehicleScenario.unverified) {
      return const VehicleRuleSet();
    }
    final reference = LegalReference(
      verification: Verification.synthetic,
      effectiveFrom: DateTime(2020),
      effectiveUntil: DateTime(2099, 12, 31),
    );
    return VehicleRuleSet(
      eligibility: EligibilityRule(
        status: switch (scenario) {
          VehicleScenario.eligible => EligibilityStatus.eligible,
          VehicleScenario.notEligible => EligibilityStatus.notEligible,
          VehicleScenario.conditional => EligibilityStatus.conditional,
          _ => EligibilityStatus.undetermined,
        },
        reference: reference,
        reason: switch (scenario) {
          VehicleScenario.eligible => (
            english: 'The fictional conditions are satisfied.',
            arabic: 'شروط المثال الافتراضي مستوفاة.',
          ),
          VehicleScenario.notEligible => (
            english: 'The fictional scenario marks a condition as unmet.',
            arabic: 'يفترض المثال عدم استيفاء أحد الشروط.',
          ),
          VehicleScenario.conditional => (
            english:
                'The fictional exemption is conditional on supporting evidence.',
            arabic: 'يشترط الإعفاء الافتراضي تقديم أدلة داعمة.',
          ),
          _ => null,
        },
        documents: [
          SupportingDocument.purchaseEvidence,
          SupportingDocument.vehicleSpecification,
          if (query.profile.regime == ImportRegime.preferential)
            SupportingDocument.originEvidence,
          if (query.profile.regime == ImportRegime.temporary)
            SupportingDocument.regimeEvidence,
        ],
      ),
      customs: CustomsRules(
        reference: reference,
        charges: [
          if (scenario != VehicleScenario.missingRate)
            ChargeRule(
              charge: Charge.duty,
              status: scenario == VehicleScenario.conditional
                  ? ChargeStatus.exempt
                  : ChargeStatus.rated,
              exactRate: scenario == VehicleScenario.conditional
                  ? null
                  : '0.10',
              bases: const [CalculationBase.customsValue],
            ),
          const ChargeRule(
            charge: Charge.development,
            status: ChargeStatus.zeroRated,
          ),
          const ChargeRule(
            charge: Charge.schedule,
            status: ChargeStatus.notApplicable,
          ),
          const ChargeRule(
            charge: Charge.vat,
            status: ChargeStatus.rated,
            exactRate: '0.08',
            bases: [CalculationBase.customsValue],
            dependencies: [Charge.duty, Charge.development],
          ),
          const ChargeRule(
            charge: Charge.other,
            status: ChargeStatus.notApplicable,
          ),
        ],
      ),
    );
  }
}
