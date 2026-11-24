import 'decimal.dart';
import 'shipment.dart';

enum FreightInput {
  rate,
  surcharge,
  containers,
  divisor,
  gross,
  volume,
  lclKg,
  increment,
  minimum,
}

class FreightEstimate {
  const FreightEstimate({
    required this.missing,
    this.units,
    this.volumetricKg,
    this.base,
    this.surcharges,
    this.total,
  });

  final List<FreightInput> missing;
  final Decimal? units;
  final Decimal? volumetricKg;
  final Decimal? base;
  final Decimal? surcharges;
  final Decimal? total;
}

/// Uses the selected carrier's entered assumptions for this shipment.
class FreightRules {
  const FreightRules();

  FreightEstimate calculate(Shipment shipment) {
    final missing = <FreightInput>[];
    Decimal? read(
      Field field,
      FreightInput input, {
      bool positive = false,
      bool whole = false,
    }) {
      final value = shipment.number(field);
      if (value == null ||
          (positive && !value.positive) ||
          (whole && !value.whole)) {
        missing.add(input);
        return null;
      }
      return value;
    }

    final rate = read(Field.rate, FreightInput.rate);
    final surcharge = read(Field.surcharge, FreightInput.surcharge)?.rounded();
    final useWeightVolume =
        shipment.transport == Transport.air ||
        (shipment.transport == Transport.sea &&
            shipment.seaLoad == SeaLoad.lcl);
    Decimal? units;
    Decimal? volumetricKg;
    Decimal? minimum;
    if (useWeightVolume) {
      final gross = read(Field.gross, FreightInput.gross, positive: true);
      final volume = shipment.volume;
      if (volume == null || !volume.positive) missing.add(FreightInput.volume);
      minimum = read(Field.minimum, FreightInput.minimum);
      final increment = shipment.text(Field.increment).isEmpty
          ? null
          : read(Field.increment, FreightInput.increment, positive: true);

      if (shipment.transport == Transport.air) {
        final divisor = read(
          Field.divisor,
          FreightInput.divisor,
          positive: true,
        );
        if (divisor != null && volume != null && volume.positive) {
          volumetricKg = volume * Decimal.integer(1000000) / divisor;
          if (gross != null) units = gross.atLeast(volumetricKg);
        }
      } else {
        final kgPerUnit = read(Field.lclKg, FreightInput.lclKg, positive: true);
        if (gross != null &&
            kgPerUnit != null &&
            volume != null &&
            volume.positive) {
          units = (gross / kgPerUnit).atLeast(volume);
        }
      }
      if (units != null && increment != null) {
        units = (units / increment).ceiling() * increment;
      }
    } else if (shipment.transport == Transport.sea) {
      units = read(
        Field.containers,
        FreightInput.containers,
        positive: true,
        whole: true,
      );
    } else {
      units = Decimal.one;
    }

    var base = rate != null && units != null ? (rate * units).rounded() : null;
    if (base != null && minimum != null) base = base.atLeast(minimum.rounded());
    return FreightEstimate(
      missing: List.unmodifiable(missing),
      units: units,
      volumetricKg: volumetricKg,
      base: base,
      surcharges: surcharge,
      total: missing.isEmpty && base != null && surcharge != null
          ? base + surcharge
          : null,
    );
  }
}
