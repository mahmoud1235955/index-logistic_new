import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/journeys/domain/commercial_models.dart';
import 'package:index_logistic/features/journeys/domain/local_workspace.dart';
import 'package:index_logistic/features/journeys/presentation/account_workspace.dart';
import 'package:index_logistic/features/journeys/presentation/leopard_workspace.dart';

const copy = AppCopy(AppLanguage.english);

void main() {
  testWidgets(
    'message composition retains an unsent draft and gates delivery',
    (tester) async {
      final workspace = LocalWorkspace();
      addTearDown(workspace.close);
      await tester.pumpWidget(
        MaterialApp(
          home: MessagesWorkspace(copy: copy, workspace: workspace),
        ),
      );
      await tester.tap(find.text('Sample freight planning conversation'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('local-message-draft')),
        'Review only',
      );
      await tester.pump();
      expect(workspace.state.drafts['thread-freight'], 'Review only');
      await tester.tap(find.text('Review delivery requirement'));
      await tester.pumpAndSettle();
      expect(find.textContaining('requires an account'), findsOneWidget);
    },
  );

  testWidgets(
    'account previews expose administrator cases without staff access',
    (tester) async {
      final workspace = LocalWorkspace();
      addTearDown(workspace.close);
      workspace.report((
        id: 'sample',
        subject: 'Sample report subject',
        reason: ReportReason.inaccurate,
      ));
      await tester.pumpWidget(
        MaterialApp(
          home: AccountWorkspace(
            copy: copy,
            workspace: workspace,
            onToggleLanguage: () {},
          ),
        ),
      );
      await tester.tap(find.text('Administration preview'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('require server authorization'),
        findsOneWidget,
      );
      await tester.tap(find.text('User reports'));
      await tester.pumpAndSettle();
      expect(find.text('Sample report subject'), findsOneWidget);
    },
  );

  testWidgets('Leopard copies only the feed product name after consent', (
    tester,
  ) async {
    final workspace = LocalWorkspace();
    addTearDown(workspace.close);
    await tester.pumpWidget(
      MaterialApp(
        home: LeopardWorkspace(copy: copy, workspace: workspace),
      ),
    );
    await tester.ensureVisible(find.text('Feed trade preparation'));
    await tester.tap(find.text('Feed trade preparation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alfalfa'));
    await tester.pumpAndSettle();
    final action = find.text('Use product name in freight draft');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(workspace.state.quote, isNull);
    await tester.tap(find.text('Copy name'));
    await tester.pumpAndSettle();
    expect(workspace.state.quote!.fields, {QuoteField.cargo: 'Alfalfa'});
  });
}
