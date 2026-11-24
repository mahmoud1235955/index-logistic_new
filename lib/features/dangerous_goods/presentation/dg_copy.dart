import '../../../core/localization/app_copy.dart';
import '../domain/dg_assessment.dart';
import '../domain/dg_models.dart';

class DgCopy {
  const DgCopy(this.app);
  final AppCopy app;
  String tr(String en, String ar) => app.isArabic ? ar : en;
  String get title => tr('Dangerous goods hub', 'مركز البضائع الخطرة');
  String get disclaimer => tr(
    'Index Logistics provides informational guidance. Official classification, certification and carrier acceptance require specialist review.',
    'يقدم إندكس لوجيستكس إرشادات معلوماتية. يتطلب التصنيف الرسمي والاعتماد وقبول الناقل مراجعة مختص.',
  );
  String get demo => tr(
    'Synthetic training data. Sample identifiers and classifications are fictional.',
    'بيانات تدريب اصطناعية. المعرفات والتصنيفات في الأمثلة خيالية.',
  );
  String get unavailable => tr(
    'Verified regulatory data unavailable',
    'البيانات التنظيمية الموثّقة غير متاحة',
  );
  String get invalidUn => tr(
    'Enter four digits, optionally prefixed with UN.',
    'أدخل أربعة أرقام ويمكن أن تسبقها UN.',
  );
  String name(Classification entry) => tr(entry.name, entry.arabicName);

  String option(Enum item) => switch (item) {
    DgMode.air => tr('Air', 'جوي'),
    DgMode.sea => tr('Sea', 'بحري'),
    DgMode.road => tr('Road', 'بري'),
    HazardClass hazard => '${hazard.code} · ${hazardName(hazard)}',
    PhysicalState.solid => tr('Solid', 'صلب'),
    PhysicalState.liquid => tr('Liquid', 'سائل'),
    PhysicalState.gas => tr('Gas', 'غاز'),
    PhysicalState.article => tr('Article', 'منتج'),
    BatteryFlag.no => tr('No batteries', 'بدون بطاريات'),
    BatteryFlag.yes => tr('Contains batteries', 'يحتوي على بطاريات'),
    Chemistry.lithiumIon => tr('Lithium-ion', 'أيونات الليثيوم'),
    Chemistry.lithiumMetal => tr('Lithium metal', 'فلز الليثيوم'),
    Chemistry.sodiumIon => tr('Sodium-ion', 'أيونات الصوديوم'),
    Chemistry.other => tr('Other chemistry', 'تركيب آخر'),
    Configuration.standalone => tr('Standalone', 'بطارية منفردة'),
    Configuration.packedWithEquipment => tr(
      'Packed with equipment',
      'معبأة مع الجهاز',
    ),
    Configuration.inEquipment => tr(
      'Installed in equipment',
      'مركّبة في الجهاز',
    ),
    BatteryCondition.intact => tr('Intact as reported', 'سليمة حسب الإفادة'),
    BatteryCondition.damagedOrRecalled => tr(
      'Damaged or recalled',
      'تالفة أو مستدعاة',
    ),
    Readiness.available => tr('Available for review', 'متاح للمراجعة'),
    Readiness.missing => tr('Missing', 'غير متاح'),
    DgVerification.synthetic => tr('Synthetic', 'اصطناعي'),
    DgVerification.unverified => tr('Unverified', 'غير موثّق'),
    DgVerification.verified => tr('Verified source record', 'سجل مصدر موثّق'),
    _ => tr('Unsure', 'غير مؤكد'),
  };

  String hazardName(HazardClass hazard) => switch (hazard) {
    HazardClass.explosives => tr('Explosives', 'المتفجرات'),
    HazardClass.gases => tr('Gases', 'الغازات'),
    HazardClass.flammableLiquids => tr(
      'Flammable liquids',
      'السوائل القابلة للاشتعال',
    ),
    HazardClass.flammableSolids => tr(
      'Flammable solids and related hazards',
      'المواد الصلبة القابلة للاشتعال والمخاطر المرتبطة',
    ),
    HazardClass.oxidizers => tr(
      'Oxidizers and organic peroxides',
      'المؤكسدات والبيروكسيدات العضوية',
    ),
    HazardClass.toxicInfectious => tr(
      'Toxic and infectious substances',
      'المواد السامة والمعدية',
    ),
    HazardClass.radioactive => tr('Radioactive material', 'المواد المشعة'),
    HazardClass.corrosive => tr('Corrosives', 'المواد الأكّالة'),
    HazardClass.miscellaneous => tr(
      'Miscellaneous dangerous goods',
      'بضائع خطرة متنوعة',
    ),
  };

