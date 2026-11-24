import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/adaptive_content.dart';

extension WorkspaceCopy on AppCopy {
  String local(String english, String arabic) => isArabic ? arabic : english;
  String get localPreview => local(
    'Local preview · Demonstration data',
    'معاينة محلية · بيانات توضيحية',
  );
}

Future<void> openWorkspace(BuildContext context, Widget page) =>
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({
    super.key,
    required this.title,
    required this.children,
    this.embedded = false,
  });
  final String title;
  final List<Widget> children;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (embedded)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                for (final child in children)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space3),
                    child: child,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    return embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: Text(title)),
            body: SafeArea(child: body),
          );
  }
}

class WorkspaceNotice extends StatelessWidget {
  const WorkspaceNotice({super.key, required this.copy, this.message});
  final AppCopy copy;
  final String? message;

  @override
  Widget build(BuildContext context) => ContentPanel(
    highlight: true,
    children: [Text(copy.localPreview), if (message != null) Text(message!)],
  );
}

class WorkspaceLink extends StatelessWidget {
  const WorkspaceLink({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.arrow_forward_ios,
  });
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: AppTokens.white,
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.all(AppTokens.space3),
    ),
    onPressed: onTap,
    child: Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: AppTokens.space2),
        Icon(icon, size: 17),
      ],
    ),
  );
}

class WorkspaceSelect<T extends Object> extends StatelessWidget {
  const WorkspaceSelect({
    super.key,
    required this.title,
    required this.options,
    required this.label,
    required this.onChanged,
    required this.copy,
    this.selected,
    this.canClear = false,
  });
  final String title;
  final Iterable<T> options;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;
  final AppCopy copy;
  final T? selected;
  final bool canClear;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      WorkspaceLink(
        label: selected == null
            ? canClear
                  ? copy.local('All', 'الكل')
                  : copy.local('Select', 'اختر')
            : label(selected!),
        icon: Icons.expand_more,
        onTap: () async {
          final result = await showDialog<({T? value})>(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(title),
              children: [
                if (canClear)
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(AppTokens.space4),
                    onPressed: () => Navigator.of(context).pop((value: null)),
                    child: Text(copy.local('All', 'الكل')),
                  ),
                for (final option in options)
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(AppTokens.space4),
                    onPressed: () => Navigator.of(context).pop((value: option)),
                    child: Text(label(option)),
                  ),
              ],
            ),
          );
          if (context.mounted && result != null) onChanged(result.value);
        },
      ),
    ],
  );
}

Widget previewResult(AppCopy copy, String title, String description) =>
    WorkspacePage(
      title: title,
      children: [WorkspaceNotice(copy: copy, message: description)],
    );

void guestPreview(
  BuildContext context,
  AppCopy copy,
  String title,
) => openWorkspace(
  context,
  previewResult(
    copy,
    title,
    copy.local(
      'This action requires an account in the live product. This preview records no submission.',
      'يتطلب هذا الإجراء حسابًا في المنتج الفعلي. لا تسجّل هذه المعاينة أي إرسال.',
    ),
  ),
);
