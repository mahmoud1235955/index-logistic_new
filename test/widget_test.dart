import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, double width) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();
  }

  testWidgets('shows six required Home entry points in Arabic and English', (
    tester,
  ) async {
    await pumpAt(tester, 390);
    const englishEntries = {
      'exporter': "I'm an Exporter",
      'importer': "I'm an Importer",
      'vehicles': 'Vehicles',
      'jobs': 'Jobs',
      'community': 'Community',
      'leopard': 'Leopard',
    };
    for (final entry in englishEntries.entries) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('entry-${entry.key}')),
          matching: find.text(entry.value),
        ),
        findsOneWidget,
      );
    }

    tester.element(find.byType(HomeScreen)).read<AppCubit>().toggleLanguage();
    await tester.pumpAndSettle();
    const arabicEntries = {
      'exporter': 'أنا مصدر',
      'importer': 'أنا مستورد',
      'vehicles': 'السيارات',
      'jobs': 'الوظائف',
      'community': 'المجتمع',
      'leopard': 'Leopard',
    };
    for (final entry in arabicEntries.entries) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('entry-${entry.key}')),
          matching: find.text(entry.value),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('mobile navigation has five destinations in V4 order', (
    tester,
  ) async {
    await pumpAt(tester, 390);
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      nav.destinations
          .cast<NavigationDestination>()
          .map((destination) => destination.label)
          .toList(),
      ['Home', 'Discover', 'Community', 'Messages', 'My Account'],
    );

    for (var index = 0; index < nav.destinations.length; index++) {
      nav.onDestinationSelected!(index);
      await tester.pumpAndSettle();
      final current = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(current.selectedIndex, index);
      expect(find.byType(NavigationBar), findsOneWidget);
      switch (index) {
        case 0:
          expect(
            find.byKey(const ValueKey('home-page-scroll')),
            findsOneWidget,
          );
        case 1:
          expect(
            find.byKey(const ValueKey('discover-page-scroll')),
            findsOneWidget,
          );
        case 2:
          expect(
            find.text(
              'The community area is an initial UI. No sample posts are available.',
            ),
            findsWidgets,
          );
        case 3:
          expect(find.textContaining('Initial messages UI.'), findsWidgets);
        case 4:
          expect(
            find.textContaining('You are browsing as a visitor.'),
            findsWidgets,
          );
      }
    }
  });

  testWidgets('entry point cards open a real initial destination', (
    tester,
  ) async {
    await pumpAt(tester, 390);
    await tester.tap(find.text("I'm an Exporter"));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'An initial exporter workspace for exploring sectors, products and markets.',
      ),
      findsOneWidget,
    );
    expect(find.text('Initial UI · local preview'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-page-scroll')), findsOneWidget);
  });

  testWidgets('desktop navigation links open matching destinations', (
    tester,
  ) async {
    await pumpAt(tester, 1280);
    await tester.tap(find.text('Community').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The community area is an initial UI. No sample posts are available.',
      ),
      findsWidgets,
    );
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Initial messages UI.'), findsWidgets);
    await tester.tap(find.text('My Account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('You are browsing as a visitor.'), findsWidgets);
  });

  testWidgets('Arabic navigation labels and direction are applied', (
    tester,
  ) async {
    await pumpAt(tester, 390);
    tester.element(find.byType(HomeScreen)).read<AppCubit>().toggleLanguage();
    await tester.pumpAndSettle();
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      nav.destinations
          .cast<NavigationDestination>()
          .map((destination) => destination.label)
          .toList(),
      ['الرئيسية', 'اكتشف', 'المجتمع', 'الرسائل', 'حسابي'],
    );
    expect(
      Directionality.of(tester.element(find.text('الرئيسية'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Home fits supported responsive widths in English and Arabic', (
    tester,
  ) async {
    const widths = [360.0, 390.0, 768.0, 1280.0, 1440.0];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in widths) {
      for (final arabic in [false, true]) {
        await pumpAt(tester, width);
        if (arabic) {
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
        final horizontalScrollables = tester
            .widgetList<Scrollable>(find.byType(Scrollable))
            .where(
              (scrollable) =>
                  scrollable.restorationId != 'editable' &&
                      scrollable.axisDirection == AxisDirection.left ||
                  scrollable.restorationId != 'editable' &&
                      scrollable.axisDirection == AxisDirection.right,
            );
        expect(
          errors,
          isEmpty,
          reason: 'Home layout at ${width.toInt()}px, RTL=$arabic',
        );
        expect(
          horizontalScrollables,
          isEmpty,
          reason: 'No horizontal scrolling at ${width.toInt()}px, RTL=$arabic',
        );
      }
    }
  });
}
