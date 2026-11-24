import 'package_group.dart';

enum CommercialType {
  buying,
  selling,
  opportunity,
  logistics,
  question,
  announcement,
}

enum ReportReason { inaccurate, inappropriate, unwanted }

typedef LocalReport = ({String id, String subject, ReportReason reason});

enum FreightMode { sea, air, road }

enum FreightService { pickup, clearance, insurance, storage, delivery }

enum QuoteField { origin, destination, readyDate, cargo, equipment, handling }

class QuoteDraft {
  QuoteDraft({
    Map<QuoteField, String> fields = const {},
    this.mode,
    List<PackageInput> packages = const [],
    Set<FreightService> services = const {},
  }) : fields = Map.unmodifiable(fields),
       services = Set.unmodifiable(services),
       packages = List.unmodifiable(packages);

  final Map<QuoteField, String> fields;
  final FreightMode? mode;
  final List<PackageInput> packages;
  final Set<FreightService> services;
  String text(QuoteField field) => fields[field]?.trim() ?? '';
  Iterable<QuoteField> get missing => const [
    QuoteField.origin,
    QuoteField.destination,
    QuoteField.cargo,
  ].where((field) => text(field).isEmpty);
}
