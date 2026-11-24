import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/dg_assessment.dart';
import '../domain/dg_models.dart';
import '../domain/dg_providers.dart';

enum SearchStatus { loading, unavailable, empty, error, results, invalid }

class DgSearchState {
  const DgSearchState(this.query, this.status, [this.results = const []]);
  final ClassificationQuery query;
  final SearchStatus status;
  final List<Classification> results;
}

class DgSearchCubit extends Cubit<DgSearchState> {
  DgSearchCubit(this.repository, {DgMode? mode})
    : super(
        DgSearchState(ClassificationQuery(mode: mode), SearchStatus.loading),
      );

  final ClassificationRepository repository;
  int _revision = 0;

  Future<void> update({
    String? text,
    HazardClass? hazard,
    DgMode? mode,
    bool clearHazard = false,
    bool clearMode = false,
    bool? demo,
  }) async {
    final previous = state.query;
    final query = ClassificationQuery(
      text: text ?? previous.text,
      hazard: clearHazard ? null : hazard ?? previous.hazard,
      mode: clearMode ? null : mode ?? previous.mode,
      demo: demo ?? previous.demo,
    );
    final revision = ++_revision;
    if (unLike(query.text) && unNumber(query.text) == null) {
      emit(DgSearchState(query, SearchStatus.invalid));
      return;
    }
    emit(DgSearchState(query, SearchStatus.loading));
    try {
      final items = await repository.search(query);
      if (isClosed || revision != _revision) return;
      final results = items
          .where(
            (item) =>
                (item.verification == DgVerification.synthetic) == query.demo &&
                (query.hazard == null || item.hazard == query.hazard),
          )
          .toList();
      emit(
        DgSearchState(
          query,
          results.isNotEmpty
              ? SearchStatus.results
              : query.demo
              ? SearchStatus.empty
              : SearchStatus.unavailable,
          List.unmodifiable(results),
        ),
      );
    } catch (_) {
      if (!isClosed && revision == _revision) {
        emit(DgSearchState(query, SearchStatus.error));
      }
    }
  }
}

enum DgStep { shipment, documents, review, result }

class DgWizardState {
  const DgWizardState(
    this.draft, {
    this.step = DgStep.shipment,
    this.submitted = false,
    this.loading = false,
    this.assessment,
    this.date,
    this.demo = false,
  });
  final ShipmentDraft draft;
  final DgStep step;
  final bool submitted, loading, demo;
  final DgAssessment? assessment;
  final DateTime? date;
}

class DgWizardCubit extends Cubit<DgWizardState> {
  DgWizardCubit(this.service, {DgMode? mode})
    : super(
        DgWizardState(
          ShipmentDraft({if (mode != null) DgField.mode: mode.name}),
        ),
      );
  final DgAssessmentService service;

  void edit(DgField field, String value) {
    if (state.loading || state.step == DgStep.result) return;
    emit(
      DgWizardState(
        ShipmentDraft({...state.draft.values, field: value}),
        step: state.step,
        submitted: state.submitted,
        demo: state.demo,
      ),
    );
  }

  void example() {
    if (state.loading || state.step != DgStep.shipment) return;
    if (state.demo) {
      emit(DgWizardState(ShipmentDraft()));
      return;
    }
    emit(
      DgWizardState(
        ShipmentDraft({
          DgField.description: 'Fictional training article',
          DgField.un: '9909',
          DgField.physical: PhysicalState.article.name,
          DgField.quantity: '2',
          DgField.unit: 'items',
          DgField.packages: '1',
          DgField.mode: (state.draft.mode ?? DgMode.air).name,
          DgField.origin: 'Example origin',
          DgField.destination: 'Example destination',
          DgField.battery: BatteryFlag.yes.name,
          DgField.chemistry: Chemistry.lithiumIon.name,
          DgField.configuration: Configuration.inEquipment.name,
          DgField.capacity: 'Example value',
          DgField.condition: BatteryCondition.intact.name,
          for (final field in [
            DgField.sds,
            DgField.classification,
            DgField.packaging,
            DgField.batteryTests,
          ])
            field: Readiness.available.name,
        }),
        demo: true,
      ),
    );
  }

  void go(DgStep step) {
    if (!state.loading && step != DgStep.result) {
      emit(DgWizardState(state.draft, step: step, demo: state.demo));
    }
  }

  void back() {
    if (state.step.index > 0) go(DgStep.values[state.step.index - 1]);
  }

  Future<void> next() async {
    final current = state;
    if (current.loading || current.step == DgStep.result) return;
    if (current.step == DgStep.shipment &&
        current.draft.shipmentFields.any(current.draft.invalid)) {
      emit(DgWizardState(current.draft, submitted: true, demo: current.demo));
      return;
    }
    if (current.step != DgStep.review) {
      go(DgStep.values[current.step.index + 1]);
      return;
    }
    emit(
      DgWizardState(
        current.draft,
        step: current.step,
        loading: true,
        demo: current.demo,
      ),
    );
    final date = DateTime.now();
    final assessment = await service.evaluate(
      current.draft,
      date,
      demonstration: current.demo,
    );
    if (!isClosed) {
      emit(
        DgWizardState(
          current.draft,
          step: DgStep.result,
          assessment: assessment,
          date: date,
          demo: current.demo,
        ),
      );
    }
  }
}
