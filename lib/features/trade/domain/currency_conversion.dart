import 'decimal.dart';
import 'shipment.dart';

class CurrencyConversion {
  const CurrencyConversion(
    this.currency,
    this.rate,
    this.provenance, {
    this.source,
    this.date,
  });

  final String currency;
  final Decimal rate;
  final Provenance provenance;
  final String? source;
  final String? date;

  Decimal convert(Decimal value) => (value * rate).rounded();

  static CurrencyConversion? fromShipment(Shipment shipment) {
    final target = shipment.text(Field.quoteCurrency).toUpperCase();
    final rate = shipment.number(Field.fx);
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(target) ||
        target == shipment.currency ||
        rate == null ||
        !rate.positive) {
      return null;
    }
    return CurrencyConversion(
      target,
      rate,
      shipment.provenance,
      source: shipment.text(Field.fxSource),
      date: shipment.text(Field.fxDate),
    );
  }
}
