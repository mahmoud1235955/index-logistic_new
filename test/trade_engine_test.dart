import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/features/trade/data/local_trade_data.dart';
import 'package:index_logistic/features/trade/domain/decimal.dart';
import 'package:index_logistic/features/trade/domain/freight_rules.dart';
import 'package:index_logistic/features/trade/domain/incoterms.dart';
import 'package:index_logistic/features/trade/domain/shipment.dart';
import 'package:index_logistic/features/trade/domain/tariff_provider.dart';
import 'package:index_logistic/features/trade/domain/trade_engine.dart';

final _date = DateTime(2026, 11, 24);

Shipment _shipment({
  TradeMode mode = TradeMode.landed,
  Transport transport = Transport.air,
  SeaLoad seaLoad = SeaLoad.fcl,
  PriceGoal goal = PriceGoal.margin,
  bool synthetic = true,
  Incoterm term = Incoterm.fca,
  Map<Field, String> data = const {},
  Map<Cost, String> costs = const {},
  Map<Cost, Treatment> treatments = const {},
}) {
  final fixture = demoShipment(mode);
  return Shipment(
    mode: mode,
    transport: transport,
    term: term,
    seaLoad: seaLoad,
    priceGoal: goal,
    synthetic: synthetic,
    inputs: {...fixture.inputs, ...data},
    costs: {...fixture.costs, ...costs},
    treatments: {...fixture.treatments, ...treatments},
  );
}

TradeResult _calculate(Shipment shipment, {TariffAmounts? tariff}) =>
    const TradeEngine().calculate(shipment, date: _date, tariff: tariff);

