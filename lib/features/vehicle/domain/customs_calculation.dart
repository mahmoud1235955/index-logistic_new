import '../../trade/domain/decimal.dart';

import 'legal_reference.dart';
import 'vehicle_profile.dart';

enum Charge { duty, development, schedule, vat, other }

enum ChargeStatus { rated, zeroRated, exempt, unknown, notApplicable }

enum CalculationBase {
  purchase,
  freight,
  insurance,
  otherCosts,
  handling,
  customsValue,
}

class ChargeRule {
  const ChargeRule({
    required this.charge,
    required this.status,
    this.rate,
    this.exactRate,
    this.bases = const [],
    this.dependencies = const [],
    this.reference,
  });

  final Charge charge;
  final ChargeStatus status;

  /// Fraction of the resulting base, e.g. 0.10 in a synthetic fixture.
  final double? rate;
  final String? exactRate;
  final List<CalculationBase> bases;
  final List<Charge> dependencies;
  final LegalReference? reference;
}

class CustomsRules {
  const CustomsRules({
    required this.reference,
    required this.charges,
    this.valuation = const [
      CalculationBase.purchase,
      CalculationBase.freight,
      CalculationBase.insurance,
    ],
  });

  final LegalReference reference;
  final List<CalculationBase> valuation;
  final List<ChargeRule> charges;
}

class ChargeLine {
  const ChargeLine(
    this.status, {
    this.amountExact,
    this.baseExact,
    this.rateExact,
  });

  final ChargeStatus status;
  final Decimal? amountExact, baseExact, rateExact;
  double? get amount => _legacy(amountExact);
  double? get base => _legacy(baseExact);
  double? get rate => _legacy(rateExact);
}

enum CostItem { purchase, freight, insurance, otherCosts, handling }

class CustomsEstimate {
  const CustomsEstimate({
    required this.costsExact,
    required this.charges,
    this.customsValueExact,
    this.totalExact,
    this.reference,
  });

  final Map<CostItem, Decimal?> costsExact;
  Map<CostItem, double?> get costs => Map.unmodifiable(
    costsExact.map((key, value) => MapEntry(key, _legacy(value))),
  );
  final Map<Charge, ChargeLine> charges;
  final Decimal? customsValueExact, totalExact;
  double? get customsValue => _legacy(customsValueExact);
  double? get total => _legacy(totalExact);
  final LegalReference? reference;
}

class CustomsCalculator {
  const CustomsCalculator();

  CustomsEstimate calculate(
    VehicleProfile profile,
    CustomsRules? rules,
    DateTime date, {
    required bool demonstration,
  }) {
    bool trusted(LegalReference reference) =>
        reference.covers(date) &&
        (demonstration
            ? reference.verification == Verification.synthetic
            : reference.hasOfficialCitation);
    final applied = rules != null && trusted(rules.reference) ? rules : null;
    final fx = profile.currency == Currency.egp
        ? Decimal.one
        : profile.currency != null
        ? _input(profile, VehicleField.exchangeRate)
        : null;
    Decimal? converted(VehicleField field) {
      final amount = _input(profile, field);
      if (fx == null || !fx.positive || amount == null) return null;
      return (amount * fx).rounded();
    }

    final costs = {
      CostItem.purchase: converted(VehicleField.purchase),
      CostItem.freight: converted(VehicleField.freight),
      CostItem.insurance: converted(VehicleField.insurance),
      CostItem.otherCosts: converted(VehicleField.otherCosts),
      CostItem.handling: converted(VehicleField.handling),
    };
    final bases = {
      CalculationBase.purchase: costs[CostItem.purchase],
      CalculationBase.freight: costs[CostItem.freight],
      CalculationBase.insurance: costs[CostItem.insurance],
      CalculationBase.otherCosts: costs[CostItem.otherCosts],
      CalculationBase.handling: costs[CostItem.handling],
    };
    final valuation = applied?.valuation;
    final customsValue =
        valuation == null ||
            valuation.isEmpty ||
            valuation.toSet().length != valuation.length
        ? null
        : _sum(valuation.map((base) => bases[base]));
    bases[CalculationBase.customsValue] = customsValue;

    final resolved = <Charge, ChargeLine>{};
    final visiting = <Charge>{};
    const unknown = ChargeLine(ChargeStatus.unknown);
    ChargeLine resolve(Charge charge) {
      if (resolved[charge] case final line?) return line;
      if (!visiting.add(charge)) return unknown;
      final candidates = applied?.charges.where(
        (item) => item.charge == charge,
      );
      final rule = candidates?.length == 1 ? candidates!.single : null;
      var line = unknown;
      if (rule != null &&
          (rule.reference == null || trusted(rule.reference!))) {
        line = switch (rule.status) {
          ChargeStatus.rated => _rated(rule, bases, resolve),
          ChargeStatus.unknown => unknown,
          _ => ChargeLine(rule.status, amountExact: Decimal.zero),
        };
      }
      visiting.remove(charge);
      return resolved[charge] = line;
    }

    final charges = {
      for (final charge in Charge.values) charge: resolve(charge),
    };
    final total = customsValue == null
        ? null
        : _sum([
            ...costs.values,
            ...charges.values.map((line) => line.amountExact),
          ]);
    return CustomsEstimate(
      costsExact: Map.unmodifiable(costs),
      charges: Map.unmodifiable(charges),
      customsValueExact: customsValue,
      totalExact: total,
      reference: rules?.reference,
    );
  }

  ChargeLine _rated(
    ChargeRule rule,
    Map<CalculationBase, Decimal?> bases,
    ChargeLine Function(Charge) resolve,
  ) {
    final rate = Decimal.parse(rule.exactRate ?? rule.rate?.toString() ?? '');
    if (rate == null ||
        !rate.positive ||
        (rule.bases.isEmpty && rule.dependencies.isEmpty) ||
        rule.bases.toSet().length != rule.bases.length ||
        rule.dependencies.toSet().length != rule.dependencies.length) {
      return const ChargeLine(ChargeStatus.unknown);
    }
    final base = _sum([
      ...rule.bases.map((key) => bases[key]),
      ...rule.dependencies.map((charge) => resolve(charge).amountExact),
    ]);
    final amount = base == null ? null : (base * rate).rounded();
    if (amount == null) {
      return const ChargeLine(ChargeStatus.unknown);
    }
    return ChargeLine(
      ChargeStatus.rated,
      amountExact: amount,
      baseExact: base,
      rateExact: rate,
    );
  }

  static Decimal? _input(VehicleProfile profile, VehicleField field) {
    final amount = Decimal.parse(profile.text(field));
    return amount != null && amount.compareTo(Decimal.integer(1000000000)) <= 0
        ? amount
        : null;
  }

  static Decimal? _sum(Iterable<Decimal?> amounts) {
    var total = Decimal.zero;
    for (final amount in amounts) {
      if (amount == null) return null;
      total += amount;
    }
    return total.rounded();
  }
}

// Read-only compatibility for existing callers. Calculation and display use exact values.
double? _legacy(Decimal? value) => value == null
    ? null
    : value.numerator.toDouble() / value.denominator.toDouble();
