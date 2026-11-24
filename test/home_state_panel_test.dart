import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/state/app_view_state.dart';
import 'package:index_logistic/core/widgets/app_state_panel.dart';

void main() {
  const states = AppViewState.values;
  const englishTitles = [
    'Loading',
    'Nothing to show yet',
    'Preview could not load',
    'Offline preview state',
    'Preview expired',
    'Permission unavailable',
  ];
  const arabicTitles = [
    'جارٍ التحميل',
    'لا توجد بيانات للعرض',
    'تعذر تحميل المعاينة',
    'حالة معاينة دون اتصال',
    'انتهت صلاحية المعاينة',
    'الصلاحية غير متاحة',
  ];

  testWidgets('all six UX states have English and Arabic titles and messages', (
    tester,
  ) async {
    for (final language in [AppLanguage.english, AppLanguage.arabic]) {
      final titles = language == AppLanguage.english
          ? englishTitles
          : arabicTitles;
      for (var index = 0; index < states.length; index++) {
        final copy = AppCopy(language);
        final state = states[index];
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: language == AppLanguage.arabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                body: Center(
                  child: AppStatePanel(
                    state: state,
                    copy: copy,
                    onAction: state == AppViewState.loading ? null : () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(titles[index]), findsOneWidget);
        expect(find.text(copy.stateMessage(state)), findsOneWidget);
        expect(copy.stateMessage(state), isNotEmpty);
        expect(
          Directionality.of(tester.element(find.text(titles[index]))),
          language == AppLanguage.arabic
              ? TextDirection.rtl
              : TextDirection.ltr,
        );
      }
    }
  });

  testWidgets('retry and empty recovery actions invoke their callbacks', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStatePanel(
            state: AppViewState.error,
            copy: const AppCopy(AppLanguage.english),
            onAction: () => retries++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Try again'));
    expect(retries, 1);

    var recoveries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStatePanel(
            state: AppViewState.empty,
            copy: const AppCopy(AppLanguage.english),
            actionLabel: 'Clear search',
            onAction: () => recoveries++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Clear search'));
    expect(recoveries, 1);
  });

  testWidgets('states without recovery do not show a dead action button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStatePanel(
            state: AppViewState.loading,
            copy: const AppCopy(AppLanguage.english),
          ),
        ),
      ),
    );
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('state panels fit V4 widths in both directions at 200% text', (
    tester,
  ) async {
    const widths = [360.0, 390.0, 768.0, 1280.0, 1440.0];
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    final errors = <String>[];

    for (final width in widths) {
      for (final language in [AppLanguage.english, AppLanguage.arabic]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: language == AppLanguage.arabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      for (final state in states)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppStatePanel(
                            state: state,
                            copy: AppCopy(language),
                            onAction: state == AppViewState.loading
                                ? null
                                : () {},
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final error = tester.takeException();
        if (error != null) errors.add('$width px, $language: $error');
        final horizontal = tester
            .widgetList<Scrollable>(find.byType(Scrollable))
            .where(
              (scrollable) =>
                  scrollable.axisDirection == AxisDirection.left ||
                  scrollable.axisDirection == AxisDirection.right,
            );
        expect(horizontal, isEmpty);
      }
    }
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}
