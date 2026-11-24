import 'decimal.dart';

enum TradeMode { landed, export, freight }

enum Transport { sea, air, road }

enum SeaLoad { fcl, lcl }

enum PriceGoal { margin, markup }

enum Incoterm { exw, fca, cpt, cip, dap, dpu, ddp, fas, fob, cfr, cif }

enum Field {
  product,
  hs,
  origin,
  destination,
  departure,
  arrival,
  currency,
  quantity,
  unit,
  unitPrice,
  invoice,
  gross,
  net,
  packages,
  length,
  width,
  height,
  volume,
  cargoType,
  handlingNotes,
  namedPlace,
  carrierNote,
  container,
  containers,
  rate,
  surcharge,
  minimum,
  divisor,
  increment,
  lclKg,
  roadVehicle,
  distance,
  valuation,
  goal,
  quoteCurrency,
  fx,
  fxSource,
  fxDate,
}

enum Cost {
  origin,
  freight,
  insurance,
  duty,
  taxes,
  terminal,
  clearance,
  storageInspection,
  inland,
  bank,
  other,
  production,
  packaging,
  certification,
  exportDocuments,
}

enum Treatment { additional, included, excluded }

enum Provenance { entered, synthetic, verified, unavailable }

class Shipment {
  Shipment({
    required this.mode,
    required this.transport,
    required this.term,
    required this.seaLoad,
    required this.priceGoal,
    required Map<Field, String> inputs,
    required Map<Cost, String> costs,
    required Map<Cost, Treatment> treatments,
    this.synthetic = false,
  }) : inputs = Map.unmodifiable(inputs),
       costs = Map.unmodifiable(costs),
       treatments = Map.unmodifiable(treatments);

  final TradeMode mode;
  final Transport transport;
  final Incoterm term;
  final SeaLoad seaLoad;
  final PriceGoal priceGoal;
  final Map<Field, String> inputs;
  final Map<Cost, String> costs;
  final Map<Cost, Treatment> treatments;
  final bool synthetic;

  Provenance get provenance =>
      synthetic ? Provenance.synthetic : Provenance.entered;
  String text(Field field) => inputs[field]?.trim() ?? '';
  Decimal? number(Field field) => Decimal.parse(text(field));
  String get currency => text(Field.currency).toUpperCase();
  Decimal? get cargoValue {
    if (text(Field.invoice).isNotEmpty) return number(Field.invoice);
    final unitPrice = number(Field.unitPrice);
    final quantity = number(Field.quantity);
    return unitPrice != null && quantity != null ? unitPrice * quantity : null;
  }

  Decimal? get volume {
    if (text(Field.volume).isNotEmpty) return number(Field.volume);
    final count = number(Field.packages);
    final length = number(Field.length);
    final width = number(Field.width);
    final height = number(Field.height);
    if (count == null ||
        !count.positive ||
        !count.whole ||
        length == null ||
        !length.positive ||
        width == null ||
        !width.positive ||
        height == null ||
        !height.positive) {
      return null;
    }
    return count * length * width * height / Decimal.integer(1000000);
  }
}

const landedCosts = [
  Cost.origin,
  Cost.freight,
  Cost.insurance,
  Cost.duty,
  Cost.taxes,
  Cost.terminal,
  Cost.clearance,
  Cost.storageInspection,
  Cost.inland,
  Cost.bank,
  Cost.other,
];
const exportCosts = [
  Cost.production,
  Cost.packaging,
  Cost.inland,
  Cost.certification,
  Cost.exportDocuments,
  Cost.origin,
  Cost.freight,
  Cost.insurance,
  Cost.terminal,
  Cost.duty,
  Cost.taxes,
  Cost.bank,
  Cost.other,
];
