import '../../trade/domain/decimal.dart';
import 'package_group.dart';

typedef ContainerSpec = ({
  Decimal length,
  Decimal width,
  Decimal height,
  Decimal doorWidth,
  Decimal doorHeight,
  Decimal payloadKg,
});

enum FitStatus { incomplete, outsideLimits, individualFitOnly }

class FitEstimate {
  const FitEstimate(
    this.status, {
    this.totals,
    this.utilization,
    this.failingGroups = const [],
    this.payloadExceeded = false,
    this.volumeExceeded = false,
  });
  final FitStatus status;
  final CargoTotals? totals;
  final Decimal? utilization;
  final List<int> failingGroups;
  final bool payloadExceeded, volumeExceeded;
}

FitEstimate containerFit(ContainerSpec? box, List<PackageInput> inputs) {
  final totals = CargoTotals.fromInputs(inputs);
  if (box == null ||
      totals == null ||
      ![
        box.length,
        box.width,
        box.height,
        box.doorWidth,
        box.doorHeight,
        box.payloadKg,
      ].every((value) => value.positive) ||
      box.doorWidth.compareTo(box.width) > 0 ||
      box.doorHeight.compareTo(box.height) > 0) {
    return FitEstimate(FitStatus.incomplete, totals: totals);
  }
  final capacity = box.length * box.width * box.height;
  final overweight = totals.kg.compareTo(box.payloadKg) > 0;
  final overVolume = totals.cbm.compareTo(capacity) > 0;
  final failing = <int>[];
  for (final (index, input) in inputs.indexed) {
    final group = input.group!;
    final edges = [group.length, group.width, group.height];
    final orientations = [
      (0, 1, 2),
      (0, 2, 1),
      (1, 0, 2),
      (1, 2, 0),
      (2, 0, 1),
      (2, 1, 0),
    ];
    final fits = orientations.any((orientation) {
      final (l, w, h) = orientation;
      return edges[l].compareTo(box.length) <= 0 &&
          edges[w].compareTo(box.doorWidth) <= 0 &&
          edges[h].compareTo(box.doorHeight) <= 0;
    });
    if (!fits) failing.add(index + 1);
  }
  return FitEstimate(
    overweight || overVolume || failing.isNotEmpty
        ? FitStatus.outsideLimits
        : FitStatus.individualFitOnly,
    totals: totals,
    utilization: totals.cbm / capacity * Decimal.integer(100),
    failingGroups: List.unmodifiable(failing),
    payloadExceeded: overweight,
    volumeExceeded: overVolume,
  );
}

DateTime? exactDate(String text) {
  final value = text.trim();
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
  final date = DateTime.tryParse('${value}T00:00:00Z');
  return date?.toIso8601String().substring(0, 10) == value ? date : null;
}

Decimal? signedDecimal(String text) {
  final value = text.trim();
  if (value.startsWith('-')) {
    final number = Decimal.parse(value.substring(1));
    return number == null ? null : Decimal.zero - number;
  }
  return Decimal.parse(value);
}

Decimal? transportEmissions({
  required String tonnes,
  required String kilometres,
  required String factor,
  required String source,
  required String effectiveDate,
}) {
  final mass = Decimal.parse(tonnes);
  final distance = Decimal.parse(kilometres);
  final supplied = Decimal.parse(factor);
  if (mass == null ||
      !mass.positive ||
      distance == null ||
      !distance.positive ||
      supplied == null ||
      source.trim().isEmpty ||
      exactDate(effectiveDate) == null) {
    return null;
  }
  return mass * distance * supplied;
}

enum ColdStatus {
  incomplete,
  invalidRange,
  needsPreparation,
  preparedForReview,
}

ColdStatus coldReadiness({
  required String commodity,
  required String min,
  required String max,
  required String source,
  required bool packaging,
  required bool equipment,
  required bool monitoring,
  required bool documentation,
}) {
  final low = signedDecimal(min);
  final high = signedDecimal(max);
  if (commodity.trim().isEmpty ||
      source.trim().isEmpty ||
      low == null ||
      high == null) {
    return ColdStatus.incomplete;
  }
  if (low.compareTo(high) > 0 ||
      low.compareTo(
            Decimal.zero - Decimal.integer(273) - Decimal.parse('0.15')!,
          ) <
          0) {
    return ColdStatus.invalidRange;
  }
  return packaging && equipment && monitoring && documentation
      ? ColdStatus.preparedForReview
      : ColdStatus.needsPreparation;
}
