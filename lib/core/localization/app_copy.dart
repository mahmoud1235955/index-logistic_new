enum AppLanguage {
  english('en'), arabic('ar'), french('fr'), italian('it'), hindi('hi'), chinese('zh');

  const AppLanguage(this.languageCode);
  final String languageCode;
  String get countryCode => this == AppLanguage.chinese ? 'CN' : this == AppLanguage.arabic ? 'EG' : '';
}

class AppCopy {
  const AppCopy(this.language);
  final AppLanguage language;
  bool get isArabic => language == AppLanguage.arabic;

  String get brand => 'INDEX';
  String get brandSub => isArabic ? 'لوجستيات' : 'LOGISTICS';
  String get network => isArabic ? 'الشبكة' : 'Network';
  String get directory => isArabic ? 'دليل الشركات' : 'Directory';
  String get opportunities => isArabic ? 'الفرص' : 'Opportunities';
  String get insights => isArabic ? 'رؤى السوق' : 'Market insights';
  String get searchHint => isArabic ? 'ابحث عن شركات، منتجات، أو خدمات...' : 'Search companies, products or services...';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign in';
  String get join => isArabic ? 'انضم إلى الشبكة' : 'Join the network';
  String get eyebrow => isArabic ? 'شبكة التجارة والخدمات اللوجستية الدولية' : 'THE INTERNATIONAL TRADE & LOGISTICS NETWORK';
  String get heroTitle => isArabic ? 'تجارة أكثر ترابطًا.\nوأعمال تتجاوز الحدود.' : 'Trade, connected.\nBusiness without borders.';
  String get heroBody => isArabic ? 'اكتشف شركاء موثوقين، وخدمات لوجستية، وفرصًا تجارية في مكان واحد.' : 'Find trusted partners, logistics services and commercial opportunities in one connected business network.';
  String get explore => isArabic ? 'استكشف الشبكة' : 'Explore the network';
  String get becomePartner => isArabic ? 'اعرض شركتك' : 'List your business';
  String get networkLabel => isArabic ? 'شبكة أعمال عالمية' : 'A connected trade network';
  String get sectorsTitle => isArabic ? 'قطاعات التجارة والخدمات' : 'Explore the trade ecosystem';
  String get sectorsSubtitle => isArabic ? 'مساحة واحدة تربط أطراف التجارة الدولية.' : 'One place for the people and services moving global trade.';
  String get seeAll => isArabic ? 'عرض الكل' : 'View all';
  String get featuredTitle => isArabic ? 'شركات تستحق الاكتشاف' : 'Businesses to know';
  String get featuredSubtitle => isArabic ? 'نماذج تجريبية لعرض دليل الشركات.' : 'A preview of the Index business directory.';
  String get verified => isArabic ? 'موثّق' : 'Verified';
  String get mockLabel => isArabic ? 'معاينة ببيانات تجريبية' : 'Preview · sample data';
  String get allBusinesses => isArabic ? 'كل الشركات' : 'All businesses';
  String get suppliers => isArabic ? 'المورّدون' : 'Suppliers';
  String get logistics => isArabic ? 'الخدمات اللوجستية' : 'Logistics';
  String get manufacturers => isArabic ? 'المصنّعون' : 'Manufacturers';
  String get freight => isArabic ? 'الشحن والتخليص' : 'Freight & customs';
  String get tradeServices => isArabic ? 'خدمات التجارة' : 'Trade services';
  String get food => isArabic ? 'الغذاء والزراعة' : 'Food & agriculture';
  String get industrial => isArabic ? 'الصناعة والمواد' : 'Industry & materials';
  String get technology => isArabic ? 'التقنية' : 'Technology';
  String get healthcare => isArabic ? 'الرعاية الصحية' : 'Healthcare';
  String get memberCompanies => isArabic ? 'شركة في الشبكة' : 'member companies';
  String get countries => isArabic ? 'دولة' : 'countries';
  String get tradeSectors => isArabic ? 'قطاعات تجارية' : 'trade sectors';
  String get footer => isArabic ? 'نبني روابط أفضل للتجارة الدولية.' : 'Building better connections for international trade.';
  String get languageButton => isArabic ? 'EN' : 'عربي';
  String get profile => isArabic ? 'حسابي' : 'Profile';
}
