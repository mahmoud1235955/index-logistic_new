import 'package:flutter/widgets.dart';

import '../../features/directory/domain/company.dart';
import '../../features/home/domain/home_entry_point.dart';
import '../state/app_view_state.dart';

enum AppLanguage {
  english('en'),
  arabic('ar', countryCode: 'EG'),
  french('fr'),
  italian('it'),
  hindi('hi'),
  chinese('zh', scriptCode: 'Hans');

  const AppLanguage(this.languageCode, {this.countryCode, this.scriptCode});
  final String languageCode;
  final String? countryCode;
  final String? scriptCode;
  Locale get locale => Locale.fromSubtags(
    languageCode: languageCode,
    scriptCode: scriptCode,
    countryCode: countryCode,
  );
}

class AppCopy {
  const AppCopy(this.language);
  final AppLanguage language;
  bool get isArabic => language == AppLanguage.arabic;
  String get homeLoading => isArabic
      ? '\u062c\u0627\u0631\u064d \u062a\u062d\u0645\u064a\u0644 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0645\u0639\u0627\u064a\u0646\u0629...'
      : 'Loading preview content...';
  String get homeEmpty => isArabic
      ? '\u0644\u0627 \u062a\u0648\u062c\u062f \u0628\u064a\u0627\u0646\u0627\u062a \u0645\u0639\u0627\u064a\u0646\u0629 \u0645\u062a\u0627\u062d\u0629.'
      : 'No preview content available.';
  String get homeLoadError => isArabic
      ? '\u062a\u0639\u0630\u0631 \u062a\u062d\u0645\u064a\u0644 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0645\u0639\u0627\u064a\u0646\u0629.'
      : 'Unable to load preview content.';
  String stateTitle(AppViewState state) => switch (state) {
    AppViewState.loading => isArabic ? 'جارٍ التحميل' : 'Loading',
    AppViewState.empty =>
      isArabic ? 'لا توجد بيانات للعرض' : 'Nothing to show yet',
    AppViewState.error =>
      isArabic ? 'تعذر تحميل المعاينة' : 'Preview could not load',
    AppViewState.offline =>
      isArabic ? 'حالة معاينة دون اتصال' : 'Offline preview state',
    AppViewState.expired =>
      isArabic ? 'انتهت صلاحية المعاينة' : 'Preview expired',
    AppViewState.permissionDenied =>
      isArabic ? 'الصلاحية غير متاحة' : 'Permission unavailable',
  };
  String stateMessage(AppViewState state) => switch (state) {
    AppViewState.loading =>
      isArabic
          ? 'جارٍ تحميل بيانات العرض المحلية.'
          : 'Loading local preview data.',
    AppViewState.empty =>
      isArabic
          ? 'لا توجد عناصر مطابقة للعرض الآن.'
          : 'There is nothing available to display right now.',
    AppViewState.error =>
      isArabic
          ? 'لم نتمكن من إكمال عملية التحميل المحلية. يمكنك المحاولة مرة أخرى.'
          : 'The local preview could not finish loading. You can try again.',
    AppViewState.offline =>
      isArabic
          ? 'هذه حالة عرض توضيحية؛ لا توجد خدمة متصلة لتحميل محتوى مباشر.'
          : 'This is a preview state; no service is connected to load live content.',
    AppViewState.expired =>
      isArabic
          ? 'هذه المعاينة المحلية معلّمة بأنها منتهية. ارجع إلى الرئيسية للمتابعة.'
          : 'This local preview is marked expired. Return Home to continue.',
    AppViewState.permissionDenied =>
      isArabic
          ? 'هذه حالة توضيحية لصلاحية مرفوضة. لم تطلب المعاينة أي صلاحية.'
          : 'This demonstrates a permission-denied state. The preview did not request a permission.',
  };
  String stateAction(AppViewState state) => switch (state) {
    AppViewState.loading => '',
    AppViewState.empty => isArabic ? 'استكشف القطاعات' : 'Explore sectors',
    AppViewState.error || AppViewState.offline => retryPreview,
    AppViewState.expired || AppViewState.permissionDenied => homeLabel,
  };
  String get retryPreview => isArabic ? 'إعادة المحاولة' : 'Try again';
  String get clearSearch => isArabic ? 'مسح البحث' : 'Clear search';
  String get exploreSectors => isArabic ? 'استكشف القطاعات' : 'Explore sectors';
  String get noCompanies => isArabic
      ? 'لا توجد شركات تجريبية متاحة للعرض.'
      : 'No sample companies are available to show.';
  String get goBackToSectors =>
      isArabic ? 'العودة إلى القطاعات' : 'Back to sectors';

