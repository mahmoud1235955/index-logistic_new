import 'customs_calculation.dart';
import 'import_eligibility.dart';
import 'vehicle_profile.dart';

enum VehicleScenario {
  unverified,
  eligible,
  notEligible,
  conditional,
  missingRate,
}

class VehicleRuleQuery {
  const VehicleRuleQuery({
    required this.destination,
    required this.date,
    required this.profile,
    required this.scenario,
  });

  final String destination;
  final DateTime date;
  final VehicleProfile profile;
  final VehicleScenario scenario;
}

class VehicleRuleSet {
  const VehicleRuleSet({this.eligibility, this.customs});
  final EligibilityRule? eligibility;
  final CustomsRules? customs;
}

abstract interface class CountryRuleProvider {
  Future<VehicleRuleSet> lookup(VehicleRuleQuery query);
}
