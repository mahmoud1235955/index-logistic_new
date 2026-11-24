import 'currency_conversion.dart';
import 'decimal.dart';
import 'freight_rules.dart';
import 'shipment.dart';
import 'tariff_provider.dart';

class CostLine {
  const CostLine(this.cost, this.amount, this.provenance, this.treatment);
  final Cost cost;
  final Decimal? amount;
  final Provenance provenance;
  final Treatment? treatment;
}

class TradeResult {
  const TradeResult({
    required this.shipment,
    required this.freight,
    required this.lines,
    required this.calculatedOn,
    this.cargoValue,
    this.valuation,
    this.total,
    this.unitCost,
    this.perKg,
    this.price,
    this.pricePerUnit,
    this.profit,
    this.margin,
    this.conversion,
    this.convertedTotal,
    this.tariff,
  });

  final Shipment shipment;
  final DateTime calculatedOn;
  final FreightEstimate freight;
  final List<CostLine> lines;
  final Decimal? cargoValue, valuation, total, unitCost, perKg;
  final Decimal? price, pricePerUnit, profit, margin, convertedTotal;
  final CurrencyConversion? conversion;
  final TariffAmounts? tariff;
}

class TradeEngine {
  const TradeEngine();

  TradeResult calculate(
    Shipment shipment, {
    TariffAmounts? tariff,
    required DateTime date,
  }) {
    final mode = shipment.mode;
    final freight = const FreightRules().calculate(shipment);
    final accepted = tariff?.appliesTo(shipment, date) == true ? tariff : null;
    final cargo = shipment.cargoValue?.rounded();
    final valuation = shipment.number(Field.valuation)?.rounded();
    final applicable = switch (mode) {
      TradeMode.landed => landedCosts,
      TradeMode.export => exportCosts,
      TradeMode.freight => const <Cost>[],
    };
    final lines = [
      for (final cost in applicable) _line(cost, shipment, freight, accepted),
    ];
    final chargesComplete = lines.every(
      (line) =>
          line.treatment == Treatment.included ||
          line.treatment == Treatment.excluded ||
          line.amount != null,
    );
    Decimal? total;
    if (mode == TradeMode.freight) {
      total = freight.total;
    } else if (chargesComplete && (mode != TradeMode.landed || cargo != null)) {
      var sum = mode == TradeMode.landed ? cargo! : Decimal.zero;
      for (final line in lines) {
        if (line.treatment == Treatment.additional) sum += line.amount!;
      }
      total = sum;
    }
    final quantity = shipment.number(Field.quantity);
    final gross = shipment.number(Field.gross);
    Decimal? divide(Decimal? amount, Decimal? units) =>
        amount == null || units == null || !units.positive
        ? null
        : (amount / units).rounded();

    final percent = shipment.number(Field.goal);
    Decimal? price;
    if (mode == TradeMode.export && total != null && percent != null) {
      final fraction = percent / Decimal.integer(100);
      if (shipment.priceGoal == PriceGoal.markup) {
        price = (total * (Decimal.one + fraction)).ceiling(2);
      } else if (fraction.compareTo(Decimal.one) < 0) {
        price = (total / (Decimal.one - fraction)).ceiling(2);
      }
    }
    final profit = price == null ? null : price - total!;
    final margin = price == null || !price.positive
        ? null
        : profit! / price * Decimal.integer(100);
    final conversion = CurrencyConversion.fromShipment(shipment);
    return TradeResult(
      shipment: shipment,
      freight: freight,
      lines: List.unmodifiable(lines),
      tariff: accepted,
      calculatedOn: date,
      cargoValue: cargo,
      valuation: valuation,
      total: total,
      unitCost: divide(total, quantity),
      perKg: divide(total, gross),
      price: price,
      pricePerUnit: divide(price, quantity),
      profit: profit,
      margin: margin,
      conversion: conversion,
      convertedTotal: total == null ? null : conversion?.convert(total),
    );
  }

  CostLine _line(
    Cost cost,
    Shipment shipment,
    FreightEstimate freight,
    TariffAmounts? tariff,
  ) {
    final treatment = shipment.treatments[cost];
    if (cost == Cost.production && treatment != Treatment.additional) {
      return CostLine(cost, null, Provenance.unavailable, null);
    }
    if (treatment != Treatment.additional) {
      return CostLine(
        cost,
        null,
        treatment == null ? Provenance.unavailable : shipment.provenance,
        treatment,
      );
    }
    if (cost == Cost.freight) {
      final amount = freight.total;
      return CostLine(
        cost,
        amount,
        amount == null ? Provenance.unavailable : shipment.provenance,
        treatment,
      );
    }
    final input = shipment.costs[cost]?.trim() ?? '';
    final entered = Decimal.parse(input)?.rounded();
    final sourced = switch (cost) {
      Cost.duty => tariff?.duty,
      Cost.taxes => tariff?.taxes,
      _ => null,
    };
    final verified =
        input.isEmpty &&
        sourced != null &&
        sourced.compareTo(Decimal.zero) >= 0;
    final amount = verified ? sourced.rounded() : entered;
    return CostLine(
      cost,
      amount,
      verified
          ? Provenance.verified
          : amount == null
          ? Provenance.unavailable
          : shipment.provenance,
      treatment,
    );
  }
}
