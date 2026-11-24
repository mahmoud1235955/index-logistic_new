import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/directory/domain/company.dart';
import 'package:index_logistic/features/directory/presentation/company_card.dart';
import 'package:index_logistic/features/home/data/home_mock_data.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

Future<void> scrollHomeTo(WidgetTester tester, Finder target) async {
  await Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.25,
    duration: Duration.zero,
  );
  await tester.pump();
}

void main() {
  test('V4 sector IDs and Arabic names are exact and unique', () {
    const expected = <(String, String)>[
      ('SEC-01', 'الأغذية والحاصلات الزراعية'),
      ('SEC-02', 'المنسوجات والملابس والجلود'),
      ('SEC-03', 'الكيماويات والأسمدة'),
      ('SEC-04', 'مواد البناء والمعادن'),
      ('SEC-05', 'الصناعات الهندسية والإلكترونية والأجهزة المنزلية'),
      ('SEC-06', 'الأدوية والمستلزمات الطبية'),
      ('SEC-07', 'الحرف اليدوية والمنتجات التراثية'),
      ('SEC-08', 'الأثاث والصناعات الخشبية'),
    ];
    final sectors = HomeMockData.sectors;
    expect(sectors, hasLength(8));
    expect(sectors.map((sector) => sector.id).toSet(), hasLength(8));
    expect(
      sectors.map((sector) => (sector.id, sector.titleAr)).toList(),
      expected,
    );
    expect(
      sectors.map((sector) => sector.id).toList(),
      expected.map((entry) => entry.$1).toList(),
    );
    expect(sectors.map((sector) => sector.titleEn).toList(), [
      'Food & agricultural produce',
      'Textiles, clothing & leather',
      'Chemicals & fertilizers',
      'Building materials & metals',
      'Engineering, electronics & household appliances',
      'Medicines & medical supplies',
      'Handicrafts & heritage products',
      'Furniture & wood products',
    ]);
  });

  test(
    'company defaults to sample and cannot appear verified without evidence',
    () {
      const sample = Company(
        name: 'Example',
        category: 'Activity',
        location: 'Example location',
        initials: 'EX',
        accent: 0xFF1D5B8F,
      );
      const unsupportedVerified = Company(
        name: 'Unsubstantiated',
        category: 'Activity',
        location: 'Example location',
        initials: 'UN',
        accent: 0xFF1D5B8F,
        trustStatus: CompanyTrustStatus.verified,
      );
      final incompleteEvidence = Company(
        name: 'Incomplete evidence',
        category: 'Activity',
        location: 'Example location',
        initials: 'IE',
        accent: 0xFF1D5B8F,
        trustStatus: CompanyTrustStatus.verified,
        verificationEvidence: CompanyVerificationEvidence(
          source: ' ',
          reviewedAt: DateTime(2026, 1, 1),
          reference: '',
        ),
      );

      expect(sample.trustStatus, CompanyTrustStatus.sample);
      expect(sample.isVerified, isFalse);
      expect(sample.primaryDataSource, isNull);
      expect(sample.lastReviewedAt, isNull);
      expect(unsupportedVerified.isVerified, isFalse);
      expect(incompleteEvidence.isVerified, isFalse);
    },
  );

  test('trust states are distinct and reviewed needs a review date', () {
    Company company(CompanyTrustStatus status, {DateTime? reviewedAt}) =>
        Company(
          name: 'Fixture',
          category: 'Activity',
          location: 'Fixture location',
          initials: 'FX',
          accent: 0xFF1D5B8F,
          trustStatus: status,
          lastReviewedAt: reviewedAt,
        );

    const copy = AppCopy(AppLanguage.english);
    expect(
      copy.companyTrustLabel(company(CompanyTrustStatus.sample)),
      'Sample data',
    );
    expect(
      copy.companyTrustLabel(company(CompanyTrustStatus.unclaimed)),
      'Unclaimed',
    );
    expect(
      copy.companyTrustLabel(company(CompanyTrustStatus.claimed)),
      'Claimed',
    );
    expect(
      copy.companyTrustLabel(company(CompanyTrustStatus.reviewed)),
      'Not provided',
    );
    expect(
      copy.companyTrustLabel(
        company(CompanyTrustStatus.reviewed, reviewedAt: DateTime(2026, 1, 1)),
      ),
      'Reviewed',
    );
    expect(
      copy.companyTrustLabel(company(CompanyTrustStatus.verified)),
      'Verification not confirmed',
    );
  });

  testWidgets('verified status without evidence has no Verified badge', (
    tester,
  ) async {
    const company = Company(
      name: 'Unsupported verification',
      category: 'Activity',
      location: 'Unknown',
      initials: 'UV',
      accent: 0xFF1D5B8F,
      trustStatus: CompanyTrustStatus.verified,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompanyCard(
            company: company,
            copy: const AppCopy(AppLanguage.english),
            onPrimaryAction: () {},
          ),
        ),
      ),
    );

    expect(find.text('Verification not confirmed'), findsOneWidget);
    expect(find.text('Verified'), findsNothing);
  });

  testWidgets('company card shows available and unavailable UX-05 fields', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('company-card-Northstar Freight'));
    await scrollHomeTo(tester, card);
    await tester.pumpAndSettle();

    expect(find.byType(CompanyCard), findsWidgets);
    expect(find.text('Netherlands'), findsOneWidget);
    expect(find.text('Freight forwarding'), findsOneWidget);
    expect(find.text('Country'), findsWidgets);
    expect(find.text('Business activity'), findsWidgets);
    expect(find.text('Product category'), findsWidgets);
    expect(find.text('Last reviewed'), findsWidgets);
    expect(find.text('Primary data source'), findsWidgets);
    expect(find.text('Not provided'), findsWidgets);
    expect(find.text('Sample data'), findsWidgets);
    expect(find.text('Verified'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('company-cta-Northstar Freight')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Northstar Freight'), findsWidgets);
    expect(find.text('Sample data'), findsOneWidget);
    expect(find.text('Not provided'), findsWidgets);
  });

  testWidgets('sector details use the stable sector ID and return to Home', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();

    final sector = find.byKey(const ValueKey('sector-SEC-01'));
    await scrollHomeTo(tester, sector);
    await tester.tap(sector);
    await tester.pumpAndSettle();
    expect(find.text('Food & agricultural produce'), findsWidgets);
    expect(find.text('Sample companies in this sector'), findsOneWidget);
    expect(find.text('Meridian Foods Co.'), findsOneWidget);
    expect(
      find.text(
        'Demonstration content only; these are not confirmed suppliers or exporters.',
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-page-scroll')), findsOneWidget);

    await scrollHomeTo(tester, sector);
    await tester.tap(sector);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(AppCopy(AppLanguage.english).homeLabel));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-page-scroll')), findsOneWidget);

    final sectorWithoutCompanies = find.byKey(const ValueKey('sector-SEC-02'));
    await scrollHomeTo(tester, sectorWithoutCompanies);
    await tester.tap(sectorWithoutCompanies);
    await tester.pumpAndSettle();
    expect(
      find.text('No sample companies are linked to this sector yet.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Back to sectors'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-page-scroll')), findsOneWidget);
  });

  testWidgets('company and sector cards use Arabic copy in RTL', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();
    tester.element(find.byType(HomeScreen)).read<AppCubit>().toggleLanguage();
    await tester.pumpAndSettle();

    final sector = find.byKey(const ValueKey('sector-SEC-01'));
    await scrollHomeTo(tester, sector);
    await tester.tap(sector);
    await tester.pumpAndSettle();
    expect(find.text('الأغذية والحاصلات الزراعية'), findsWidgets);
    expect(
      find.text('الحاصلات الزراعية والمنتجات الغذائية المخصصة للتجارة.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip(AppCopy(AppLanguage.arabic).homeLabel));
    await tester.pumpAndSettle();

    final company = find.byKey(
      const ValueKey('company-card-Meridian Foods Co.'),
    );
    await scrollHomeTo(tester, company);
    await tester.pumpAndSettle();
    expect(find.text('الدولة'), findsWidgets);
    expect(find.text('النشاط التجاري'), findsWidgets);
    expect(find.text('فئة المنتج'), findsWidgets);
    expect(find.text('آخر مراجعة'), findsWidgets);
    expect(find.text('مصدر البيانات الأساسي'), findsWidgets);
    expect(find.text('مصر'), findsOneWidget);
    expect(find.text('تصدير الأغذية'), findsOneWidget);
    expect(find.text('بيانات تجريبية'), findsWidgets);
    expect(find.text('موثّق'), findsNothing);
  });
}
