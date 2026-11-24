import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/theme/app_theme.dart';
import 'package:index_logistic/features/directory/presentation/company_details_screen.dart';
import 'package:index_logistic/features/home/data/home_mock_data.dart';
import 'package:index_logistic/features/home/presentation/cubit/home_cubit.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';
import 'package:index_logistic/features/home/presentation/sector_details_screen.dart';

const _widths = [360.0, 390.0, 768.0, 1280.0, 1440.0];

void main() {
  testWidgets('Discover/Search stays responsive in both directions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final scale in [1.0, 2.0]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      for (final width in _widths) {
        for (final isArabic in [false, true]) {
          tester.view.physicalSize = Size(width, 900);
          await tester.pumpWidget(const IndexLogisticsApp());
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(HomeScreen));
          if (isArabic) {
            context.read<AppCubit>().toggleLanguage();
            await tester.pumpAndSettle();
          }
          tester
              .element(find.byType(HomeScreen))
              .read<HomeCubit>()
              .selectTab(1);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('discover-page-scroll')),
            findsOneWidget,
          );
          expect(_horizontalScrollables(tester), isEmpty);
          _expectNoRenderingError(
            tester,
            'Discover $width px, Arabic=$isArabic',
          );
        }
      }
    }
  });

  testWidgets(
    'Company and sector details fit all target widths in RTL and LTR',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      for (final scale in [1.0, 2.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        for (final width in _widths) {
          for (final language in [AppLanguage.english, AppLanguage.arabic]) {
            final copy = AppCopy(language);
            final direction = language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr;
            tester.view.physicalSize = Size(width, 900);

            await tester.pumpWidget(
              MaterialApp(
                theme: IndexTheme.light,
                home: Directionality(
                  textDirection: direction,
                  child: CompanyDetailsScreen(
                    company: HomeMockData.companies.first,
                    copy: copy,
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(_horizontalScrollables(tester), isEmpty);
            _expectNoRenderingError(
              tester,
              'Company details $width px, $language',
            );
            if (language == AppLanguage.arabic) {
              for (final name in tester.widgetList<Text>(
                find.text(HomeMockData.companies.first.name),
              )) {
                expect(name.textDirection, TextDirection.ltr);
              }
            }

            await tester.pumpWidget(
              MaterialApp(
                theme: IndexTheme.light,
                home: Directionality(
                  textDirection: direction,
                  child: SectorDetailsScreen(
                    sector: HomeMockData.sectors.first,
                    companies: HomeMockData.companies,
                    copy: copy,
                    onHome: () {},
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(_horizontalScrollables(tester), isEmpty);
            _expectNoRenderingError(
              tester,
              'Sector details $width px, $language',
            );
          }
        }
      }
    },
  );
}

Iterable<Scrollable> _horizontalScrollables(WidgetTester tester) => tester
    .widgetList<Scrollable>(find.byType(Scrollable))
    .where(
      (scrollable) =>
          (scrollable.axisDirection == AxisDirection.left ||
              scrollable.axisDirection == AxisDirection.right) &&
          scrollable.restorationId != 'editable',
    );

void _expectNoRenderingError(WidgetTester tester, String context) {
  final errors = <Object>[];
  Object? error;
  while ((error = tester.takeException()) != null) {
    errors.add(error!);
  }
  expect(errors, isEmpty, reason: '$context: ${errors.join('; ')}');
}
