enum ReferenceField {
  country,
  destination,
  region,
  product,
  service,
  equipment,
  port,
  airport,
  permit,
  organizer,
  date,
  currency,
  carrier,
  tracking,
  source,
  temperature,
  language,
}

typedef ReferenceQuery = ({
  String category,
  Map<ReferenceField, String> fields,
});
typedef ReferenceRecord = ({String label, String source, DateTime reviewedAt});

abstract interface class ReferenceProvider {
  Future<List<ReferenceRecord>?> lookup(ReferenceQuery query);
}

class LocalReferenceProvider implements ReferenceProvider {
  const LocalReferenceProvider();

  @override
  Future<List<ReferenceRecord>?> lookup(ReferenceQuery query) async => null;
}
