import '../../../core/localization/app_copy.dart';
import '../domain/freight_rules.dart';
import '../domain/incoterms.dart';
import '../domain/shipment.dart';
import 'trade_cubit.dart';

class TradeCopy {
  const TradeCopy(this.app);
  final AppCopy app;
  String tr(String en, String ar) => app.isArabic ? ar : en;
  String get title => tr('Trade cost calculator', 'حاسبة تكاليف التجارة');
  String get demo => tr(
    'Synthetic example. Amounts and carrier assumptions are fictional.',
    'مثال اصطناعي. المبالغ وافتراضات الناقل خيالية.',
  );
  String get notice => tr(
    'Local estimates use the amounts and carrier rules you enter. Confirm charges, contract terms and taxes with your providers.',
    'تعتمد التقديرات المحلية على المبالغ وقواعد الناقل التي تدخلها. تحقّق من الرسوم وشروط العقد والضرائب مع مزودي الخدمة.',
  );

  String step(TradeStep value) => switch (value) {
    TradeStep.shipment => tr('Shipment details', 'بيانات الشحنة'),
    TradeStep.freight => tr('Freight and carrier rules', 'الشحن وقواعد الناقل'),
    TradeStep.costs => tr('Costs and currency', 'التكاليف والعملة'),
    TradeStep.review => tr('Review inputs', 'مراجعة المدخلات'),
    TradeStep.result => tr('Calculation results', 'نتائج الحساب'),
  };

  String option(Enum value) => switch (value) {
    TradeMode.landed => tr('Import landed cost', 'التكلفة الواصلة للاستيراد'),
    TradeMode.export => tr(
      'Export pricing and profitability',
      'تسعير التصدير والربحية',
    ),
    TradeMode.freight => tr('Freight cost estimate', 'تقدير تكلفة الشحن'),
    Transport.sea => tr('Sea', 'بحري'),
    Transport.air => tr('Air', 'جوي'),
    Transport.road => tr('Road', 'بري'),
    SeaLoad.fcl => tr('FCL · Full container', 'FCL · حاوية كاملة'),
    SeaLoad.lcl => tr('LCL · Shared container', 'LCL · شحن مجمّع'),
    PriceGoal.margin => tr(
      'Margin · Profit as a share of selling price',
      'الهامش · الربح كنسبة من سعر البيع',
    ),
    PriceGoal.markup => tr(
      'Markup · Profit as a share of cost',
      'الزيادة · الربح كنسبة من التكلفة',
    ),
    Treatment.additional => tr('Add separately', 'أضف كبند منفصل'),
    Treatment.included => tr(
      'Already included in a counted amount',
      'مدرج في مبلغ محسوب',
    ),
    Treatment.excluded => tr(
      'Outside scope or not incurred',
      'خارج النطاق أو غير متكبد',
    ),
    Provenance.entered => tr('User-entered', 'من إدخال المستخدم'),
    Provenance.synthetic => tr('Synthetic', 'اصطناعي'),
    Provenance.verified => tr('Verified provider', 'مصدر موثّق'),
    Provenance.unavailable => tr('Unavailable', 'غير متاح'),
    _ => value.name.toUpperCase(),
  };