void main() {
  test(
    'V4 package example yields 0.156 CBM, 26 volumetric kg and 45 chargeable kg',
    () {
      final shipment = demoShipment(TradeMode.freight);
      final result = _calculate(shipment);
      expect(shipment.volume!.format(3), '0.156');
      expect(result.freight.volumetricKg!.format(), '26.00');
      expect(result.freight.units!.format(), '45.00');
      expect(result.freight.base!.format(), '99.00');
      expect(result.total!.format(), '104.00');
      expect(result.unitCost!.format(), '34.67');
    },
  );

  test('air uses the supplied divisor, billing increment and minimum', () {
    final result = _calculate(
      _shipment(
        mode: TradeMode.freight,
        data: {
          Field.volume: '0.301',
          Field.gross: '30',
          Field.divisor: '5000',
          Field.increment: '5',
          Field.rate: '1',
          Field.minimum: '80',
        },
      ),
    );
    expect(result.freight.volumetricKg!.format(), '60.20');
    expect(result.freight.units!.format(), '65.00');
    expect(result.total!.format(), '85.00');
  });

  test('FCL multiplies per-container rate and adds rounded surcharge', () {
    final result = _calculate(
      _shipment(
        mode: TradeMode.freight,
        transport: Transport.sea,
        data: {
          Field.container: '40HC',
          Field.containers: '2',
          Field.rate: '125.125',
          Field.surcharge: '0.005',
        },
      ),
    );
    expect(result.freight.base!.format(), '250.25');
    expect(result.total!.format(), '250.26');
  });

  test(
    'LCL uses the carrier weight equivalence and rounds up by its increment',
    () {
      final result = _calculate(
        _shipment(
          mode: TradeMode.freight,
          transport: Transport.sea,
          seaLoad: SeaLoad.lcl,
          data: {
            Field.gross: '525',
            Field.volume: '1.2',
            Field.lclKg: '250',
            Field.rate: '40',
            Field.increment: '0.25',
            Field.minimum: '0',
            Field.surcharge: '10',
          },
        ),
      );
      expect(result.freight.units!.format(), '2.25');
      expect(result.total!.format(), '100.00');
    },
  );

  test('road uses the entered charge without deriving it from distance', () {
    final result = _calculate(
      _shipment(
        mode: TradeMode.freight,
        transport: Transport.road,
        data: {
          Field.roadVehicle: 'Rigid truck',
          Field.distance: '500',
          Field.rate: '220',
        },
      ),
    );
    expect(result.total!.format(), '225.00');
  });

  test(
    'import totals costs once, reports per unit and converts only the resulting total',
    () {
      final result = _calculate(
        _shipment(
          data: {
            Field.quoteCurrency: 'EUR',
            Field.fx: '٠٫٩١٢٣٤٥',
            Field.fxSource: 'Fictional exercise',
          },
        ),
      );
      expect(result.total!.format(), '468.00');
      expect(result.valuation!.format(), '404.00');
      expect(result.unitCost!.format(), '156.00');
      expect(result.perKg!.format(), '10.40');
      expect(result.convertedTotal!.format(), '426.98');
      expect(result.conversion!.provenance, Provenance.synthetic);
    },
  );

  test(
    'CIF invoice with included freight and insurance does not double-count them',
    () {
      final result = _calculate(
        _shipment(
          transport: Transport.sea,
          term: Incoterm.cif,
          data: {Field.invoice: '409', Field.rate: '', Field.surcharge: ''},
          treatments: {
            Cost.freight: Treatment.included,
            Cost.insurance: Treatment.included,
          },
        ),
      );
      expect(result.cargoValue!.format(), '409.00');
      expect(result.total!.format(), '468.00');
      final freight = result.lines.singleWhere(
        (line) => line.cost == Cost.freight,
      );
      expect(freight.treatment, Treatment.included);
      expect(freight.amount, isNull);
    },
  );

  test(
    'unknown duty, freight minimum and invoice value each block their affected totals',
    () {
      final noDuty = _calculate(_shipment(costs: {Cost.duty: ''}));
      expect(noDuty.total, isNull);
      expect(
        noDuty.lines.singleWhere((line) => line.cost == Cost.duty).provenance,
        Provenance.unavailable,
      );
      final noMinimum = _calculate(
        _shipment(mode: TradeMode.freight, data: {Field.minimum: ''}),
      );
      expect(noMinimum.total, isNull);
      expect(noMinimum.freight.missing, contains(FreightInput.minimum));
      final noInvoice = _calculate(_shipment(data: {Field.unitPrice: ''}));
      expect(noInvoice.total, isNull);
      final noFx = _calculate(
        _shipment(data: {Field.quoteCurrency: 'EUR', Field.fx: ''}),
      );
      expect(noFx.total, isNotNull);
      expect(noFx.convertedTotal, isNull);
    },
  );

  test(
    'verified tariff amounts are restricted by source, date, currency and mode',
    () {
      final shipment = _shipment(synthetic: false, costs: {Cost.duty: ''});
      TariffAmounts input(bool verified, DateTime from) => TariffAmounts(
        currency: 'USD',
        source: 'Test provider record',
        version: 'test-version',
        effectiveFrom: from,
        verified: verified,
        duty: Decimal.integer(15),
      );
      expect(_calculate(shipment, tariff: input(false, _date)).total, isNull);
      expect(
        _calculate(shipment, tariff: input(true, DateTime(2027))).total,
        isNull,
      );
      final result = _calculate(shipment, tariff: input(true, _date));
      expect(result.total!.format(), '468.00');
      expect(
        result.lines.singleWhere((line) => line.cost == Cost.duty).provenance,
        Provenance.verified,
      );
    },
  );

  test(
    'margin and markup use distinct denominators and selling prices round upward',
    () {
      final margin = _calculate(_shipment(mode: TradeMode.export));
      final markup = _calculate(
        _shipment(mode: TradeMode.export, goal: PriceGoal.markup),
      );
      expect(margin.total!.format(), '283.00');
      expect(margin.price!.format(), '353.75');
      expect(margin.pricePerUnit!.format(), '117.92');
      expect(margin.profit!.format(), '70.75');
      expect(margin.margin!.format(), '20.00');
      expect(markup.price!.format(), '339.60');
      expect(markup.margin!.format(), '16.67');
      final fractional = _calculate(
        _shipment(mode: TradeMode.export, data: {Field.goal: '30'}),
      );
      expect(fractional.price!.format(), '404.29');
      final invalid = _calculate(
        _shipment(mode: TradeMode.export, data: {Field.goal: '100'}),
      );
      expect(invalid.price, isNull);
      final excluded = _calculate(
        _shipment(
          mode: TradeMode.export,
          treatments: {Cost.production: Treatment.excluded},
        ),
      );
      expect(excluded.total, isNull);
    },
  );

  test('exact decimal rounding and eleven Incoterms transport groups', () {
    expect((Decimal.parse('0.1')! + Decimal.parse('0.2')!).format(), '0.30');
    expect(Decimal.parse('1.005')!.format(), '1.01');
    expect(Decimal.parse('1,005'), isNull);
    expect(Incoterm.values.length, 11);
    expect(
      Incoterm.values.where((term) => term.supports(Transport.sea)).length,
      11,
    );
    expect(
      Incoterm.values.where((term) => term.supports(Transport.air)).length,
      7,
    );
    expect(Incoterm.cif.sellerContractsInsurance, isTrue);
  });
}
