import 'decimal.dart';
import 'shipment.dart';

class TariffAmounts {
  const TariffAmounts({
    required this.currency,
    required this.source,
    required this.version,
    required this.verified,
    required this.effectiveFrom,
    this.effectiveThrough,
    this.duty,
    this.taxes,
  });

  final String currency;
  final String source;
  final String version;
  final bool verified;
  final DateTime effectiveFrom;
  final DateTime? effectiveThrough;
  final Decimal? duty;
  final Decimal? taxes;

  bool appliesTo(Shipment shipment, DateTime date) =>
      verified &&
      shipment.mode == TradeMode.landed &&
      !shipment.synthetic &&
      currency == shipment.currency &&
      source.trim().isNotEmpty &&
      version.trim().isNotEmpty &&
      !date.isBefore(effectiveFrom) &&
      (effectiveThrough == null || !date.isAfter(effectiveThrough!));
}

abstract interface class TariffProvider {
  Future<TariffAmounts?> lookup(Shipment shipment, DateTime date);
}
