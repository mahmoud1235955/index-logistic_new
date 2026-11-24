import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_trade_data.dart';
import '../domain/decimal.dart';
import '../domain/incoterms.dart';
import '../domain/shipment.dart';
import '../domain/tariff_provider.dart';
import '../domain/trade_engine.dart';

enum TradeStep { shipment, freight, costs, review, result }

enum InputIssue {
  required,
  numeric,
  positive,
  whole,
  currency,
  netWeight,
  dimensions,
  term,
  margin,
  date,
}

class TradeState {
  const TradeState(
    this.shipment, {
    this.step = TradeStep.shipment,
    this.submitted = false,
    this.loading = false,
    this.result,
    this.saved = const [],
    this.providerFailed = false,
  });
  final Shipment shipment;
  final TradeStep step;
  final bool submitted, loading, providerFailed;
  final TradeResult? result;
  final List<TradeResult> saved;

  List<Cost> get costFields => switch (shipment.mode) {
    TradeMode.landed => landedCosts,
    TradeMode.export => exportCosts,
    TradeMode.freight => const [],
  };

  List<Field> fields(TradeStep step) => switch (step) {
    TradeStep.shipment => const [
      Field.product,
      Field.hs,
      Field.origin,
      Field.destination,
      Field.departure,
      Field.arrival,
      Field.currency,
      Field.quantity,
      Field.unit,
      Field.unitPrice,
      Field.invoice,
      Field.gross,
      Field.net,
      Field.packages,
      Field.length,
      Field.width,
      Field.height,
      Field.volume,
      Field.cargoType,
      Field.handlingNotes,
      Field.namedPlace,
    ],
    TradeStep.freight => [
      Field.carrierNote,
      if (shipment.transport == Transport.sea &&
          shipment.seaLoad == SeaLoad.fcl) ...[
        Field.container,
        Field.containers,
      ],
      if (shipment.transport == Transport.air) Field.divisor,
      if (shipment.transport == Transport.sea &&
          shipment.seaLoad == SeaLoad.lcl)
        Field.lclKg,
      if (shipment.transport == Transport.road) ...[
        Field.roadVehicle,
        Field.distance,
      ],
      if (shipment.transport == Transport.air ||
          (shipment.transport == Transport.sea &&
              shipment.seaLoad == SeaLoad.lcl)) ...[
        Field.increment,
        Field.minimum,
      ],
      Field.rate,
      Field.surcharge,
    ],
    TradeStep.costs => [
      if (shipment.mode == TradeMode.landed) Field.valuation,
      if (shipment.mode == TradeMode.export) Field.goal,
      Field.quoteCurrency,
      if (shipment.text(Field.quoteCurrency).isNotEmpty ||
          shipment.text(Field.fx).isNotEmpty) ...[
        Field.fx,
        Field.fxSource,
        Field.fxDate,
      ],
    ],
    _ => const [],
  };

  bool required(Field field) => const {
    Field.product,
    Field.origin,
    Field.destination,
    Field.departure,
    Field.arrival,
    Field.currency,
    Field.quantity,
    Field.unit,
    Field.namedPlace,
  }.contains(field);

  static bool numeric(Field field) => const {
    Field.quantity,
    Field.unitPrice,
    Field.invoice,
    Field.gross,
    Field.net,
    Field.packages,
    Field.length,
    Field.width,
    Field.height,
    Field.volume,
    Field.containers,
    Field.rate,
    Field.surcharge,
    Field.minimum,
    Field.divisor,
    Field.increment,
    Field.lclKg,
    Field.distance,
    Field.valuation,
    Field.goal,
    Field.fx,
  }.contains(field);

  InputIssue? issue(Field field) {
    final raw = shipment.text(field);
    if (field == Field.namedPlace &&
        !shipment.term.supports(shipment.transport)) {
      return InputIssue.term;
    }
    const dimensions = [Field.length, Field.width, Field.height];
    if (field == dimensions.first &&
        dimensions.any((item) => shipment.text(item).isNotEmpty) &&
        [
          ...dimensions,
          Field.packages,
        ].any((item) => shipment.text(item).isEmpty)) {
      return InputIssue.dimensions;
    }
    if (raw.isEmpty) return required(field) ? InputIssue.required : null;
    if (field == Field.currency || field == Field.quoteCurrency) {
      final code = raw.toUpperCase();
      if (!RegExp(r'^[A-Z]{3}$').hasMatch(code) ||
          (field == Field.quoteCurrency && code == shipment.currency)) {
        return InputIssue.currency;
      }
    }
    if (field == Field.fxDate) {
      final date = DateTime.tryParse(raw);
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw) ||
          date == null ||
          date.toIso8601String().substring(0, 10) != raw) {
        return InputIssue.date;
      }
    }
    if (!numeric(field)) return null;
    final value = shipment.number(field);
    if (value == null) return InputIssue.numeric;
    if (const {
          Field.quantity,
          Field.gross,
          Field.net,
          Field.packages,
          Field.length,
          Field.width,
          Field.height,
          Field.volume,
          Field.containers,
          Field.divisor,
          Field.lclKg,
          Field.distance,
          Field.increment,
          Field.fx,
        }.contains(field) &&
        !value.positive) {
      return InputIssue.positive;
    }
    if ((field == Field.packages || field == Field.containers) &&
        !value.whole) {
      return InputIssue.whole;
    }
    final gross = shipment.number(Field.gross);
    if (field == Field.net && gross != null) {
      if (value.compareTo(gross) > 0) return InputIssue.netWeight;
    }
    if (field == Field.goal &&
        shipment.priceGoal == PriceGoal.margin &&
        value.compareTo(Decimal.integer(100)) >= 0) {
      return InputIssue.margin;
    }
    return null;
  }
}