  String field(Field field, Shipment shipment) => switch (field) {
    Field.product => tr('Product description', 'وصف المنتج'),
    Field.hs => tr('HS code', 'رمز النظام المنسق'),
    Field.origin => tr('Country of origin', 'بلد المنشأ'),
    Field.destination => tr('Destination country', 'بلد الوجهة'),
    Field.departure =>
      shipment.transport == Transport.road
          ? tr('Pickup location', 'نقطة الاستلام')
          : tr('Origin port or airport', 'ميناء أو مطار الانطلاق'),
    Field.arrival =>
      shipment.transport == Transport.road
          ? tr('Delivery location', 'نقطة التسليم')
          : tr('Destination port or airport', 'ميناء أو مطار الوجهة'),
    Field.currency => tr(
      'Shipment currency (e.g. USD)',
      'عملة الشحنة (مثل USD)',
    ),
    Field.quantity => tr('Product quantity', 'كمية المنتج'),
    Field.unit => tr('Unit of measurement', 'وحدة القياس'),
    Field.unitPrice => tr('Unit price', 'سعر الوحدة'),
    Field.invoice => tr(
      'Total cargo or invoice value',
      'إجمالي قيمة البضاعة أو الفاتورة',
    ),
    Field.gross => tr('Gross weight (kg)', 'الوزن الإجمالي (كجم)'),
    Field.net => tr('Net weight (kg)', 'الوزن الصافي (كجم)'),
    Field.packages => tr('Package count', 'عدد الطرود'),
    Field.length => tr('Length per package (cm)', 'طول الطرد (سم)'),
    Field.width => tr('Width per package (cm)', 'عرض الطرد (سم)'),
    Field.height => tr('Height per package (cm)', 'ارتفاع الطرد (سم)'),
    Field.volume => tr('Total shipment volume (CBM)', 'إجمالي حجم الشحنة (م³)'),
    Field.cargoType => tr('Cargo type', 'نوع البضاعة'),
    Field.handlingNotes => tr(
      'Special handling requirements',
      'متطلبات المناولة الخاصة',
    ),
    Field.namedPlace => tr(
      'Incoterm named place or port',
      'المكان أو الميناء المحدد لشرط التجارة',
    ),
    Field.carrierNote => tr(
      'Carrier rule source or reference',
      'مصدر أو مرجع قاعدة الناقل',
    ),
    Field.container => tr('Container type', 'نوع الحاوية'),
    Field.containers => tr('Container count', 'عدد الحاويات'),
    Field.divisor => tr(
      'Carrier volumetric divisor (cm³/kg)',
      'معامل الوزن الحجمي للناقل (سم³/كجم)',
    ),
    Field.lclKg => tr(
      'Carrier kg per W/M unit',
      'كجم لكل وحدة وزن أو قياس لدى الناقل',
    ),
    Field.increment => tr(
      'Carrier billing increment',
      'وحدة التقريب المحاسبي لدى الناقل',
    ),
    Field.minimum => tr(
      'Minimum base charge',
      'الحد الأدنى لأجرة الشحن الأساسية',
    ),
    Field.roadVehicle => tr('Vehicle type', 'نوع المركبة'),
    Field.distance => tr('Distance (km)', 'المسافة (كم)'),
    Field.rate =>
      shipment.transport == Transport.road
          ? tr('Entered road transport charge', 'أجرة النقل البري المدخلة')
          : shipment.transport == Transport.air
          ? tr('Rate per chargeable kg', 'السعر لكل كجم محاسبي')
          : shipment.seaLoad == SeaLoad.fcl
          ? tr('Rate per container', 'السعر لكل حاوية')
          : tr('Rate per W/M unit', 'السعر لكل وحدة وزن أو قياس'),
    Field.surcharge => tr('Total surcharges', 'إجمالي الرسوم الإضافية'),
    Field.valuation => tr(
      'Customs valuation (reference basis)',
      'القيمة الجمركية (أساس مرجعي)',
    ),
    Field.goal => tr(
      'Desired profit percentage (%)',
      'نسبة الربح المطلوبة (%)',
    ),
    Field.quoteCurrency => tr(
      'Conversion target currency',
      'العملة المستهدفة للتحويل',
    ),
    Field.fx => tr(
      'Target currency per shipment currency unit',
      'وحدات العملة المستهدفة لكل وحدة من عملة الشحنة',
    ),
    Field.fxSource => tr('Exchange-rate source', 'مصدر سعر الصرف'),
    Field.fxDate => tr(
      'Exchange-rate effective date (YYYY-MM-DD)',
      'تاريخ سريان سعر الصرف (YYYY-MM-DD)',
    ),
  };

