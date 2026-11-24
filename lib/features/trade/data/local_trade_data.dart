import '../domain/shipment.dart';
import '../domain/tariff_provider.dart';

class LocalTariffs implements TariffProvider {
  const LocalTariffs();

  @override
  Future<TariffAmounts?> lookup(Shipment shipment, DateTime date) async => null;
}

Shipment demoShipment(TradeMode mode) => Shipment(
  mode: mode,
  transport: Transport.air,
  term: Incoterm.fca,
  seaLoad: SeaLoad.fcl,
  priceGoal: PriceGoal.margin,
  synthetic: true,
  inputs: const {
    Field.product: 'Sample cartons',
    Field.origin: 'Egypt',
    Field.destination: 'Jordan',
    Field.departure: 'CAI',
    Field.arrival: 'AMM',
    Field.currency: 'USD',
    Field.quantity: '3',
    Field.unit: 'carton',
    Field.unitPrice: '100',
    Field.gross: '45',
    Field.net: '42',
    Field.packages: '3',
    Field.length: '20',
    Field.width: '40',
    Field.height: '65',
    Field.cargoType: 'Sample general cargo',
    Field.namedPlace: 'CAI',
    Field.carrierNote: 'Synthetic example',
    Field.divisor: '6000',
    Field.increment: '1',
    Field.rate: '2.2',
    Field.minimum: '40',
    Field.surcharge: '5',
    Field.valuation: '404',
    Field.goal: '20',
  },
  costs: const {
    Cost.origin: '12',
    Cost.insurance: '5',
    Cost.duty: '15',
    Cost.taxes: '7',
    Cost.terminal: '4',
    Cost.clearance: '8',
    Cost.storageInspection: '0',
    Cost.inland: '10',
    Cost.bank: '3',
    Cost.other: '0',
    Cost.production: '125',
    Cost.packaging: '12',
    Cost.certification: '3',
    Cost.exportDocuments: '5',
  },
  treatments: {
    for (final cost in (mode == TradeMode.export ? exportCosts : landedCosts))
      cost:
          mode == TradeMode.export && (cost == Cost.duty || cost == Cost.taxes)
          ? Treatment.excluded
          : Treatment.additional,
  },
);