class TradeCubit extends Cubit<TradeState> {
  TradeCubit(TradeMode mode, {this.provider = const LocalTariffs()})
    : super(TradeState(_blank(mode)));

  final TariffProvider provider;

  static Shipment _blank(TradeMode mode) => Shipment(
    mode: mode,
    transport: Transport.sea,
    term: Incoterm.fca,
    seaLoad: SeaLoad.fcl,
    priceGoal: PriceGoal.margin,
    inputs: const {},
    costs: const {},
    treatments: const {},
  );

  void _replace(Shipment shipment) => emit(
    TradeState(
      shipment,
      step: state.step,
      submitted: state.submitted,
      saved: state.saved,
    ),
  );

  void editDraft({
    TradeMode? mode,
    Transport? transport,
    Incoterm? term,
    SeaLoad? seaLoad,
    PriceGoal? priceGoal,
    Field? field,
    String? value,
    Cost? cost,
    Treatment? treatment,
  }) {
    if (state.loading || state.step == TradeStep.result) return;
    final current = state.shipment;
    if (mode != null && mode != current.mode && current.synthetic) {
      _replace(demoShipment(mode));
      return;
    }
    final newMode = mode ?? current.mode;
    final changedCarrierBasis =
        (transport != null && transport != current.transport) ||
        (seaLoad != null && seaLoad != current.seaLoad);
    final inputs = {...current.inputs};
    if (changedCarrierBasis) {
      for (final input in state.fields(TradeStep.freight)) {
        inputs.remove(input);
      }
    }
    if (field != null) inputs[field] = value ?? '';
    _replace(
      Shipment(
        mode: newMode,
        transport: transport ?? current.transport,
        term: term ?? current.term,
        seaLoad: seaLoad ?? current.seaLoad,
        priceGoal: priceGoal ?? current.priceGoal,
        synthetic: current.synthetic,
        inputs: inputs,
        costs: {
          if (newMode == current.mode) ...current.costs,
          if (cost != null && value != null) cost: value,
        },
        treatments: {
          if (newMode == current.mode) ...current.treatments,
          if (cost != null && treatment != null) cost: treatment,
        },
      ),
    );
  }

  void loadDemo() => _replace(demoShipment(state.shipment.mode));
  void reset() => _replace(_blank(state.shipment.mode));

  void go(TradeStep step) {
    if (!state.loading && step != TradeStep.result) {
      emit(TradeState(state.shipment, step: step, saved: state.saved));
    }
  }

  void back() {
    if (state.step.index > 0) go(TradeStep.values[state.step.index - 1]);
  }

  Future<void> next() async {
    final current = state;
    if (current.loading || current.step == TradeStep.result) return;
    final checked = current.step == TradeStep.review
        ? TradeStep.values.take(3)
        : [current.step];
    for (final step in checked) {
      final invalidCosts =
          step == TradeStep.costs &&
          current.costFields.any((cost) {
            final raw = current.shipment.costs[cost]?.trim() ?? '';
            return current.shipment.treatments[cost] == Treatment.additional &&
                raw.isNotEmpty &&
                Decimal.parse(raw) == null;
          });
      if (invalidCosts ||
          current.fields(step).any((field) => current.issue(field) != null)) {
        emit(
          TradeState(
            current.shipment,
            step: step,
            submitted: true,
            saved: current.saved,
          ),
        );
        return;
      }
    }
    if (current.step != TradeStep.review) {
      go(TradeStep.values[current.step.index + 1]);
      return;
    }
    final shipment = current.shipment;
    emit(
      TradeState(
        shipment,
        step: current.step,
        saved: current.saved,
        loading: true,
      ),
    );
    final date = DateTime.now();
    TariffAmounts? tariff;
    var providerFailed = false;
    if (shipment.mode == TradeMode.landed && !shipment.synthetic) {
      try {
        tariff = await provider.lookup(shipment, date);
      } catch (_) {
        providerFailed = true;
      }
    }
    if (isClosed) return;
    emit(
      TradeState(
        shipment,
        step: TradeStep.result,
        saved: current.saved,
        providerFailed: providerFailed,
        result: const TradeEngine().calculate(
          shipment,
          tariff: tariff,
          date: date,
        ),
      ),
    );
  }

  void toggleSaved() {
    final result = state.result;
    if (result == null) return;
    final saved = [...state.saved];
    if (!saved.remove(result)) {
      saved.add(result);
      if (saved.length > 3) saved.removeAt(0);
    }
    emit(
      TradeState(
        state.shipment,
        step: state.step,
        result: result,
        providerFailed: state.providerFailed,
        saved: List.unmodifiable(saved),
      ),
    );
  }
}
