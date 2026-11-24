import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/state/app_view_state.dart';
import 'package:index_logistic/core/widgets/app_state_panel.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('captures the 390px Home screen in English', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/sprint3_home_390_en.png'),
    );
  });

  testWidgets('captures the 390px Home screen in Arabic RTL', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();
    tester.element(find.byType(HomeScreen)).read<AppCubit>().toggleLanguage();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/sprint3_home_390_ar.png'),
    );
  });

  testWidgets('captures all six UX state panels for visual review', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const copy = AppCopy(AppLanguage.english);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                for (final state in AppViewState.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppStatePanel(
                      state: state,
                      copy: copy,
                      onAction: state == AppViewState.loading ? null : () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/sprint3_state_panels_1280.png'),
    );
  });
}
