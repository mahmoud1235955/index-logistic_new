import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/features/access/domain/access_flow.dart';
import 'package:index_logistic/features/access/presentation/auth_preview_screen.dart';
import 'package:index_logistic/features/access/presentation/welcome_screen.dart';
import 'package:index_logistic/features/home/presentation/home_screen.dart';

void main() {
  Future<void> setViewport(
    WidgetTester tester,
    double width, {
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    await tester.pumpWidget(const IndexLogisticsApp(showSplash: true));
    await tester.pumpAndSettle();
  }

  testWidgets('startup opens welcome without a timed splash delay', (
    tester,
  ) async {
    await setViewport(tester, 390);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Welcome to Index Logistics'), findsOneWidget);
  });

  testWidgets('guest continues to the existing public Home screen', (
    tester,
  ) async {
    await setViewport(tester, 390);
    await tester.tap(find.byKey(const ValueKey('continue-as-guest')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('home-page-scroll')), findsOneWidget);
  });

  testWidgets('welcome language switch applies Arabic copy and RTL direction', (
    tester,
  ) async {
    await setViewport(tester, 390);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('مرحباً بك في إندكس لوجيستكس'), findsOneWidget);
    expect(find.text('المتابعة كزائر'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('المتابعة كزائر'))),
      TextDirection.rtl,
    );
  });

  testWidgets('account screens retain Arabic RTL navigation copy', (
    tester,
  ) async {
    await setViewport(tester, 390);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إنشاء حساب'));
    await tester.pumpAndSettle();
    final heading = find.text('إنشاء حساب').first;
    expect(heading, findsOneWidget);
    expect(Directionality.of(tester.element(heading)), TextDirection.rtl);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
  });

  testWidgets(
    'account preview flow does not claim to send or verify credentials',
    (tester) async {
      await setViewport(tester, 390);
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.byType(AuthPreviewScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Demo User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'demo@example.test',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'sample-pass-123',
      );
      await tester.ensureVisible(find.text('Continue preview').first);
      await tester.tap(find.text('Continue preview').first);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No verification code is sent'),
        findsOneWidget,
      );

      await tester.tap(find.text('Account UI preview'));
      await tester.pumpAndSettle();
      expect(find.text('Account type'), findsOneWidget);
      await tester.tap(find.byType(RadioListTile<AccountType>).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue preview'));
      await tester.tap(find.text('Continue preview'));
      await tester.pumpAndSettle();
      expect(find.text('Profile setup'), findsOneWidget);
      expect(find.textContaining('will not be stored or sent'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Demo User');
      await tester.ensureVisible(find.text('Continue preview'));
      await tester.tap(find.text('Continue preview'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No account was created'), findsOneWidget);
    },
  );

  testWidgets(
    'sign-in and recovery are explicitly unavailable local previews',
    (tester) async {
      await setViewport(tester, 390);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'demo@example.test',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'sample-pass-123',
      );
      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('no account service is connected'),
        findsOneWidget,
      );

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'demo@example.test',
      );
      await tester.ensureVisible(find.text('Continue preview'));
      await tester.tap(find.text('Continue preview'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('no recovery message was sent'),
        findsOneWidget,
      );
    },
  );

  testWidgets('welcome layout supports required widths and 200% text scaling', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    const widths = [360.0, 390.0, 768.0, 1280.0, 1440.0];
    for (final width in widths) {
      for (final scale in [1.0, 2.0]) {
        await setViewport(tester, width, scale: scale);
        expect(
          tester.takeException(),
          isNull,
          reason: 'width=$width scale=$scale',
        );
        final scrollables = tester.widgetList<Scrollable>(
          find.byType(Scrollable),
        );
        expect(
          scrollables.where(
            (item) =>
                item.axisDirection == AxisDirection.left ||
                item.axisDirection == AxisDirection.right,
          ),
          isEmpty,
          reason: 'welcome horizontal scroll at $width',
        );
        expect(find.byType(WelcomeScreen), findsOneWidget);
      }
    }
  });

  testWidgets('sign-in layout supports required widths and 200% text scaling', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    const widths = [360.0, 390.0, 768.0, 1280.0, 1440.0];
    for (final width in widths) {
      await setViewport(tester, width, scale: 2);
      await tester.ensureVisible(find.text('Sign in').last);
      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();
      expect(find.byType(AuthPreviewScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'width=$width');
      final horizontalScrollables = tester
          .widgetList<Scrollable>(find.byType(Scrollable))
          .where(
            (scrollable) =>
                scrollable.restorationId != 'editable' &&
                (scrollable.axisDirection == AxisDirection.left ||
                    scrollable.axisDirection == AxisDirection.right),
          );
      expect(horizontalScrollables, isEmpty, reason: 'width=$width');
    }
  });
}