  String cost(Cost cost) => switch (cost) {
    Cost.origin => tr('Origin charges', 'رسوم المنشأ'),
    Cost.freight => tr('International freight', 'الشحن الدولي'),
    Cost.insurance => tr('Insurance', 'التأمين'),
    Cost.duty => tr('Customs duties', 'الرسوم الجمركية'),
    Cost.taxes => tr('Taxes and fees', 'الضرائب والرسوم'),
    Cost.terminal => tr('Port or airport handling', 'مناولة الميناء أو المطار'),
    Cost.clearance => tr('Customs clearance', 'التخليص الجمركي'),
    Cost.storageInspection => tr('Storage and inspection', 'التخزين والفحص'),
    Cost.inland => tr('Inland transport', 'النقل الداخلي'),
    Cost.bank => tr('Banking and commissions', 'المصاريف البنكية والعمولات'),
    Cost.other => tr('Other expenses', 'نفقات أخرى'),
    Cost.production => tr('Acquisition or manufacturing', 'الشراء أو التصنيع'),
    Cost.packaging => tr('Packaging and labeling', 'التعبئة ووضع الملصقات'),
    Cost.certification => tr('Inspection and certification', 'الفحص والشهادات'),
    Cost.exportDocuments => tr(
      'Export clearance and documentation',
      'تخليص التصدير والمستندات',
    ),
  };

  String freightInput(FreightInput value, Shipment shipment) =>
      field(switch (value) {
        FreightInput.rate => Field.rate,
        FreightInput.surcharge => Field.surcharge,
        FreightInput.containers => Field.containers,
        FreightInput.divisor => Field.divisor,
        FreightInput.gross => Field.gross,
        FreightInput.volume => Field.volume,
        FreightInput.lclKg => Field.lclKg,
        FreightInput.increment => Field.increment,
        FreightInput.minimum => Field.minimum,
      }, shipment);

  String issue(InputIssue issue) => switch (issue) {
    InputIssue.required => tr('Required.', 'مطلوب.'),
    InputIssue.numeric => tr(
      'Enter a non-negative decimal, without grouping separators.',
      'أدخل رقمًا عشريًا غير سالب دون فواصل الآلاف.',
    ),
    InputIssue.positive => tr(
      'Enter a value above zero.',
      'أدخل قيمة أكبر من صفر.',
    ),
    InputIssue.whole => tr('Enter a whole number.', 'أدخل عددًا صحيحًا.'),
    InputIssue.currency => tr(
      'Enter a three-letter currency code. For conversion, choose a different currency.',
      'أدخل رمز عملة من ثلاثة أحرف. اختر عملة مختلفة للتحويل.',
    ),
    InputIssue.netWeight => tr(
      'Net weight cannot exceed gross weight.',
      'لا يمكن أن يتجاوز الوزن الصافي الوزن الإجمالي.',
    ),
    InputIssue.dimensions => tr(
      'Enter all three dimensions and package count.',
      'أدخل الأبعاد الثلاثة وعدد الطرود.',
    ),
    InputIssue.term => tr(
      'Choose an Incoterm compatible with transport.',
      'اختر شرط تجارة متوافقًا مع وسيلة النقل.',
    ),
    InputIssue.margin => tr(
      'Margin must be below 100%.',
      'يجب أن يقل هامش الربح عن 100٪.',
    ),
    InputIssue.date => tr(
      'Enter a valid date in YYYY-MM-DD format.',
      'أدخل تاريخًا صحيحًا بصيغة YYYY-MM-DD.',
    ),
  };

  String transportScope(Incoterm term) => term.waterwayOnly
      ? tr('Sea and inland waterways', 'النقل البحري والممرات المائية الداخلية')
      : tr('Any transport mode', 'جميع وسائل النقل');

