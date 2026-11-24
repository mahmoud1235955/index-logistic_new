import '../../trade/domain/decimal.dart';

enum PackageType { carton, pallet, crate, other }

enum MeasureUnit { centimetre, metre, inch }

enum MassUnit { kilogram, pound }

enum PackageField { count, length, width, height, gross }

class PackageInput {
  PackageInput({
    Object? identity,
    this.type = PackageType.carton,
    this.measure = MeasureUnit.centimetre,
    this.mass = MassUnit.kilogram,
    this.values = const {},
  }) : identity = identity ?? Object();
  final Object identity;

  final PackageType type;
  final MeasureUnit measure;
  final MassUnit mass;
  final Map<PackageField, String> values;

  PackageInput edit({
    PackageType? type,
    MeasureUnit? measure,
    MassUnit? mass,
    PackageField? field,
    String? value,
  }) => PackageInput(
    identity: identity,
    type: type ?? this.type,
    measure: measure ?? this.measure,
    mass: mass ?? this.mass,
    values: Map.unmodifiable({...values, ?field: value ?? ''}),
  );

  Decimal? value(PackageField field) {
    final number = Decimal.parse(values[field] ?? '');
    return number != null &&
            number.positive &&
            (field != PackageField.count || number.whole)
        ? number
        : null;
  }

  PackageGroup? get group {
    final count = value(PackageField.count);
    final length = value(PackageField.length);
    final width = value(PackageField.width);
    final height = value(PackageField.height);
    final gross = value(PackageField.gross);
    if (count == null ||
        length == null ||
        width == null ||
        height == null ||
        gross == null) {
      return null;
    }
    final toMetres = switch (measure) {
      MeasureUnit.metre => Decimal.one,
      MeasureUnit.centimetre => Decimal.one / Decimal.integer(100),
      MeasureUnit.inch => Decimal.integer(254) / Decimal.integer(10000),
    };
    final toKg = mass == MassUnit.kilogram
        ? Decimal.one
        : Decimal.integer(45359237) / Decimal.integer(100000000);
    return PackageGroup(
      type,
      count,
      length * toMetres,
      width * toMetres,
      height * toMetres,
      gross * toKg,
    );
  }
}

class PackageGroup {
  const PackageGroup(
    this.type,
    this.count,
    this.length,
    this.width,
    this.height,
    this.gross,
  );
  final PackageType type;
  final Decimal count, length, width, height, gross;
  Decimal get cbm => count * length * width * height;
  Decimal get kg => count * gross;
}

class CargoTotals {
  const CargoTotals(this.cbm, this.kg);
  final Decimal cbm, kg;

  static CargoTotals? fromInputs(List<PackageInput> inputs) {
    if (inputs.isEmpty) return null;
    var cbm = Decimal.zero;
    var kg = Decimal.zero;
    for (final input in inputs) {
      final group = input.group;
      if (group == null) return null;
      cbm += group.cbm;
      kg += group.kg;
    }
    return CargoTotals(cbm, kg);
  }
}