  String get homeWelcomeTitle =>
      isArabic ? 'بوابتك إلى التجارة الدولية' : 'Your gateway to global trade';
  String get homeWelcomeBody => isArabic
      ? 'اختر المسار المناسب لعملك أو استكشف شبكة الأعمال.'
      : 'Choose the path that fits your business, or explore the network.';
  String get quickAccess => isArabic ? 'ابدأ من هنا' : 'Start here';
  String get visitorMode => isArabic ? 'وضع الزائر' : 'Visitor mode';
  String get previewOnly =>
      isArabic ? 'واجهة أولية · معاينة محلية' : 'Initial UI · local preview';
  String get homeTab => isArabic ? 'الرئيسية' : 'Home';
  String get discoverTab => isArabic ? 'اكتشف' : 'Discover';
  String get communityTab => isArabic ? 'المجتمع' : 'Community';
  String get messagesTab => isArabic ? 'الرسائل' : 'Messages';
  String get myAccountTab => isArabic ? 'حسابي' : 'My Account';
  String get discoverDescription => isArabic
      ? 'استكشف قطاعات التجارة الثمانية وابحث في البيانات التجريبية المحلية.'
      : 'Explore the eight trade sectors and search local sample data.';
  String get communityDescription => isArabic
      ? 'مساحة المجتمع قيد الإعداد. لا توجد منشورات تجريبية في هذه المعاينة.'
      : 'The community area is an initial UI. No sample posts are available.';
  String get messagesDescription => isArabic
      ? 'واجهة أولية للرسائل. لا توجد محادثات تجريبية أو خدمة مراسلة متصلة.'
      : 'Initial messages UI. No sample conversations or messaging service is connected.';
  String get accountDescription => isArabic
      ? 'أنت تتصفح بوضع الزائر. لا يوجد حساب أو خدمة تسجيل دخول متصلة.'
      : 'You are browsing as a visitor. No account or sign-in service is connected.';
  String get noResults =>
      isArabic ? 'لا توجد نتائج مطابقة.' : 'No matching results.';
  String get sampleCompany => isArabic ? 'شركة تجريبية' : 'Sample company';
  String get destinationInitialTitle => isArabic ? 'واجهة أولية' : 'Initial UI';
  String get destinationInitialBody => isArabic
      ? 'هذه شاشة بداية محلية للمراجعة. لا ترسل بيانات ولا تتصل بخدمة خارجية.'
      : 'This is a local initial screen for review. It does not submit data or connect to an external service.';
  String get exporterTitle => isArabic ? 'أنا مصدر' : "I'm an Exporter";
  String get importerTitle => isArabic ? 'أنا مستورد' : "I'm an Importer";
  String get vehiclesTitle => isArabic ? 'السيارات' : 'Vehicles';
  String get jobsTitle => isArabic ? 'الوظائف' : 'Jobs';
  String get leopardTitle => 'Leopard';
  String get exporterDescription => isArabic
      ? 'واجهة أولية للمصدرين لاستعراض القطاعات والمنتجات والأسواق.'
      : 'An initial exporter workspace for exploring sectors, products and markets.';
  String get importerDescription => isArabic
      ? 'واجهة أولية للمستوردين لاستكشاف المنتجات والموردين.'
      : 'An initial importer workspace for exploring products and suppliers.';
  String get vehiclesDescription => isArabic
      ? 'مساحة أولية للسيارات والمركبات. لا توجد سجلات استيراد أو بيانات تكاليف متصلة.'
      : 'An initial vehicles area. No import records or cost data are connected.';
  String get jobsDescription => isArabic
      ? 'واجهة أولية للوظائف. لا توجد وظائف أو طلبات توظيف تجريبية.'
      : 'Initial jobs UI. No sample vacancies or applications are available.';
  String get leopardDescription => isArabic
      ? 'واجهة أولية لمراجعة خدمات Leopard. لا توجد عروض أسعار أو طلبات شحن متصلة.'
      : 'An initial Leopard services screen. No quotes or shipping requests are connected.';
  String entryPointTitle(HomeEntryPoint point) => switch (point) {
    HomeEntryPoint.exporter => exporterTitle,
    HomeEntryPoint.importer => importerTitle,
    HomeEntryPoint.vehicles => vehiclesTitle,
    HomeEntryPoint.jobs => jobsTitle,
    HomeEntryPoint.community => communityTab,
    HomeEntryPoint.leopard => leopardTitle,
  };
  String entryPointDescription(HomeEntryPoint point) => switch (point) {
    HomeEntryPoint.exporter => exporterDescription,
    HomeEntryPoint.importer => importerDescription,
    HomeEntryPoint.vehicles => vehiclesDescription,
    HomeEntryPoint.jobs => jobsDescription,
    HomeEntryPoint.community => communityDescription,
    HomeEntryPoint.leopard => leopardDescription,
  };
  String get entryPointSubtitle => isArabic
      ? 'واجهة أولية لاستكشاف هذا المسار. لا توجد معاملات أو خدمات مباشرة.'
      : 'An initial workspace for this path. No live services or transactions.';
  String get sectorsSearchHint =>
      isArabic ? 'ابحث في القطاعات...' : 'Search sectors...';
  String get companiesSearchHint =>
      isArabic ? 'ابحث عن شركة تجريبية...' : 'Search sample companies...';
  String get countryLabel => isArabic ? 'الدولة' : 'Country';
  String get businessActivityLabel =>
      isArabic ? 'النشاط التجاري' : 'Business activity';
  String get productCategoryLabel =>
      isArabic ? 'فئة المنتج' : 'Product category';
  String get lastReviewedLabel => isArabic ? 'آخر مراجعة' : 'Last reviewed';
  String get primaryDataSourceLabel =>
      isArabic ? 'مصدر البيانات الأساسي' : 'Primary data source';
  String get unavailable => isArabic ? 'غير متاح' : 'Not provided';
  String get sampleDataLabel => isArabic ? 'بيانات تجريبية' : 'Sample data';
  String get unclaimedLabel => isArabic ? 'غير مطالب بها' : 'Unclaimed';
  String get claimedLabel => isArabic ? 'تمت المطالبة' : 'Claimed';
  String get reviewedLabel => isArabic ? 'تمت المراجعة' : 'Reviewed';
  String get verifiedLabel => isArabic ? 'موثّق' : 'Verified';
  String get verificationUnconfirmed =>
      isArabic ? 'تعذر تأكيد التوثيق' : 'Verification not confirmed';
  String get viewCompanyDetails =>
      isArabic ? 'عرض تفاصيل الشركة' : 'View company details';
  String get sectorCompaniesTitle => isArabic
      ? 'شركات تجريبية مرتبطة بهذا القطاع'
      : 'Sample companies in this sector';
  String get noSectorCompanies => isArabic
      ? 'لا توجد شركات تجريبية مرتبطة بهذا القطاع حاليًا.'
      : 'No sample companies are linked to this sector yet.';
  String get sectorDemoNote => isArabic
      ? 'هذه بيانات عرض تجريبية ولا تمثل موردين أو مصدرين مؤكدين.'
      : 'Demonstration content only; these are not confirmed suppliers or exporters.';
  String get homeLabel => isArabic ? 'الرئيسية' : 'Home';

