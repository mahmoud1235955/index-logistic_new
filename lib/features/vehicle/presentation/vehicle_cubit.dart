import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/country_rule_provider.dart';
import '../domain/customs_calculation.dart';
import '../domain/import_eligibility.dart';
import '../domain/vehicle_profile.dart';

enum VehicleStep { vehicle, importer, finance, review, result }

enum FieldError { required, number, positive, integer, year, date, currency }

class VehicleState {
  VehicleState({
    required this.profile,
    this.step = VehicleStep.vehicle,
    this.scenario = VehicleScenario.unverified,
    this.submitted = false,
    this.loading = false,
    this.lookupFailed = false,
    this.assessment,
    this.estimate,
  });

  final VehicleProfile profile;
  final VehicleStep step;
  final VehicleScenario scenario;
  final bool submitted;
  final bool loading;
  final bool lookupFailed;
  final EligibilityAssessment? assessment;
  final CustomsEstimate? estimate;

  bool get demonstration => scenario != VehicleScenario.unverified;

  List<VehicleField> fields(VehicleStep step) => switch (step) {
    VehicleStep.vehicle => [
      VehicleField.category,
      VehicleField.manufacturer,
      VehicleField.model,
      VehicleField.manufacturingYear,
      VehicleField.modelYear,
      VehicleField.condition,
      VehicleField.fuel,
      if (profile.fuel == Fuel.electric || profile.fuel == Fuel.hybrid)
        VehicleField.powerKw,
      if (profile.fuel != null && profile.fuel != Fuel.electric)
        VehicleField.engineCc,
      if (profile.category == VehicleCategory.truck ||
          profile.category == VehicleCategory.commercial)
        VehicleField.payloadKg,
      if (profile.category == VehicleCategory.bus) VehicleField.seatCount,
      VehicleField.specification,
      VehicleField.origin,
      VehicleField.exportCountry,
      VehicleField.tariffCode,
    ],
    VehicleStep.importer => [
      VehicleField.importer,
      VehicleField.use,
      VehicleField.regime,
      if (profile.regime == ImportRegime.temporary) VehicleField.temporaryDays,
      if (profile.regime == ImportRegime.preferential)
        VehicleField.preferenceProgram,
      if (profile.importer == ImporterKind.individual) VehicleField.residency,
      if (profile.regime != null) VehicleField.preference,
      VehicleField.documents,
      VehicleField.assessmentDate,
    ],
    VehicleStep.finance => [
      VehicleField.currency,
      if (profile.currency == Currency.other) VehicleField.currencyCode,
      VehicleField.purchase,
      VehicleField.freight,
      VehicleField.insurance,
      VehicleField.otherCosts,
      VehicleField.handling,
      if (profile.foreignCurrency) ...[
        VehicleField.exchangeRate,
        VehicleField.exchangeSource,
        VehicleField.exchangeDate,
      ],
    ],
    _ => const [],
  };

  bool optional(VehicleField field) => switch (field) {
    VehicleField.specification => profile.category != VehicleCategory.other,
    VehicleField.powerKw => profile.fuel == Fuel.hybrid,
    VehicleField.tariffCode ||
    VehicleField.documents ||
    VehicleField.preference ||
    VehicleField.exchangeSource ||
    VehicleField.exchangeDate ||
    VehicleField.payloadKg ||
    VehicleField.seatCount ||
    VehicleField.temporaryDays ||
    VehicleField.preferenceProgram => true,
    // A missing FX rate is allowed and produces an incomplete estimate.
    VehicleField.exchangeRate => true,
    _ => false,
  };

  static bool isNumeric(VehicleField field) => switch (field) {
    VehicleField.engineCc ||
    VehicleField.powerKw ||
    VehicleField.manufacturingYear ||
    VehicleField.modelYear ||
    VehicleField.purchase ||
    VehicleField.freight ||
    VehicleField.insurance ||
    VehicleField.otherCosts ||
    VehicleField.handling ||
    VehicleField.exchangeRate ||
    VehicleField.payloadKg ||
    VehicleField.seatCount ||
    VehicleField.temporaryDays => true,
    _ => false,
  };

