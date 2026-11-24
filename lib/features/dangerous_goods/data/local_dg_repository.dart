import '../domain/dg_models.dart';
import '../domain/dg_providers.dart';

class LocalDgRepository implements ClassificationRepository {
  const LocalDgRepository();

  @override
  Future<List<Classification>> search(ClassificationQuery query) async {
    if (!query.demo) return const [];
    final text = digits(query.text.trim()).toLowerCase();
    final code = unNumber(text);
    return List.unmodifiable([
      for (final item in samples)
        if ((query.hazard == null || item.hazard == query.hazard) &&
            (query.mode == null || item.demoModes.contains(query.mode)) &&
            (text.isEmpty ||
                (code != null
                    ? item.un == code
                    : [
                        item.name,
                        item.arabicName,
                        item.hazard.name,
                        item.division ?? '',
                        ...item.alternatives,
                      ].any((name) => name.toLowerCase().contains(text)))))
          item,
    ]);
  }
}

final samples = List<Classification>.unmodifiable([
  for (final hazard in HazardClass.values)
    Classification(
      un: '990${hazard.code}',
      name: 'Fictional training entry ${hazard.code}',
      arabicName: 'سجل تدريبي خيالي ${hazard.code}',
      hazard: hazard,
      division: hazard.divisions.firstOrNull,
      alternatives: hazard == HazardClass.miscellaneous
          ? const ['Sample battery profile', 'ملف بطارية تجريبي']
          : ['Sample class ${hazard.code}', 'مثال فئة ${hazard.code}'],
      verification: DgVerification.synthetic,
      demoModes: [DgMode.values[hazard.index % DgMode.values.length]],
    ),
]);