  String allocation(Incoterm term) => switch (term) {
    Incoterm.exw => tr(
      'Buyer arranges pickup, carriage and clearance. Seller makes goods available at the named location.',
      'يرتب المشتري الاستلام والنقل والتخليص. يتيح البائع البضاعة في المكان المحدد.',
    ),
    Incoterm.fca => tr(
      'Seller clears export and delivers to the buyer’s appointed carrier at the named place. Buyer arranges main carriage.',
      'يخلص البائع البضاعة للتصدير ويسلمها لناقل المشتري في المكان المحدد. يرتب المشتري النقل الرئيسي.',
    ),
    Incoterm.fas => tr(
      'Seller clears export and brings goods alongside the vessel. Buyer arranges loading and sea freight.',
      'يخلص البائع البضاعة للتصدير ويوصلها بجانب السفينة. يرتب المشتري التحميل والشحن البحري.',
    ),
    Incoterm.fob => tr(
      'Seller clears export and loads the vessel. Buyer arranges sea freight.',
      'يخلص البائع البضاعة للتصدير ويحملها على السفينة. يرتب المشتري الشحن البحري.',
    ),
    Incoterm.cpt || Incoterm.cfr => tr(
      'Seller arranges and pays carriage to the named destination. Buyer handles import clearance and any insurance it needs.',
      'يرتب البائع النقل ويدفعه إلى الوجهة المحددة. يتولى المشتري تخليص الاستيراد وأي تأمين يحتاجه.',
    ),
    Incoterm.cip || Incoterm.cif => tr(
      'Seller pays carriage to the named destination and arranges insurance. Buyer handles import clearance.',
      'يدفع البائع أجرة النقل إلى الوجهة المحددة ويرتب التأمين. يتولى المشتري تخليص الاستيراد.',
    ),
    Incoterm.dap => tr(
      'Seller takes goods to the named destination. Buyer unloads and clears import.',
      'يوصل البائع البضاعة إلى الوجهة المحددة. يفرغ المشتري البضاعة ويخلصها للاستيراد.',
    ),
    Incoterm.dpu => tr(
      'Seller delivers and unloads at the named destination. Buyer clears import.',
      'يسلم البائع البضاعة ويفرغها في الوجهة المحددة. يتولى المشتري تخليص الاستيراد.',
    ),
    Incoterm.ddp => tr(
      'Seller funds delivery and import clearance, including applicable import duties. Buyer unloads.',
      'يتحمل البائع تكاليف التسليم وتخليص الاستيراد بما فيها الرسوم المنطبقة. يتولى المشتري التفريغ.',
    ),
  };

  String risk(Incoterm term) => switch (term) {
    Incoterm.exw => tr(
      'When goods are made available at the agreed place, before loading.',
      'عند إتاحة البضاعة في المكان المتفق عليه قبل التحميل.',
    ),
    Incoterm.fca => tr(
      'When delivery to the buyer’s carrier occurs at the agreed point.',
      'عند التسليم إلى ناقل المشتري في النقطة المتفق عليها.',
    ),
    Incoterm.cpt || Incoterm.cip => tr(
      'At handover to the carrier at the agreed delivery point.',
      'عند التسليم للناقل في نقطة التسليم المتفق عليها.',
    ),
    Incoterm.fas => tr(
      'When goods are positioned alongside the vessel at the shipment port.',
      'عند وضع البضاعة بجانب السفينة في ميناء الشحن.',
    ),
    Incoterm.fob || Incoterm.cfr || Incoterm.cif => tr(
      'When goods are on board at the shipment port.',
      'عند وجود البضاعة على متن السفينة في ميناء الشحن.',
    ),
    Incoterm.dap || Incoterm.ddp => tr(
      'At the named destination with the goods available for unloading.',
      'في الوجهة المحددة عند إتاحة البضاعة للتفريغ.',
    ),
    Incoterm.dpu => tr(
      'After unloading at the named destination.',
      'بعد التفريغ في الوجهة المحددة.',
    ),
  };
}
