enum VehicleCategory { passenger, commercial, truck, bus, motorcycle, other }

enum VehicleCondition { newVehicle, used }

enum Fuel { petrol, diesel, electric, hybrid }

enum ImporterKind { individual, company }

enum ImportUse { personal, commercial }

enum ImportRegime { standard, temporary, preferential, other }

enum Residency { resident, nonResident, unspecified }

enum Currency { egp, usd, eur, gbp, sar, aed, other }

enum DocumentReadiness { ready, partial, unavailable }

enum PreferenceClaim { none, potentialExemption, potentialPreference, unsure }

enum VehicleField {
  category,
  manufacturer,
  model,
  manufacturingYear,
  modelYear,
  condition,
  engineCc,
  powerKw,
  fuel,
  payloadKg,
  seatCount,
  specification,
  origin,
  exportCountry,
  tariffCode,
  importer,
  use,
  residency,
  regime,
  temporaryDays,
  preferenceProgram,
  preference,
  documents,
  assessmentDate,
  purchase,
  currency,
  currencyCode,
  freight,
  insurance,
  otherCosts,
  handling,
  exchangeRate,
  exchangeSource,
  exchangeDate,
}

class VehicleProfile {
  VehicleProfile(Map<VehicleField, String> values)
    : values = Map.unmodifiable(values);

  final Map<VehicleField, String> values;
  String text(VehicleField field) => values[field]?.trim() ?? '';
  T? option<T extends Enum>(VehicleField field, List<T> options) =>
      options.where((option) => option.name == text(field)).firstOrNull;

  Fuel? get fuel => option(VehicleField.fuel, Fuel.values);
  VehicleCategory? get category =>
      option(VehicleField.category, VehicleCategory.values);
  ImporterKind? get importer =>
      option(VehicleField.importer, ImporterKind.values);
  ImportRegime? get regime => option(VehicleField.regime, ImportRegime.values);
  Currency? get currency => option(VehicleField.currency, Currency.values);
  bool get foreignCurrency => currency != null && currency != Currency.egp;

  double? number(VehicleField field) {
    final value = _normalize(text(field)).replaceAll('٫', '.');
    if (!RegExp(r'^\d+(?:\.\d{1,6})?$').hasMatch(value)) return null;
    final parsed = double.tryParse(value);
    return parsed != null && parsed.isFinite && parsed <= 1000000000
        ? parsed
        : null;
  }

  DateTime? date(VehicleField field) {
    final value = _normalize(text(field));
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    final parsed = DateTime.tryParse(value);
    return parsed != null && parsed.toIso8601String().startsWith(value)
        ? parsed
        : null;
  }

  static String _normalize(String text) =>
      text.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
        final digit = match[0]!.codeUnitAt(0);
        return (digit >= 0x06f0 ? digit - 0x06f0 : digit - 0x0660).toString();
      });
}