  String field(DgField field) => switch (field) {
    DgField.description => tr(
      'Substance or product description',
      'وصف المادة أو المنتج',
    ),
    DgField.un => tr('UN number (if known)', 'رقم الأمم المتحدة (إن عُرف)'),
    DgField.physical => tr('Physical state', 'الحالة الفيزيائية'),
    DgField.quantity => tr('Quantity', 'الكمية'),
    DgField.unit => tr('Measurement unit', 'وحدة القياس'),
    DgField.packages => tr('Package count', 'عدد الطرود'),
    DgField.mode => tr('Transport mode', 'وسيلة النقل'),
    DgField.origin => tr('Origin', 'المنشأ'),
    DgField.destination => tr('Destination', 'الوجهة'),
    DgField.carrier => tr(
      'Carrier or operator (if known)',
      'الناقل أو المشغّل (إن عُرف)',
    ),
    DgField.battery => tr('Battery content', 'وجود بطارية'),
    DgField.chemistry => tr('Battery chemistry', 'تركيب البطارية'),
    DgField.configuration => tr('Battery configuration', 'تكوين البطارية'),
    DgField.capacity => tr('Battery capacity and unit', 'سعة البطارية ووحدتها'),
    DgField.condition => tr('Battery condition', 'حالة البطارية'),
    DgField.sds => document(DgDocument.sds),
    DgField.classification => document(DgDocument.classification),
    DgField.packaging => tr(
      'Packaging and labeling readiness',
      'جاهزية التعبئة والملصقات',
    ),
    DgField.batteryTests => document(DgDocument.batteryTests),
  };

  String document(DgDocument doc) => switch (doc) {
    DgDocument.sds => tr(
      'Safety Data Sheet (SDS)',
      'صحيفة بيانات السلامة (SDS)',
    ),
    DgDocument.classification => tr(
      'Classification documentation',
      'وثائق التصنيف',
    ),
    DgDocument.packaging => tr(
      'Packaging and labeling records',
      'سجلات التعبئة والوسم',
    ),
    DgDocument.declaration => tr(
      'Transport declaration, where applicable',
      'إقرار النقل عند انطباقه',
    ),
    DgDocument.certification => tr(
      'Packaging certification, where applicable',
      'شهادة العبوة عند انطباقها',
    ),
    DgDocument.batteryTests => tr(
      'Battery test documentation, where applicable',
      'وثائق اختبار البطاريات عند انطباقها',
    ),
    DgDocument.modeDocuments => tr(
      'Mode-specific and carrier documents',
      'وثائق وسيلة النقل والناقل',
    ),
  };

  String status(DgStatus status) => switch (status) {
    DgStatus.informationComplete => tr(
      'Information complete for specialist review',
      'البيانات مكتملة لمراجعة المختص',
    ),
    DgStatus.additionalInformation => tr(
      'Additional information required',
      'مطلوب معلومات إضافية',
    ),
    DgStatus.verifiedRestriction => tr(
      'Verified applicable restriction identified',
      'تحديد قيد منطبق من مصدر موثّق',
    ),
    DgStatus.undetermined => tr('Unable to determine', 'يتعذر التحديد'),
    DgStatus.specialistReview => tr(
      'Specialist or carrier review required',
      'يلزم مراجعة المختص أو الناقل',
    ),
  };

  String framework(Framework framework) => switch (framework) {
    Framework.icao => tr(
      framework.title,
      'التعليمات الفنية للإيكاو (Doc 9284)',
    ),
    Framework.iata => tr(framework.title, 'لوائح البضائع الخطرة للإياتا'),
    Framework.imdg => tr(
      framework.title,
      'المدونة البحرية الدولية للبضائع الخطرة',
    ),
    Framework.adr => tr(framework.title, 'اتفاق النقل البري ADR'),
    Framework.nationalRoad => tr(
      framework.title,
      'اللوائح الوطنية للنقل البري',
    ),
  };
}
