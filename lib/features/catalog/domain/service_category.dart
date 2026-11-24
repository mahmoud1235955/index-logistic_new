enum CategoryType { directory, journey, reference, tool }

enum CategoryPhase { p1, p2, p3 }

enum CategoryReadiness { preview }

class CategoryCapability {
  const CategoryCapability({
    required this.nameAr,
    required this.nameEn,
    required this.phase,
  });

  final String nameAr;
  final String nameEn;
  final CategoryPhase phase;
}

class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.type,
    this.futureCapability,
  });

  final String id;
  final String slug;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final CategoryType type;
  final CategoryCapability? futureCapability;

  CategoryPhase get referencePhase => CategoryPhase.p1;
  CategoryReadiness get readiness => CategoryReadiness.preview;
}
