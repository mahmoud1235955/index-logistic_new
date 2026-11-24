import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/directory/domain/company.dart';
import 'package:index_logistic/features/home/data/home_mock_data.dart';
import 'package:index_logistic/features/home/domain/home_repository.dart';
import 'package:index_logistic/features/home/domain/sector.dart';
import 'package:index_logistic/features/home/presentation/cubit/home_cubit.dart';
import 'package:index_logistic/features/home/presentation/cubit/home_state.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

Future<void> scrollHomeTo(WidgetTester tester, Finder target) async {
  final viewport = find.byKey(const ValueKey('home-page-scroll'));
  for (var attempt = 0; attempt < 12; attempt++) {
    final targetRect = tester.getRect(target);
    final viewportRect = tester.getRect(viewport);
    if (targetRect.top >= viewportRect.top &&
        targetRect.bottom <= viewportRect.bottom) {
      return;
    }
    final delta = targetRect.center.dy > viewportRect.bottom ? -480.0 : 480.0;
    await tester.drag(viewport, Offset(0, delta));
    await tester.pumpAndSettle();
  }
  fail('Could not scroll Home target into view: $target');
}

void main() {
  test(
    'local mock scenarios map to all applicable repository states',
    () async {
      const scenarios = {
        HomeMockScenario.empty: HomeStatus.empty,
        HomeMockScenario.error: HomeStatus.error,
        HomeMockScenario.offline: HomeStatus.offline,
        HomeMockScenario.expired: HomeStatus.expired,
        HomeMockScenario.permissionDenied: HomeStatus.permissionDenied,
      };
      for (final entry in scenarios.entries) {
        final cubit = HomeCubit(HomeMockData(scenario: entry.key));
        await cubit.loadHome();
        expect(cubit.state.status, entry.value);
        await cubit.close();
      }
    },
  );

  testWidgets('Retry reruns the local repository operation and recovers', (
    tester,
  ) async {
    final repository = _FailsOnceRepository();
    final cubit = HomeCubit(repository);
    await cubit.loadHome();
    expect(cubit.state.status, HomeStatus.error);
    expect(repository.sectorReads, 1);

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: HomeScreen(
            language: AppLanguage.english,
            onToggleLanguage: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final retry = find.text('Try again');
    await scrollHomeTo(tester, retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(repository.sectorReads, 2);
    expect(cubit.state.status, HomeStatus.loaded);
    expect(find.byKey(const ValueKey('sector-SEC-01')), findsOneWidget);
    await cubit.close();
  });

  testWidgets(
    'Discover search filters local records and empty recovery clears it',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const IndexLogisticsApp());
      await tester.pumpAndSettle();

      tester
          .widget<NavigationBar>(find.byType(NavigationBar))
          .onDestinationSelected!(1);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Meridian');
      await tester.pumpAndSettle();
      expect(find.text('Meridian Foods Co.'), findsOneWidget);
      expect(find.text('Northstar Freight'), findsNothing);

      await tester.enterText(find.byType(TextField), 'no matching fixture');
      await tester.pumpAndSettle();
      expect(find.text('No matching results.'), findsOneWidget);
      await tester.tap(find.text('Clear search'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sector-SEC-01')), findsOneWidget);
      expect(find.text('Northstar Freight'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    },
  );

  testWidgets('expired and permission states recover to Home', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const recoveryCases = {
      HomeMockScenario.expired: 'Preview expired',
      HomeMockScenario.permissionDenied: 'Permission unavailable',
    };

    for (final entry in recoveryCases.entries) {
      final cubit = HomeCubit(HomeMockData(scenario: entry.key));
      await cubit.loadHome();
      cubit.selectTab(1);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: HomeScreen(
              language: AppLanguage.english,
              onToggleLanguage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Home'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home-page-scroll')), findsOneWidget);
      await cubit.close();
    }
  });

  testWidgets('entry-point empty state opens local Discover', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("I'm an Exporter"));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to show yet'), findsOneWidget);
    await tester.tap(find.text('Explore sectors'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('discover-page-scroll')), findsOneWidget);
  });
}

class _FailsOnceRepository implements HomeRepository {
  int sectorReads = 0;

  @override
  Future<List<Sector>> getSectors() async {
    sectorReads++;
    if (sectorReads == 1) throw Exception('local demonstration failure');
    return HomeMockData.sectors;
  }

  @override
  Future<List<Company>> getFeaturedCompanies() async => HomeMockData.companies;
}
