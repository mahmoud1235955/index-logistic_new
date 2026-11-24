import 'dg_models.dart';

class ClassificationQuery {
  const ClassificationQuery({
    this.text = '',
    this.hazard,
    this.mode,
    this.demo = false,
  });
  final String text;
  final HazardClass? hazard;
  final DgMode? mode;
  final bool demo;
}

abstract interface class ClassificationRepository {
  Future<List<Classification>> search(ClassificationQuery query);
}

class RuleQuery {
  const RuleQuery(this.shipment, this.classification, this.date);
  final ShipmentDraft shipment;
  final Classification classification;
  final DateTime date;
}

class VerifiedRestriction {
  const VerifiedRestriction({
    required this.query,
    required this.source,
    required this.english,
    required this.arabic,
  });

  /// The adapter binds a precisely matched record to this exact request.
  /// A generic UN or transport-mode match alone does not establish applicability.
  final RuleQuery query;
  final RegulatorySource source;
  final String english, arabic;
}

abstract interface class ModeRuleProvider {
  Future<List<VerifiedRestriction>> restrictions(RuleQuery query);
}

abstract interface class IcaoRuleProvider implements ModeRuleProvider {}

abstract interface class IataRuleProvider implements ModeRuleProvider {}

abstract interface class ImdgRuleProvider implements ModeRuleProvider {}

abstract interface class AdrRuleProvider implements ModeRuleProvider {}

abstract interface class NationalRoadRuleProvider implements ModeRuleProvider {}

class RuleProviders {
  const RuleProviders({
    this.icao,
    this.iata,
    this.imdg,
    this.adr,
    this.nationalRoad,
  });
  final IcaoRuleProvider? icao;
  final IataRuleProvider? iata;
  final ImdgRuleProvider? imdg;
  final AdrRuleProvider? adr;
  final NationalRoadRuleProvider? nationalRoad;

  Map<Framework, ModeRuleProvider?> forMode(DgMode mode) => switch (mode) {
    DgMode.air => {Framework.icao: icao, Framework.iata: iata},
    DgMode.sea => {Framework.imdg: imdg},
    DgMode.road => {Framework.adr: adr, Framework.nationalRoad: nationalRoad},
  };
}
