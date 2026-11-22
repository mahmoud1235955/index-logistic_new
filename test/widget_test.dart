// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('shows the Index Logistics preview and can switch language', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const IndexLogisticsApp());

    expect(
      find.text('Trade, connected.\nBusiness without borders.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Arabic'));
    await tester.pumpAndSettle();
    expect(
      find.text('تجارة أكثر ترابطًا.\nوأعمال تتجاوز الحدود.'),
      findsOneWidget,
    );
  });

  testWidgets('preserves the four mobile navigation destinations', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(700, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });

  testWidgets('Home fits supported responsive widths in English and Arabic', (
    WidgetTester tester,
  ) async {
    const widths = [360.0, 390.0, 430.0, 600.0, 800.0, 1024.0, 1440.0];
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in widths) {
      for (final isArabic in [false, true]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpWidget(const IndexLogisticsApp());
        await tester.pumpAndSettle();

        if (isArabic) {
          tester
              .element(find.byType(HomeScreen))
              .read<AppCubit>()
              .toggleLanguage();
          await tester.pumpAndSettle();
        }

        final errors = <Object>[];
        Object? error;
        while ((error = tester.takeException()) != null) {
          errors.add(error!);
        }
        expect(
          errors,
          isEmpty,
          reason:
              'Home should fit at ${width.toInt()}px in '
              '${isArabic ? 'Arabic RTL' : 'English LTR'}',
        );
      }
    }
  });
}
