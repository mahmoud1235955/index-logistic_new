import '../../../core/localization/app_copy.dart';
import '../domain/country_rule_provider.dart';
import '../domain/customs_calculation.dart';
import '../domain/import_eligibility.dart';
import '../domain/legal_reference.dart';
import '../domain/vehicle_profile.dart';

class VehicleCopy {
  const VehicleCopy(this.app);
  final AppCopy app;
  String tr(String en, String ar) => app.isArabic ? ar : en;

  String get title => tr('Egypt vehicle import', 'استيراد المركبات إلى مصر');
  String get open =>
      tr('Open vehicle import calculator', 'افتح حاسبة استيراد المركبات');
  String get disclaimer => tr(
    'Estimates are informational and subject to official Egyptian customs and import regulations. They do not constitute official approval.',
    'التقديرات لأغراض معلوماتية وتخضع للوائح الجمارك والاستيراد المصرية الرسمية. ولا تُعد موافقة رسمية.',
  );
  String get synthetic => tr(
    'Synthetic demonstration. These example rules and rates do not represent Egyptian law.',
    'عرض توضيحي ببيانات اصطناعية. قواعد ونسب المثال لا تمثل القانون المصري.',
  );

  String field(VehicleField field) => switch (field) {
    VehicleField.category => tr('Vehicle category', 'فئة المركبة'),
    VehicleField.manufacturer => tr('Manufacturer', 'الشركة المصنّعة'),
    VehicleField.model => tr('Model', 'الطراز'),
    VehicleField.manufacturingYear => tr('Manufacturing year', 'سنة التصنيع'),
    VehicleField.modelYear => tr('Model year', 'سنة الطراز'),
    VehicleField.condition => tr('Condition', 'حالة المركبة'),
    VehicleField.engineCc => tr('Engine capacity (cc)', 'سعة المحرك (سم³)'),
    VehicleField.powerKw => tr('Motor power (kW)', 'قدرة المحرك (كيلوواط)'),
    VehicleField.fuel => tr('Fuel type', 'نوع الوقود'),
    VehicleField.payloadKg => tr('Payload (kg)', 'الحمولة (كجم)'),
    VehicleField.seatCount => tr('Number of seats', 'عدد المقاعد'),
    VehicleField.specification => tr(
      'Other vehicle specifications',
      'مواصفات أخرى للمركبة',
    ),
    VehicleField.origin => tr('Country of origin', 'بلد المنشأ'),
    VehicleField.exportCountry => tr('Country of export', 'بلد التصدير'),
    VehicleField.tariffCode => tr(
      'Tariff classification (HS code)',
      'التصنيف الجمركي (رمز HS)',
    ),
    VehicleField.importer => tr('Importer type', 'صفة المستورد'),
    VehicleField.use => tr('Import purpose', 'غرض الاستيراد'),
    VehicleField.residency => tr('Residency in Egypt', 'الإقامة في مصر'),
    VehicleField.regime => tr('Import regime', 'نظام الاستيراد'),
    VehicleField.temporaryDays => tr(
      'Expected temporary stay (days)',
      'مدة الاستيراد المؤقت المتوقعة (أيام)',
    ),
    VehicleField.preferenceProgram => tr(
      'Claimed agreement or programme',
      'الاتفاقية أو البرنامج محل الطلب',
    ),
    VehicleField.preference => tr(
      'Potential exemption or preference',
      'الإعفاء أو المعاملة التفضيلية المحتملة',
    ),
    VehicleField.documents => tr(
      'Supporting document status',
      'حالة المستندات الداعمة',
    ),
    VehicleField.assessmentDate => tr(
      'Assessment date (YYYY-MM-DD)',
      'تاريخ التقييم (YYYY-MM-DD)',
    ),
    VehicleField.purchase => tr('Purchase price', 'سعر الشراء'),
    VehicleField.currency => tr(
      'Currency for all amounts',
      'عملة جميع المبالغ',
    ),
    VehicleField.currencyCode => tr(
      'Currency code (3 letters)',
      'رمز العملة (٣ أحرف)',
    ),
    VehicleField.freight => tr('International freight', 'الشحن الدولي'),
    VehicleField.insurance => tr('Insurance', 'التأمين'),
    VehicleField.otherCosts => tr(
      'Other shipment costs',
      'تكاليف الشحنة الأخرى',
    ),
    VehicleField.handling => tr('Clearance and handling', 'التخليص والمناولة'),
    VehicleField.exchangeRate => tr(
      'Exchange rate (EGP per currency unit)',
      'سعر الصرف (جنيه لكل وحدة عملة)',
    ),
    VehicleField.exchangeSource => tr('Exchange-rate source', 'مصدر سعر الصرف'),
    VehicleField.exchangeDate => tr(
      'Exchange effective date (YYYY-MM-DD)',
      'تاريخ سريان سعر الصرف (YYYY-MM-DD)',
    ),
  };

