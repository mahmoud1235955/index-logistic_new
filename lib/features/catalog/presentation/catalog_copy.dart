import '../../../core/localization/app_copy.dart';
import '../domain/service_category.dart';

class CatalogCopy {
  const CatalogCopy(this.app);

  final AppCopy app;

  String _text(String ar, String en) => app.isArabic ? ar : en;

  String get title => _text('فهرس الخدمات', 'Service catalog');
  String get search => _text('البحث في فهرس الخدمات', 'Search service catalog');
  String get searchHint => _text(
    'الاسم بالعربية أو الإنجليزية، أو CAT-01',
    'Arabic or English name, or CAT-01',
  );
  String get browse => _text('تصفح فهرس الخدمات', 'Browse service catalog');
  String get preview => _text('معاينة محلية', 'Local preview');
  String get notice => _text(
    'أوصاف مرجعية للعرض فقط. الخدمات والبيانات التشغيلية غير متاحة في هذه المعاينة.',
    'Reference descriptions for demonstration only. Operational services and data are unavailable in this preview.',
  );
  String count(int results, int total) =>
      _text('$results من $total قسمًا', '$results of $total categories');
  String get noResults => _text(
    'لا توجد أقسام مطابقة. جرّب اسمًا آخر أو معرّف قسم.',
    'No categories match. Try another name or a category ID.',
  );
  String get scope => _text('نطاق القسم في V4', 'Category scope in V4');
  String get future => _text('قدرة مستقبلية', 'Future capability');
  String get phase => _text('المرحلة المرجعية', 'Reference phase');
  String get related => _text('أقسام مرتبطة', 'Related categories');
  String get back => _text('العودة إلى الفهرس', 'Back to catalog');

  String name(ServiceCategory category) =>
      _text(category.nameAr, category.nameEn);

  String description(ServiceCategory category) =>
      _text(category.descriptionAr, category.descriptionEn);

  String capability(CategoryCapability item) => _text(item.nameAr, item.nameEn);

  String type(CategoryType type) => switch (type) {
    CategoryType.directory => _text('دليل', 'Directory'),
    CategoryType.journey => _text('مسار', 'Journey'),
    CategoryType.reference => _text('مرجع', 'Reference'),
    CategoryType.tool => _text('أداة', 'Tool'),
  };
}
