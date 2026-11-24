import '../domain/service_category.dart';

/// V4 section 5, pages 5–9. English text is a local translation.
class LocalCategoryRepository {
  const LocalCategoryRepository();

  List<ServiceCategory> get categories => _categories;
}

const _categories = <ServiceCategory>[
  ServiceCategory(
    id: 'CAT-01',
    slug: 'importers',
    nameAr: 'المستوردون',
    nameEn: 'Importers',
    descriptionAr:
        'بحث منتج ودولة وقطاع؛ تمييز مشترٍ محتمل عن مستورد مثبت من بلد بعينه؛ مصدر لكل ادعاء',
    descriptionEn:
        'Search by product, country and sector. Distinguish potential buyers from documented importers from a given country, with a source for each claim.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-02',
    slug: 'exporters',
    nameAr: 'المصدرون',
    nameEn: 'Exporters',
    descriptionAr:
        'ملفات شركات ومنتجات ومواصفات وأسواق؛ ربط بقطاعات متعددة؛ تواصل وفق الخصوصية',
    descriptionEn:
        'Company and product profiles, specifications and markets. Support multiple sectors and respect contact privacy.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-03',
    slug: 'cars-and-vehicles',
    nameAr: 'السيارات والمركبات',
    nameEn: 'Cars and Vehicles',
    descriptionAr:
        'ملاكي وكهرباء وهجين وتجاري وشاحنات وأوناش وجرارات زراعية ومعدات وموتوسيكلات؛ مسارات شخصي وتجاري ومؤقت ومبادرات موثقة',
    descriptionEn:
        'Passenger, electric, hybrid and commercial vehicles, trucks, cranes, agricultural tractors, equipment and motorcycles. Cover personal, commercial and temporary import pathways and documented initiatives.',
    type: CategoryType.journey,
    futureCapability: CategoryCapability(
      nameAr: 'حاسبة استيراد المركبات',
      nameEn: 'Vehicle import calculator',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-04',
    slug: 'insurance',
    nameAr: 'التأمين',
    nameEn: 'Insurance',
    descriptionAr:
        'جهات ونطاق جغرافي وتغطية مستندة إلى مصدر؛ طلب عرض؛ لا وصف شحنة بأنها مؤمنة دون وثيقة',
    descriptionEn:
        'Providers, geographic scope and source-backed coverage. Quote requests require a provider, and insured status requires a policy.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-05',
    slug: 'inspection-monitoring-and-quality',
    nameAr: 'الفحص والمتابعة والجودة',
    nameEn: 'Inspection, Monitoring and Quality',
    descriptionAr:
        'جهات وخدمات وشهادات وصلاحية بياناتها؛ التفريق بين فحص واعتماد وشهادة',
    descriptionEn:
        'Providers, services, certificates and data validity. Distinguish inspection, accreditation and certification.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-06',
    slug: 'exporter-support-organizations',
    nameAr: 'الهيئات الداعمة للمصدرين',
    nameEn: 'Exporter Support Organizations',
    descriptionAr:
        'مجالس وهيئات وغرف وتمويل ودعم وشهادات؛ شروط وروابط رسمية ومراجعة دورية',
    descriptionEn:
        'Councils, authorities, chambers, funding, support and certificates. Include eligibility, official links and periodic review.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-07',
    slug: 'customs-yards-and-warehouses',
    nameAr: 'الساحات والمخازن الجمركية',
    nameEn: 'Customs Yards and Warehouses',
    descriptionAr:
        'الموقع ونوع الترخيص والخدمات والجهة المشغلة؛ يشمل روابط مخازن عامة وحرة وجافة؛ لا سعة حية مفترضة',
    descriptionEn:
        'Location, license type, services and operator. Include links for public, free-zone and dry warehouses. Live capacity requires a source.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-08',
    slug: 'domestic-transport',
    nameAr: 'النقل الداخلي',
    nameEn: 'Domestic Transport',
    descriptionAr:
        'معدات وتغطية واستلام وتسليم ونقل مبرد وثقيل؛ تختلف عن مسارات النقل الدولي بالقسم 11',
    descriptionEn:
        'Equipment, coverage, pickup, delivery, refrigerated and heavy haulage. International routes belong to CAT-11.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-09',
    slug: 'shipping-lines-and-vessels',
    nameAr: 'الخطوط الملاحية والسفن',
    nameEn: 'Shipping Lines and Vessels',
    descriptionAr:
        'دليل خط ووكيل وموانئ؛ فرع وساطة وتأجير سفن وبضائع صب؛ الجداول من مصدر مؤرخ',
    descriptionEn:
        'Shipping lines, agents and ports. Cover ship brokerage, chartering and bulk cargo. Schedules require a dated source.',
    type: CategoryType.directory,
    futureCapability: CategoryCapability(
      nameAr: 'جداول الملاحة',
      nameEn: 'Shipping schedules',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-10',
    slug: 'airlines-and-air-cargo',
    nameAr: 'شركات الطيران والشحن الجوي',
    nameEn: 'Airlines and Air Cargo',
    descriptionAr:
        'شركات و GSA ومناولة وتأجير طائرات شحن؛ البحث العام مفتوح والوظائف المهنية الحساسة بصلاحيات',
    descriptionEn:
        'Airlines, general sales agents, handling and cargo aircraft chartering. Public search and permission-controlled professional functions.',
    type: CategoryType.directory,
    futureCapability: CategoryCapability(
      nameAr: 'تكامل الشحن الجوي',
      nameEn: 'Air cargo integration',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-11',
    slug: 'international-road-transport',
    nameAr: 'النقل البري الدولي',
    nameEn: 'International Road Transport',
    descriptionAr:
        'مسارات وحدود ومعدات وخدمات وطلبات أسعار؛ مرشحات تبريد و FTL و LTL',
    descriptionEn:
        'Routes, borders, equipment, services and quote requests. Filters cover refrigerated, full truckload and less than truckload.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-12',
    slug: 'freight-forwarders',
    nameAr: 'وكلاء الشحن',
    nameEn: 'Freight Forwarders',
    descriptionAr:
        'بحري وجوي وبري ومتعدد الوسائط وتخصصات ومناطق؛ عضويات وتراخيص بأدلتها',
    descriptionEn:
        'Sea, air, road and multimodal forwarding, specialties and regions. Memberships and licenses require evidence.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-13',
    slug: 'express-shipping-and-post',
    nameAr: 'الشحن السريع والبريد',
    nameEn: 'Express Shipping and Post',
    descriptionAr:
        'طرود وتغطية وقيود منشورة؛ الحاسبة والتتبع حسب المزود المرخص',
    descriptionEn:
        'Parcels, coverage and published restrictions. Calculations and tracking depend on authorized providers.',
    type: CategoryType.directory,
    futureCapability: CategoryCapability(
      nameAr: 'تكامل الحاسبة والتتبع',
      nameEn: 'Calculator and tracking integration',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-14',
    slug: 'commercial-representation',
    nameAr: 'التمثيل التجاري',
    nameEn: 'Commercial Representation',
    descriptionAr:
        'دولة وسفارة وقنصلية ومكتب تجاري ووسائل اتصال رسمية؛ ليس انتماء أو اعتمادا للمنصة',
    descriptionEn:
        'Countries, embassies, consulates, trade offices and official contacts. Directory inclusion conveys no affiliation or accreditation.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-15',
    slug: 'exhibitions-and-events',
    nameAr: 'المعارض والفعاليات',
    nameEn: 'Exhibitions and Events',
    descriptionAr:
        'تخصص وبلد ومنظم وتاريخ ومنطقة زمنية وروابط؛ تمييز مؤكد ومؤجل ومنتهي',
    descriptionEn:
        'Specialty, country, organizer, date, time zone and links. Distinguish confirmed, postponed and past events.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-16',
    slug: 'containers-containerization-and-stowage',
    nameAr: 'الحاويات والتحوية والرص',
    nameEn: 'Containers, Containerization and Stowage',
    descriptionAr:
        'معدات و CBM ووزن وقابلية رص وأبعاد أبواب؛ تصور 3D وتحسين توزيع لاحقا؛ السعة الحجمية لا تثبت صلاحية الرص',
    descriptionEn:
        'Equipment, volume, weight, stackability and door dimensions. 3D previews and distribution optimization come later. Volume alone cannot establish load fit.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'تحسين توزيع الحمولة',
      nameEn: 'Load distribution optimization',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-17',
    slug: 'customs-clearance',
    nameAr: 'التخليص الجمركي',
    nameEn: 'Customs Clearance',
    descriptionAr:
        'جهات وتخصصات ومنافذ وترخيص وتاريخ مراجعة؛ لا تفويض تلقائي من المنصة',
    descriptionEn:
        'Providers, specialties, border points, licenses and review dates. Authorization requires a separate process.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-18',
    slug: 'packaging-and-supporting-equipment',
    nameAr: 'التعبئة والتغليف والمعدات المساندة',
    nameEn: 'Packaging and Supporting Equipment',
    descriptionAr:
        'كراتين وطبالي وبراميل وتثبيت وتحميل وتفريغ وأجهزة تسجيل حرارة؛ مواصفات وموردون',
    descriptionEn:
        'Cartons, pallets, drums, securing, loading, unloading and temperature loggers. Include specifications and suppliers.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-19',
    slug: 'customs-platforms-and-procedures',
    nameAr: 'المنصات والإجراءات الجمركية',
    nameEn: 'Customs Platforms and Procedures',
    descriptionAr:
        'بوابات رسمية حسب الدولة والعملية وروابط وإرشاد؛ API فقط إذا متاح ومصرح',
    descriptionEn:
        'Official portals by country and procedure, with links and guidance. Integrations require availability and authorization.',
    type: CategoryType.reference,
  ),
  ServiceCategory(
    id: 'CAT-20',
    slug: 'intelligent-trade-and-logistics-advisor',
    nameAr: 'المستشار التجاري واللوجستي الذكي',
    nameEn: 'Intelligent Trade and Logistics Advisor',
    descriptionAr:
        'بحث مرجعي موثق ومساعدة صياغة وتجهيز طلب؛ تحويل لخبير عند نقص الأدلة',
    descriptionEn:
        'Source-backed reference search and help drafting and preparing requests. Refer to an expert when evidence is insufficient.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'المساعدة بالذكاء الاصطناعي',
      nameEn: 'AI assistance',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-21',
    slug: 'personal-baggage-and-relocation',
    nameAr: 'الأمتعة الشخصية والانتقال',
    nameEn: 'Personal Baggage and Relocation',
    descriptionAr:
        'أمتعة ومسافرون ونقل مقتنيات؛ قواعد حسب الدولة والتاريخ؛ النقد والمحظورات من مرجع رسمي',
    descriptionEn:
        'Baggage, travelers and moving belongings. Rules depend on country and date, with official references for cash and prohibited items.',
    type: CategoryType.journey,
  ),
  ServiceCategory(
    id: 'CAT-22',
    slug: 'special-imports-and-non-standard-shipments',
    nameAr: 'الاستيراد الخاص والشحنات غير النمطية',
    nameEn: 'Special Imports and Non-Standard Shipments',
    descriptionAr:
        'مؤقت ومشروعات ومعارض ومعدات كبيرة وحالات تتطلب مراجعة؛ الاسم لا يحدد معاملة جمركية تلقائية',
    descriptionEn:
        'Temporary imports, projects, exhibitions, oversized equipment and cases needing review. Customs treatment requires individual assessment.',
    type: CategoryType.journey,
    futureCapability: CategoryCapability(
      nameAr: 'مسار الاستيراد الخاص',
      nameEn: 'Special import workflow',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-23',
    slug: 'personal-imports-and-e-commerce',
    nameAr: 'الاستيراد الشخصي والتجارة الإلكترونية',
    nameEn: 'Personal Imports and E-Commerce',
    descriptionAr:
        'خطوات ووثائق وحدود منشورة حسب الوجهة؛ تمييز التجاري عن الشخصي دون وعود إعفاء',
    descriptionEn:
        'Published steps, documents and limits by destination. Distinguish commercial and personal imports without promising exemptions.',
    type: CategoryType.journey,
  ),
  ServiceCategory(
    id: 'CAT-24',
    slug: 'jobs-and-expertise',
    nameAr: 'الوظائف والخبرات',
    nameEn: 'Jobs and Expertise',
    descriptionAr:
        'مدخل بدور على شغل ومدخل بطلب موظفين؛ مبيعات وتشغيل وتخليص وسائقون ومخازن ومحاسبة وترجمة وقانون وتقنية',
    descriptionEn:
        'Paths for job seekers and employers. Cover sales, operations, clearance, drivers, warehousing, accounting, translation, law and technology.',
    type: CategoryType.journey,
  ),
  ServiceCategory(
    id: 'CAT-25',
    slug: 'time-and-meetings',
    nameAr: 'التوقيت والاجتماعات',
    nameEn: 'Time and Meetings',
    descriptionAr:
        'ساعات مدن وتداخل العمل وتوقيت صيفي؛ مواعيد بروابط اجتماعات لاحقا',
    descriptionEn:
        'City clocks, overlapping work hours and daylight saving time. Meeting links and scheduling are future capabilities.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'تقويم الاجتماعات',
      nameEn: 'Meeting calendar',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-26',
    slug: 'currencies-and-financial-information',
    nameAr: 'العملات والمعلومات المالية',
    nameEn: 'Currencies and Financial Information',
    descriptionAr:
        'تحويل مؤرخ بمصدر؛ تمييز مرجعي عن سعر بنك وتنفيذ؛ المعادن امتداد اختياري',
    descriptionEn:
        'Dated conversions with a source. Distinguish reference values, bank rates and transaction rates. Metals are optional.',
    type: CategoryType.tool,
  ),
  ServiceCategory(
    id: 'CAT-27',
    slug: 'shipping-costs-and-quote-requests',
    nameAr: 'تكلفة الشحن وطلبات الأسعار',
    nameEn: 'Shipping Costs and Quote Requests',
    descriptionAr:
        'FCL و LCL وجوي وبري وسيارات؛ حاسبة مدخلات ثم تقدير موثق أو RFQ؛ مقارنة نطاقات متكافئة',
    descriptionEn:
        'Full and less-than-container loads, air, road and vehicles. Shipment inputs support a documented estimate or quote request. Compare like scopes.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'تقدير تكلفة الشحن',
      nameEn: 'Shipping cost estimation',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-28',
    slug: 'trade-terms-and-payment-methods',
    nameAr: 'شروط التجارة وطرق السداد',
    nameEn: 'Trade Terms and Payment Methods',
    descriptionAr:
        'Incoterms ومكان مسمى وإصدار، و L/C و CAD والتحصيل والتحويل؛ شرح أصلي وروابط مع احترام الحقوق',
    descriptionEn:
        'Incoterms with a named place and edition, plus letters of credit, cash against documents, collection and transfers. Provide original explanations and rights-respecting links.',
    type: CategoryType.reference,
  ),
  ServiceCategory(
    id: 'CAT-29',
    slug: 'shipment-and-container-tracking',
    nameAr: 'تتبع الشحنات والحاويات',
    nameEn: 'Shipment and Container Tracking',
    descriptionAr:
        'روابط جهات أصلية ثم تكامل مصرح؛ حاوية وبوليصة و AWB وطرود؛ آخر حدث ومصدر ووقت',
    descriptionEn:
        'Original provider links and authorized integrations for containers, bills of lading, air waybills and parcels. Show the latest event, source and time.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'تكامل التتبع',
      nameEn: 'Tracking integration',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-30',
    slug: 'carbon-footprint-and-cbam',
    nameAr: 'البصمة الكربونية و CBAM',
    nameEn: 'Carbon Footprint and CBAM',
    descriptionAr:
        'فصل انبعاثات النقل عن الانبعاثات المضمنة للسلع؛ مصدر ومنهج وفترة وحدود؛ لا إقرار امتثال آلي',
    descriptionEn:
        'Distinguish transport emissions from embedded goods emissions. Record source, methodology, period and boundaries. Compliance claims require assessment.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'حساب الانبعاثات',
      nameEn: 'Emissions calculation',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-31',
    slug: 'customs-taxes-and-landed-cost',
    nameAr: 'الجمارك والضرائب والتكلفة الواصلة',
    nameEn: 'Customs, Taxes and Landed Cost',
    descriptionAr:
        'سلع وسيارات حسب الدولة والتصنيف والمنشأ والتقييم والتاريخ؛ حساب جزئي صريح عند نقص البيانات',
    descriptionEn:
        'Goods and vehicles by country, classification, origin, valuation and date. Clearly label any partial calculation when inputs are missing.',
    type: CategoryType.tool,
    futureCapability: CategoryCapability(
      nameAr: 'قواعد حساب الجمارك والضرائب والتكلفة الواصلة',
      nameEn: 'Customs, tax and landed-cost calculation rules',
      phase: CategoryPhase.p2,
    ),
  ),
  ServiceCategory(
    id: 'CAT-32',
    slug: 'export-opportunities-purchase-requests-and-markets',
    nameAr: 'فرص التصدير وطلبات الشراء والأسواق',
    nameEn: 'Export Opportunities, Purchase Requests and Markets',
    descriptionAr:
        'فرص مؤرخة وموثقة وطلبات أعضاء موسومة ومطابقة منتج ودولة؛ انتهاء وصلاحية مصدر',
    descriptionEn:
        'Dated, documented opportunities and labeled member requests. Match products and countries and show expiration and source validity.',
    type: CategoryType.directory,
  ),
  ServiceCategory(
    id: 'CAT-33',
    slug: 'dangerous-goods-and-special-shipments',
    nameAr: 'البضائع الخطرة والشحنات الخاصة',
    nameEn: 'Dangerous Goods and Special Shipments',
    descriptionAr:
        'مرجع UN وتصنيف ومخاطر و SDS وحيوانات حية وقابل للتلف حسب تخصص مستقل؛ مراجعة بشرية؛ لا تصريح شحن',
    descriptionEn:
        'UN reference, classification, risks and safety data sheets. Treat live animals and perishables as separate specialties. Human review is required for shipment decisions.',
    type: CategoryType.reference,
    futureCapability: CategoryCapability(
      nameAr: 'محرك البضائع الخطرة المرخّص',
      nameEn: 'Licensed dangerous-goods engine',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-34',
    slug: 'cold-chain-and-cargo-temperature',
    nameAr: 'سلسلة التبريد وحرارة البضائع',
    nameEn: 'Cold Chain and Cargo Temperature',
    descriptionAr:
        'مخازن ونقل ومعدات ومتطلبات سلعة و SOP؛ فروق setpoint وحرارة المنتج؛ تسجيل حرارة بتكامل لاحق',
    descriptionEn:
        'Warehouses, transport, equipment, commodity requirements and procedures. Distinguish setpoint and product temperature. Temperature logging requires future integration.',
    type: CategoryType.directory,
    futureCapability: CategoryCapability(
      nameAr: 'تكامل أجهزة تسجيل الحرارة',
      nameEn: 'Temperature logger integration',
      phase: CategoryPhase.p3,
    ),
  ),
  ServiceCategory(
    id: 'CAT-35',
    slug: 'academy-library-and-consulting',
    nameAr: 'الأكاديمية والمكتبة والاستشارات',
    nameEn: 'Academy, Library and Consulting',
    descriptionAr:
        'تعليم مجاني وسلاسل ومصطلحات ومستندات تدريبية وخبراء؛ ربط قناة المالك بعد تأكيد الرابط',
    descriptionEn:
        'Free learning, series, terminology, training documents and experts. Link the owner’s channel once confirmed.',
    type: CategoryType.reference,
  ),
];