  String option(Enum option) => switch (option) {
    VehicleCategory.passenger => tr('Passenger car', 'سيارة ملاكي'),
    VehicleCategory.commercial => tr('Commercial vehicle', 'مركبة تجارية'),
    VehicleCategory.truck => tr('Truck', 'شاحنة'),
    VehicleCategory.bus => tr('Bus', 'حافلة'),
    VehicleCategory.motorcycle => tr('Motorcycle', 'دراجة نارية'),
    VehicleCategory.other => tr('Other vehicle', 'مركبة أخرى'),
    VehicleCondition.newVehicle => tr('New', 'جديدة'),
    VehicleCondition.used => tr('Used', 'مستعملة'),
    Fuel.petrol => tr('Petrol', 'بنزين'),
    Fuel.diesel => tr('Diesel', 'ديزل'),
    Fuel.electric => tr('Electric', 'كهربائي'),
    Fuel.hybrid => tr('Hybrid', 'هجين'),
    ImporterKind.individual => tr('Individual', 'فرد'),
    ImporterKind.company => tr('Company', 'شركة'),
    ImportUse.personal => tr('Personal use', 'استخدام شخصي'),
    ImportUse.commercial => tr('Commercial import', 'استيراد تجاري'),
    Residency.resident => tr('Resident', 'مقيم'),
    Residency.nonResident => tr('Non-resident', 'غير مقيم'),
    Residency.unspecified => tr('Unspecified', 'غير محدد'),
    ImportRegime.standard => tr('Standard import', 'استيراد عادي'),
    ImportRegime.temporary => tr('Temporary import', 'استيراد مؤقت'),
    ImportRegime.preferential => tr(
      'Potential preferential treatment',
      'معاملة تفضيلية محتملة',
    ),
    ImportRegime.other => tr('Other or unsure', 'أخرى أو غير مؤكدة'),
    Currency.other => tr('Other currency', 'عملة أخرى'),
    Currency currency => currency.name.toUpperCase(),
    DocumentReadiness.ready => tr(
      'Available for specialist review',
      'متاحة لمراجعة المختص',
    ),
    DocumentReadiness.partial => tr(
      'Some documents available',
      'بعض المستندات متاحة',
    ),
    DocumentReadiness.unavailable => tr(
      'Documents pending',
      'المستندات قيد التجهيز',
    ),
    PreferenceClaim.none => tr('None indicated', 'لا يوجد'),
    PreferenceClaim.potentialExemption => tr(
      'Potential exemption',
      'إعفاء محتمل',
    ),
    PreferenceClaim.potentialPreference => tr(
      'Potential preference',
      'معاملة تفضيلية محتملة',
    ),
    PreferenceClaim.unsure => tr('Unsure', 'غير مؤكد'),
    VehicleScenario.unverified => tr(
      'My inputs · Legal verification required',
      'بياناتي · يلزم تحقق قانوني',
    ),
    VehicleScenario.eligible => tr('Demo · Eligible', 'مثال · مؤهل'),
    VehicleScenario.notEligible => tr('Demo · Not eligible', 'مثال · غير مؤهل'),
    VehicleScenario.conditional => tr(
      'Demo · Conditional with exempt duty',
      'مثال · مشروط مع إعفاء جمركي',
    ),
    VehicleScenario.missingRate => tr(
      'Demo · Missing duty rate',
      'مثال · نسبة جمركية مفقودة',
    ),
    _ => option.name,
  };

  String eligibility(EligibilityStatus status) => switch (status) {
    EligibilityStatus.eligible => tr('Eligible', 'مؤهل'),
    EligibilityStatus.notEligible => tr('Not eligible', 'غير مؤهل'),
    EligibilityStatus.conditional => tr(
      'Conditional eligibility',
      'أهلية مشروطة',
    ),
    EligibilityStatus.undetermined => tr(
      'Unable to determine',
      'يتعذر تحديد الأهلية',
    ),
  };

  String issue(AssessmentIssue issue) => switch (issue) {
    AssessmentIssue.noApplicableRule => tr(
      'Applicable eligibility rule or further legal verification.',
      'يلزم توفير قاعدة أهلية منطبقة أو إجراء تحقق قانوني إضافي.',
    ),
    AssessmentIssue.unverifiedRule => tr(
      'Source verification for the applicable rule.',
      'يلزم التحقق من مصدر القاعدة المنطبقة.',
    ),
    AssessmentIssue.confirmEvidence => tr(
      'Evidence to confirm the scenario conditions.',
      'يلزم تقديم أدلة تؤكد شروط السيناريو.',
    ),
  };

  String verification(Verification? status) => switch (status) {
    Verification.verified => tr('Verified source record', 'سجل مصدر موثّق'),
    Verification.synthetic => tr('Synthetic fixture', 'بيانات اصطناعية'),
    _ => tr('Legal verification required', 'يلزم تحقق قانوني'),
  };

  String document(SupportingDocument document) => switch (document) {
    SupportingDocument.purchaseEvidence => tr(
      'Purchase evidence',
      'مستند الشراء',
    ),
    SupportingDocument.vehicleSpecification => tr(
      'Vehicle specification evidence',
      'مستند مواصفات المركبة',
    ),
    SupportingDocument.originEvidence => tr(
      'Origin evidence',
      'مستند إثبات المنشأ',
    ),
    SupportingDocument.regimeEvidence => tr(
      'Regime evidence',
      'مستند النظام المختار',
    ),
  };

  String charge(Charge charge) => switch (charge) {
    Charge.duty => tr('Customs duty', 'الرسوم الجمركية'),
    Charge.development => tr('Development fee', 'رسم التنمية'),
    Charge.schedule => tr('Schedule tax', 'ضريبة الجدول'),
    Charge.vat => tr('VAT', 'ضريبة القيمة المضافة'),
    Charge.other => tr('Other applicable charges', 'رسوم أخرى منطبقة'),
  };

  String chargeStatus(ChargeStatus status) => switch (status) {
    ChargeStatus.rated => tr('Calculated', 'محسوبة'),
    ChargeStatus.zeroRated => tr('Zero-rated', 'بنسبة صفر'),
    ChargeStatus.exempt => tr('Exempt', 'معفاة'),
    ChargeStatus.unknown => tr('Unknown', 'غير معروفة'),
    ChargeStatus.notApplicable => tr('Not applicable', 'غير منطبقة'),
  };
}
