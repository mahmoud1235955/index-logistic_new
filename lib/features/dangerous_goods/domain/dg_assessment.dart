import 'dg_models.dart';
import 'dg_providers.dart';

enum DgStatus {
  informationComplete,
  additionalInformation,
  verifiedRestriction,
  undetermined,
  specialistReview,
}

class DgAssessment {
  const DgAssessment(
    this.status,
    this.missing, {
    this.restriction,
    this.lookupFailed = false,
  });
  final DgStatus status;
  final Set<DgField> missing;
  final VerifiedRestriction? restriction;
  final bool lookupFailed;
}

class DgAssessmentService {
  const DgAssessmentService(this.repository, this.providers);
  final ClassificationRepository repository;
  final RuleProviders providers;

  Future<DgAssessment> evaluate(
    ShipmentDraft shipment,
    DateTime date, {
    bool demonstration = false,
  }) async {
    final missing = {
      ...shipment.missing,
      for (final field in [
        ...shipment.shipmentFields,
        ...shipment.readinessFields,
      ])
        if (shipment.invalid(field)) field,
    };
    if (missing.isNotEmpty) {
      return DgAssessment(
        DgStatus.additionalInformation,
        Set.unmodifiable(missing),
      );
    }
    final needsSpecialist =
        [
          ...shipment.readinessFields,
          DgField.physical,
          DgField.battery,
          if (shipment.battery == BatteryFlag.yes) ...[
            DgField.condition,
            DgField.chemistry,
            DgField.configuration,
          ],
        ].any((field) => shipment.text(field) == 'unsure') ||
        (shipment.battery == BatteryFlag.yes &&
            shipment.text(DgField.condition) ==
                BatteryCondition.damagedOrRecalled.name);
    if (needsSpecialist) {
      return const DgAssessment(DgStatus.specialistReview, {});
    }
    final un = shipment.un;
    final mode = shipment.mode;
    if (un == null || mode == null) {
      return const DgAssessment(DgStatus.undetermined, {DgField.un});
    }
    if (demonstration) {
      return const DgAssessment(DgStatus.informationComplete, {});
    }

    try {
      final records = await repository.search(
        ClassificationQuery(text: un, mode: mode),
      );
      final matches = records
          .where((record) => record.un == un && record.supports(mode, date))
          .toList();
      if (matches.length == 1) {
        final query = RuleQuery(shipment, matches.single, date);
        for (final entry in providers.forMode(mode).entries) {
          final restrictions = await entry.value?.restrictions(query) ?? [];
          for (final restriction in restrictions) {
            if (identical(restriction.query, query) &&
                restriction.source.framework == entry.key &&
                restriction.source.isApplicable(mode, date) &&
                restriction.english.trim().isNotEmpty &&
                restriction.arabic.trim().isNotEmpty) {
              return DgAssessment(
                DgStatus.verifiedRestriction,
                {},
                restriction: restriction,
              );
            }
          }
        }
      }
      return const DgAssessment(DgStatus.informationComplete, {});
    } catch (_) {
      return const DgAssessment(DgStatus.undetermined, {}, lookupFailed: true);
    }
  }
}
