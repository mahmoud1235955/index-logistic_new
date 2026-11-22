import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('desktop language label is readable in both directions', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [800.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const IndexLogisticsApp());
      await tester.pumpAndSettle();

      expect(find.text('Arabic'), findsOneWidget);
    }

    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();
    tester
        .element(find.byType(HomeScreen))
        .read<AppCubit>()
        .toggleLanguage();
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('EN'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Home remains usable at 100%, 125%, and 150% text scale', (
    WidgetTester tester,
  ) async {
    const scales = [1.0, 1.25, 1.5];
    const widths = [390, 800, 1440];
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final scale in scales) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      for (final width in widths) {
        for (final isArabic in [false, true]) {
          tester.view.physicalSize = Size(width.toDouble(), 900);
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
                'Home at ${width}px, ${isArabic ? 'RTL' : 'LTR'}, '
                'text scale ${scale * 100}%',
          );
        }
      }
    }
  });
}
