import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/catalog/data/local_category_repository.dart';
import 'package:index_logistic/features/catalog/presentation/catalog_copy.dart';
import 'package:index_logistic/features/catalog/presentation/catalog_screen.dart';
import 'package:index_logistic/features/home/data/home_mock_data.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

const _searchKey = ValueKey('catalog-search');
const _homeShortcut = ValueKey('home-catalog-shortcut');
const _discoverShortcut = ValueKey('discover-catalog-shortcut');
const _categories = LocalCategoryRepository();

void main() {
  test(
    'V4 CAT-01 to CAT-35 are unique and separate from SEC-01 to SEC-08',
    () async {
      final categories = _categories.categories;
      expect(categories.map((item) => item.id), [
        for (var i = 1; i <= 35; i++) 'CAT-${i.toString().padLeft(2, '0')}',
      ]);
      expect(categories.map((item) => item.slug).toSet(), hasLength(35));
      expect(categories.map((item) => item.nameAr), [
        'المستوردون',
        'المصدرون',
        'السيارات والمركبات',
        'التأمين',
        'الفحص والمتابعة والجودة',
        'الهيئات الداعمة للمصدرين',
        'الساحات والمخازن الجمركية',
        'النقل الداخلي',
        'الخطوط الملاحية والسفن',
        'شركات الطيران والشحن الجوي',
        'النقل البري الدولي',
        'وكلاء الشحن',
        'الشحن السريع والبريد',
        'التمثيل التجاري',
        'المعارض والفعاليات',
        'الحاويات والتحوية والرص',
        'التخليص الجمركي',
        'التعبئة والتغليف والمعدات المساندة',
        'المنصات والإجراءات الجمركية',
        'المستشار التجاري واللوجستي الذكي',
        'الأمتعة الشخصية والانتقال',
        'الاستيراد الخاص والشحنات غير النمطية',
        'الاستيراد الشخصي والتجارة الإلكترونية',
        'الوظائف والخبرات',
        'التوقيت والاجتماعات',
        'العملات والمعلومات المالية',
        'تكلفة الشحن وطلبات الأسعار',
        'شروط التجارة وطرق السداد',
        'تتبع الشحنات والحاويات',
        'البصمة الكربونية و CBAM',
        'الجمارك والضرائب والتكلفة الواصلة',
        'فرص التصدير وطلبات الشراء والأسواق',
        'البضائع الخطرة والشحنات الخاصة',
        'سلسلة التبريد وحرارة البضائع',
        'الأكاديمية والمكتبة والاستشارات',
      ]);
      final sectors = await const HomeMockData().getSectors();
      expect(sectors.map((item) => item.id), [
        for (var i = 1; i <= 8; i++) 'SEC-0$i',
      ]);
    },
  );

  testWidgets('Home opens each category in two route transitions', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openHomeCatalog(tester);
    expect(find.byType(CatalogScreen), findsOneWidget);
    final search = find.byKey(_searchKey);
    for (final item in _categories.categories) {
      await tester.enterText(search, item.id);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey(item.id)));
      await tester.pumpAndSettle();
      final detail = find.byType(CategoryDetailsScreen);
      expect(tester.widget<CategoryDetailsScreen>(detail).category, same(item));
      expect(
        find.descendant(of: detail, matching: find.text(item.nameEn)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: detail, matching: find.text(item.descriptionEn)),
        findsOneWidget,
      );
      expect(find.text('Local preview'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, item.id);
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets(
    'Discover opens catalog and search matches both languages and IDs',
    (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Discover').first);
      await tester.pumpAndSettle();
      final shortcut = _shortcutButton(_discoverShortcut);
      await tester.ensureVisible(shortcut);
      await tester.tap(shortcut);
      await tester.pumpAndSettle();

      final search = find.byKey(_searchKey);
      for (final query in ['البضائع الخطرة', 'DANGEROUS GOODS', 'cat-٣٣']) {
        await tester.enterText(search, query);
        await tester.pumpAndSettle();
        expect(find.text('1 of 35 categories'), findsOneWidget);
        expect(find.byKey(const ValueKey('CAT-33')), findsOneWidget);
      }
      await tester.enterText(search, 'SEC-01');
      await tester.pumpAndSettle();
      expect(
        find.text('No categories match. Try another name or a category ID.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('35 of 35 categories'), findsOneWidget);
    },
  );

  for (final language in [AppLanguage.english, AppLanguage.arabic]) {
    for (final width in [360.0, 390.0, 768.0, 1280.0, 1440.0]) {
      testWidgets(
        '${language.name} catalog and details at ${width.toInt()}px and 200% text',
        (tester) async {
          await _pumpApp(tester, width: width, language: language, scale: 2);
          await _openHomeCatalog(tester);
          final search = find.byKey(_searchKey);
          expect(
            Directionality.of(tester.element(search)),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          await tester.enterText(search, 'CAT-31');
          await tester.pumpAndSettle();
          final result = find.byKey(const ValueKey('CAT-31'));
          await tester.dragUntilVisible(
            result.hitTestable(),
            find.descendant(
              of: find.byType(CatalogScreen),
              matching: find.byType(ListView),
            ),
            const Offset(0, -300),
          );
          await tester.tap(result);
          await tester.pumpAndSettle();
          final copy = CatalogCopy(AppCopy(language));
          final item = _categories.categories[30];
          expect(find.text(copy.name(item)), findsOneWidget);
          final capability = find.text(copy.capability(item.futureCapability!));
          expect(capability, findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  AppLanguage language = AppLanguage.english,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 844);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(const IndexLogisticsApp());
  await tester.pumpAndSettle();
  if (language == AppLanguage.arabic) {
    tester.element(find.byType(HomeScreen)).read<AppCubit>().toggleLanguage();
    await tester.pumpAndSettle();
  }
}

Future<void> _openHomeCatalog(WidgetTester tester) async {
  final shortcut = _shortcutButton(_homeShortcut);
  await tester.dragUntilVisible(
    shortcut.hitTestable(),
    find.byKey(const ValueKey('home-page-scroll')),
    const Offset(0, -300),
  );
  await tester.tap(shortcut);
  await tester.pumpAndSettle();
}

Finder _shortcutButton(ValueKey<String> key) => find.descendant(
  of: find.byKey(key),
  matching: find.byType(FilledButton),
);