  String companyTrustLabel(Company company) {
    if (company.trustStatus == CompanyTrustStatus.sample) {
      return sampleDataLabel;
    }
    if (company.trustStatus == CompanyTrustStatus.verified) {
      return company.isVerified ? verifiedLabel : verificationUnconfirmed;
    }
    return switch (company.trustStatus) {
      CompanyTrustStatus.sample => sampleDataLabel,
      CompanyTrustStatus.unclaimed => unclaimedLabel,
      CompanyTrustStatus.claimed => claimedLabel,
      CompanyTrustStatus.reviewed =>
        company.lastReviewedAt == null ? unavailable : reviewedLabel,
      CompanyTrustStatus.verified => verificationUnconfirmed,
    };
  }

  String get brand => 'INDEX';
  String get brandSub => isArabic ? 'لوجستيات' : 'LOGISTICS';
  String get network => isArabic ? 'الشبكة' : 'Network';
  String get directory => isArabic ? 'دليل الشركات' : 'Directory';
  String get opportunities => isArabic ? 'الفرص' : 'Opportunities';
  String get insights => isArabic ? 'رؤى السوق' : 'Market insights';
  String get searchHint => isArabic
      ? 'ابحث عن شركات، منتجات، أو خدمات...'
      : 'Search companies, products or services...';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign in';
  String get join => isArabic ? 'انضم إلى الشبكة' : 'Join the network';
  String get eyebrow => isArabic
      ? 'شبكة التجارة والخدمات اللوجستية الدولية'
      : 'THE INTERNATIONAL TRADE & LOGISTICS NETWORK';
  String get heroTitle => isArabic
      ? 'تجارة أكثر ترابطًا.\nوأعمال تتجاوز الحدود.'
      : 'Trade, connected.\nBusiness without borders.';
  String get heroBody => isArabic
      ? 'اكتشف شركاء موثوقين، وخدمات لوجستية، وفرصًا تجارية في مكان واحد.'
      : 'Find trusted partners, logistics services and commercial opportunities in one connected business network.';
  String get explore => isArabic ? 'استكشف الشبكة' : 'Explore the network';
  String get becomePartner => isArabic ? 'اعرض شركتك' : 'List your business';
  String get networkLabel =>
      isArabic ? 'شبكة أعمال عالمية' : 'A connected trade network';
  String get sectorsTitle =>
      isArabic ? 'قطاعات التجارة والخدمات' : 'Explore the trade ecosystem';
  String get sectorsSubtitle => isArabic
      ? 'مساحة واحدة تربط أطراف التجارة الدولية.'
      : 'One place for the people and services moving global trade.';
  String get seeAll => isArabic ? 'عرض الكل' : 'View all';
  String get featuredTitle =>
      isArabic ? 'شركات تستحق الاكتشاف' : 'Businesses to know';
  String get featuredSubtitle => isArabic
      ? 'نماذج تجريبية لعرض دليل الشركات.'
      : 'A preview of the Index business directory.';
  String get verified => isArabic ? 'موثّق' : 'Verified';
  String get mockLabel =>
      isArabic ? 'معاينة ببيانات تجريبية' : 'Preview · sample data';
  String get allBusinesses => isArabic ? 'كل الشركات' : 'All businesses';
  String get suppliers => isArabic ? 'المورّدون' : 'Suppliers';
  String get logistics => isArabic ? 'الخدمات اللوجستية' : 'Logistics';
  String get manufacturers => isArabic ? 'المصنّعون' : 'Manufacturers';
  String get freight => isArabic ? 'الشحن والتخليص' : 'Freight & customs';
  String get tradeServices => isArabic ? 'خدمات التجارة' : 'Trade services';
  String get food => isArabic ? 'الغذاء والزراعة' : 'Food & agriculture';
  String get industrial =>
      isArabic ? 'الصناعة والمواد' : 'Industry & materials';
  String get technology => isArabic ? 'التقنية' : 'Technology';
  String get healthcare => isArabic ? 'الرعاية الصحية' : 'Healthcare';
  String get memberCompanies =>
      isArabic ? 'شركة في الشبكة' : 'member companies';
  String get countries => isArabic ? 'دولة' : 'countries';
  String get tradeSectors => isArabic ? 'قطاعات تجارية' : 'trade sectors';
  String get footer => isArabic
      ? 'نبني روابط أفضل للتجارة الدولية.'
      : 'Building better connections for international trade.';
  String get languageButton => isArabic ? 'EN' : 'Arabic';
  String get profile => isArabic ? 'حسابي' : 'Profile';
}