  FieldError? error(VehicleField field) {
    final value = profile.text(field);
    if (value.isEmpty) return optional(field) ? null : FieldError.required;
    if (field == VehicleField.assessmentDate ||
        field == VehicleField.exchangeDate) {
      final date = profile.date(field);
      if (date == null || date.year < 1900) return FieldError.date;
      if (field == VehicleField.exchangeDate &&
          date.isAfter(profile.date(VehicleField.assessmentDate) ?? date)) {
        return FieldError.date;
      }
    }
    if (field == VehicleField.currencyCode &&
        (!RegExp(r'^[A-Za-z]{3}$').hasMatch(value) ||
            value.toUpperCase() == 'EGP')) {
      return FieldError.currency;
    }
    if (!isNumeric(field)) return null;
    final number = profile.number(field);
    if (number == null) return FieldError.number;
    if (field == VehicleField.manufacturingYear ||
        field == VehicleField.modelYear) {
      final maxYear =
          (profile.date(VehicleField.assessmentDate) ?? DateTime.now()).year +
          1;
      if (number != number.round() || number < 1886 || number > maxYear) {
        return FieldError.year;
      }
    }
    if ((field == VehicleField.engineCc ||
            field == VehicleField.seatCount ||
            field == VehicleField.temporaryDays) &&
        number != number.round()) {
      return FieldError.integer;
    }
    if (const {
          VehicleField.purchase,
          VehicleField.engineCc,
          VehicleField.powerKw,
          VehicleField.exchangeRate,
          VehicleField.payloadKg,
          VehicleField.seatCount,
          VehicleField.temporaryDays,
        }.contains(field) &&
        number <= 0) {
      return FieldError.positive;
    }
    return null;
  }
}

class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit(this.repository, {DateTime? date})
    : super(
        VehicleState(
          profile: VehicleProfile({
            VehicleField.assessmentDate: (date ?? DateTime.now())
                .toIso8601String()
                .substring(0, 10),
            VehicleField.currency: Currency.egp.name,
          }),
        ),
      );

  final CountryRuleProvider repository;

  void change(VehicleField field, String value) {
    if (state.loading || state.profile.text(field) == value.trim()) return;
    emit(
      VehicleState(
        profile: VehicleProfile({...state.profile.values, field: value}),
        step: state.step,
        scenario: state.scenario,
        submitted: state.submitted,
      ),
    );
  }

  void selectScenario(VehicleScenario scenario) {
    if (state.loading || scenario == state.scenario) return;
    emit(
      VehicleState(
        profile: state.profile,
        step: state.step,
        scenario: scenario,
      ),
    );
  }

  void back() {
    if (state.step == VehicleStep.vehicle || state.loading) return;
    edit(VehicleStep.values[state.step.index - 1]);
  }

  void edit(VehicleStep step) {
    if (state.loading || step == VehicleStep.result) return;
    emit(
      VehicleState(
        profile: state.profile,
        step: step,
        scenario: state.scenario,
      ),
    );
  }

  Future<void> next() async {
    if (state.loading || state.step == VehicleStep.result) return;
    final current = state;
    final check = current.step == VehicleStep.review
        ? [VehicleStep.vehicle, VehicleStep.importer, VehicleStep.finance]
        : [current.step];
    for (final step in check) {
      if (current.fields(step).any((field) => current.error(field) != null)) {
        emit(
          VehicleState(
            profile: current.profile,
            step: step,
            scenario: current.scenario,
            submitted: true,
          ),
        );
        return;
      }
    }
    if (current.step != VehicleStep.review) {
      edit(VehicleStep.values[current.step.index + 1]);
      return;
    }

    final profile = VehicleProfile({
      for (final step in check)
        for (final field in current.fields(step))
          field: current.profile.text(field),
    });
    final date = profile.date(VehicleField.assessmentDate)!;
    emit(
      VehicleState(
        profile: current.profile,
        step: current.step,
        scenario: current.scenario,
        loading: true,
      ),
    );
    var rules = const VehicleRuleSet();
    var lookupFailed = false;
    try {
      rules = await repository.lookup(
        VehicleRuleQuery(
          destination: 'EG',
          date: date,
          profile: profile,
          scenario: current.scenario,
        ),
      );
    } catch (_) {
      lookupFailed = true;
    }
    if (isClosed) return;
    emit(
      VehicleState(
        profile: current.profile,
        step: VehicleStep.result,
        scenario: current.scenario,
        lookupFailed: lookupFailed,
        assessment: EligibilityAssessment.evaluate(
          rules.eligibility,
          date,
          demonstration: current.demonstration,
        ),
        estimate: const CustomsCalculator().calculate(
          profile,
          rules.customs,
          date,
          demonstration: current.demonstration,
        ),
      ),
    );
  }
}
