enum DgMode { air, sea, road }

enum HazardClass {
  explosives('1', ['1.1', '1.2', '1.3', '1.4', '1.5', '1.6']),
  gases('2', ['2.1', '2.2', '2.3']),
  flammableLiquids('3', []),
  flammableSolids('4', ['4.1', '4.2', '4.3']),
  oxidizers('5', ['5.1', '5.2']),
  toxicInfectious('6', ['6.1', '6.2']),
  radioactive('7', []),
  corrosive('8', []),
  miscellaneous('9', []);

  const HazardClass(this.code, this.divisions);
  final String code;
  final List<String> divisions;
}

enum DgVerification { synthetic, unverified, verified }

enum Framework {
  icao(
    DgMode.air,
    'ICAO Technical Instructions (Doc 9284)',
    'https://www.icao.int/Dangerous-Goods/Technical-Instructions',
  ),
  iata(
    DgMode.air,
    'IATA Dangerous Goods Regulations',
    'https://www.iata.org/en/publications/dgr',
  ),
  imdg(
    DgMode.sea,
    'IMO IMDG Code',
    'https://www.imo.org/en/publications/pages/imdg%20code.aspx',
  ),
  adr(DgMode.road, 'UNECE ADR', 'https://unece.org/transport/dangerous-goods'),
  nationalRoad(DgMode.road, 'National road transport rules', '');

  const Framework(this.mode, this.title, this.url);
  final DgMode mode;
  final String title, url;
}

class RegulatorySource {
  const RegulatorySource({
    required this.framework,
    required this.edition,
    required this.jurisdiction,
    required this.effectiveFrom,
    required this.verification,
    required this.citation,
    this.effectiveThrough,
    this.amendment,
  });
  final Framework framework;
  final String edition, jurisdiction, citation;
  final DateTime effectiveFrom;
  final DateTime? effectiveThrough;
  final String? amendment;
  final DgVerification verification;

  bool isApplicable(DgMode mode, DateTime date) =>
      verification == DgVerification.verified &&
      framework.mode == mode &&
      edition.trim().isNotEmpty &&
      jurisdiction.trim().isNotEmpty &&
      Uri.tryParse(citation)?.scheme == 'https' &&
      (Uri.tryParse(citation)?.hasAuthority ?? false) &&
      !date.isBefore(effectiveFrom) &&
      (effectiveThrough == null || !date.isAfter(effectiveThrough!));
}

class Classification {
  const Classification({
    required this.un,
    required this.name,
    required this.arabicName,
    required this.hazard,
    required this.verification,
    this.division,
    this.alternatives = const [],
    this.subsidiary = const [],
    this.packingGroup,
    this.sources = const [],
    this.demoModes = const [],
  });
  final String un, name, arabicName;
  final HazardClass hazard;
  final String? division, packingGroup;
  final List<String> alternatives, subsidiary;
  final List<RegulatorySource> sources;
  final List<DgMode> demoModes;
  final DgVerification verification;

  bool supports(DgMode mode, DateTime date) =>
      verification == DgVerification.verified &&
      sources.any((source) => source.isApplicable(mode, date));
}

String digits(String text) =>
    text.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
      final digit = match[0]!.codeUnitAt(0);
      return (digit - (digit >= 0x06f0 ? 0x06f0 : 0x0660)).toString();
    });

String? unNumber(String text) {
  final match = RegExp(
    r'^(?:UN\s*)?(\d{4})$',
    caseSensitive: false,
  ).firstMatch(digits(text.trim()));
  final value = match?.group(1);
  return value == '0000' ? null : value;
}

bool unLike(String input) => RegExp(
  r'^(?:UN(?:\s|\d|$)|\d+$)',
  caseSensitive: false,
).hasMatch(digits(input.trim()));

enum PhysicalState { solid, liquid, gas, article, unsure }

enum BatteryFlag { no, yes, unsure }

enum Chemistry { lithiumIon, lithiumMetal, sodiumIon, other, unsure }

enum Configuration { standalone, packedWithEquipment, inEquipment, unsure }

enum BatteryCondition { intact, damagedOrRecalled, unsure }

enum Readiness { available, missing, unsure }

enum DgDocument {
  sds,
  classification,
  packaging,
  declaration,
  certification,
  batteryTests,
  modeDocuments,
}

enum DgField {
  description,
  un,
  physical,
  quantity,
  unit,
  packages,
  mode,
  origin,
  destination,
  carrier,
  battery,
  chemistry,
  configuration,
  capacity,
  condition,
  sds,
  classification,
  packaging,
  batteryTests,
}

class ShipmentDraft {
  ShipmentDraft([Map<DgField, String> values = const {}])
    : values = Map.unmodifiable(values);
  final Map<DgField, String> values;
  String text(DgField field) => values[field]?.trim() ?? '';
  T? option<T extends Enum>(DgField field, List<T> options) =>
      options.where((option) => option.name == text(field)).firstOrNull;
  DgMode? get mode => option(DgField.mode, DgMode.values);
  BatteryFlag? get battery => option(DgField.battery, BatteryFlag.values);
  String? get un => unNumber(text(DgField.un));

  List<DgField> get shipmentFields => [
    DgField.description,
    DgField.un,
    DgField.physical,
    DgField.quantity,
    DgField.unit,
    DgField.packages,
    DgField.mode,
    DgField.origin,
    DgField.destination,
    DgField.carrier,
    DgField.battery,
    if (battery == BatteryFlag.yes) ...[
      DgField.chemistry,
      DgField.configuration,
      DgField.capacity,
      DgField.condition,
    ],
  ];
  List<DgField> get readinessFields => [
    DgField.sds,
    DgField.classification,
    DgField.packaging,
    if (battery == BatteryFlag.yes) DgField.batteryTests,
  ];

  Set<DgField> get missing => {
    for (final field in [...shipmentFields, ...readinessFields])
      if (field != DgField.un &&
          field != DgField.carrier &&
          text(field).isEmpty)
        field,
    for (final field in readinessFields)
      if (text(field) == Readiness.missing.name) field,
  };

  bool invalid(DgField field) {
    final value = text(field);
    if (value.isEmpty) return false;
    if (field == DgField.un) return un == null;
    if (field == DgField.packages) {
      return !RegExp(r'^\d{1,9}$').hasMatch(digits(value)) ||
          int.parse(digits(value)) <= 0;
    }
    if (field == DgField.quantity) {
      final normalized = digits(value).replaceAll('٫', '.');
      return !RegExp(r'^\d{1,12}(?:\.\d{1,6})?$').hasMatch(normalized) ||
          double.parse(normalized) <= 0;
    }
    return false;
  }
}
