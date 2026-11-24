import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/local_workspace.dart';
import 'admin_workspace.dart';
import 'commercial_board.dart';
import 'directory_workspace.dart';
import 'quote_workspace.dart';
import 'user_guides.dart';
import 'workspace_widgets.dart';

class MessagesWorkspace extends StatelessWidget {
  const MessagesWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LocalWorkspace, WorkspaceState>(
        bloc: workspace,
        builder: (context, state) => WorkspacePage(
          title: copy.messagesTab,
          children: [
            WorkspaceNotice(
              copy: copy,
              message: copy.local(
                'Sample threads and unsent drafts for this session.',
                'محادثات توضيحية ومسودات غير مرسلة لهذه الجلسة.',
              ),
            ),
            for (final (id, title) in [
              (
                'thread-freight',
                copy.local(
                  'Sample freight planning conversation',
                  'محادثة تخطيط شحن توضيحية',
                ),
              ),
              (
                'thread-product',
                copy.local(
                  'Sample product inquiry conversation',
                  'محادثة استفسار منتج توضيحية',
                ),
              ),
            ])
              if (!state.blocked.contains(id))
                WorkspaceLink(
                  label: title,
                  onTap: () => _conversation(context, id, title),
                ),
            if (state.blocked.containsAll({'thread-freight', 'thread-product'}))
              Text(
                copy.local(
                  'No visible conversations.',
                  'لا توجد محادثات ظاهرة.',
                ),
              ),
          ],
        ),
      );

  void _conversation(
    BuildContext context,
    String id,
    String title,
  ) => openWorkspace(
    context,
    WorkspacePage(
      title: title,
      children: [
        WorkspaceNotice(
          copy: copy,
          message: copy.local(
            'Fictional conversation. Recipient identity is unavailable.',
            'محادثة خيالية. هوية المستلم غير متاحة.',
          ),
        ),
        ContentPanel(
          title: copy.local('Example message', 'رسالة توضيحية'),
          children: [
            Text(
              id == 'thread-freight'
                  ? copy.local(
                      'Could you confirm the route and service scope for review?',
                      'هل يمكنك تأكيد المسار ونطاق الخدمة للمراجعة؟',
                    )
                  : copy.local(
                      'Could you share the product specification for review?',
                      'هل يمكنك مشاركة مواصفات المنتج للمراجعة؟',
                    ),
            ),
          ],
        ),
        TextFormField(
          key: const ValueKey('local-message-draft'),
          initialValue: workspace.state.drafts[id] ?? '',
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: copy.local(
              'Unsent local draft',
              'مسودة محلية غير مرسلة',
            ),
          ),
          onChanged: (value) => workspace.draft(id, value),
        ),
        Builder(
          builder: (context) => WorkspaceLink(
            label: copy.local(
              'Review delivery requirement',
              'راجع متطلبات الإرسال',
            ),
            onTap: () => guestPreview(
              context,
              copy,
              copy.local('Message delivery preview', 'معاينة إرسال الرسالة'),
            ),
          ),
        ),
        ReportWorkspaceLink(
          copy: copy,
          workspace: workspace,
          id: id,
          title: title,
        ),
        BlocBuilder<LocalWorkspace, WorkspaceState>(
          bloc: workspace,
          builder: (context, state) => WorkspaceLink(
            label: state.blocked.contains(id)
                ? copy.local(
                    'Unhide sample conversation',
                    'أظهر المحادثة التوضيحية',
                  )
                : copy.local(
                    'Hide sample conversation',
                    'أخفِ المحادثة التوضيحية',
                  ),
            onTap: () => workspace.toggleBlocked(id),
          ),
        ),
      ],
    ),
  );
}

class AccountWorkspace extends StatelessWidget {
  const AccountWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
    required this.onToggleLanguage,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;
  final VoidCallback onToggleLanguage;

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.myAccountTab,
    children: [
      WorkspaceNotice(copy: copy, message: copy.accountDescription),
      AdaptiveGrid(
        children: [
          WorkspaceLink(
            label: copy.local(
              'Walkthrough and glossary',
              'دليل الاستخدام والمصطلحات',
            ),
            onTap: () => openWorkspace(context, UserGuides(copy: copy)),
          ),
          WorkspaceLink(
            label: copy.local('Saved items', 'المحفوظات'),
            onTap: () => openWorkspace(
              context,
              SavedWorkspace(copy: copy, workspace: workspace),
            ),
          ),
          WorkspaceLink(
            label: copy.local(
              'Profile management preview',
              'معاينة إدارة الملف',
            ),
            onTap: () => _profile(context),
          ),
          WorkspaceLink(
            label: copy.local('Notification preferences', 'تفضيلات الإشعارات'),
            onTap: () => _settings(context, privacy: false),
          ),
          WorkspaceLink(
            label: copy.local(
              'Privacy and blocked sources',
              'الخصوصية والمصادر المخفية',
            ),
            onTap: () => _settings(context, privacy: true),
          ),
          WorkspaceLink(
            label: copy.local(
              'Resume freight quotation draft',
              'استأنف مسودة طلب سعر الشحن',
            ),
            onTap: () => openWorkspace(
              context,
              QuoteWorkspace(copy: copy, workspace: workspace),
            ),
          ),
          WorkspaceLink(
            label: copy.local('Administration preview', 'معاينة الإدارة'),
            onTap: () => openWorkspace(
              context,
              AdminWorkspace(copy: copy, workspace: workspace),
            ),
          ),
          WorkspaceLink(
            label: copy.local(
              'Language · Switch to Arabic',
              'اللغة · انتقل إلى الإنجليزية',
            ),
            icon: Icons.language,
            onTap: () {
              Navigator.of(context).pop();
              onToggleLanguage();
            },
          ),
        ],
      ),
    ],
  );

  void _profile(BuildContext context) => openWorkspace(
    context,
    WorkspacePage(
      title: copy.local('Profile management preview', 'معاينة إدارة الملف'),
      children: [
        WorkspaceNotice(
          copy: copy,
          message: copy.local(
            'Use sample profile text for this session.',
            'استخدم نص ملف توضيحي لهذه الجلسة.',
          ),
        ),
        for (final (id, title) in [
          ('profile-role', copy.local('Professional role', 'الدور المهني')),
          (
            'profile-summary',
            copy.local('Business profile summary', 'ملخص الملف التجاري'),
          ),
        ])
          TextFormField(
            initialValue: workspace.state.drafts[id] ?? '',
            decoration: InputDecoration(labelText: title),
            onChanged: (value) => workspace.draft(id, value),
          ),
        Builder(
          builder: (context) => WorkspaceLink(
            label: copy.local(
              'Review publication requirement',
              'راجع متطلبات النشر',
            ),
            onTap: () => guestPreview(
              context,
              copy,
              copy.local('Profile publication preview', 'معاينة نشر الملف'),
            ),
          ),
        ),
      ],
    ),
  );

  void _settings(
    BuildContext context, {
    required bool privacy,
  }) => openWorkspace(
    context,
    BlocBuilder<LocalWorkspace, WorkspaceState>(
      bloc: workspace,
      builder: (context, state) => WorkspacePage(
        title: privacy
            ? copy.local(
                'Privacy and blocked sources',
                'الخصوصية والمصادر المخفية',
              )
            : copy.local('Notification preferences', 'تفضيلات الإشعارات'),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'Preference changes apply to this preview session.',
              'تطبق تغييرات التفضيلات على جلسة المعاينة.',
            ),
          ),
          for (final (id, title)
              in privacy
                  ? [
                      (
                        'profile-visible',
                        copy.local(
                          'Show profile in public search preview',
                          'أظهر الملف في معاينة البحث العام',
                        ),
                      ),
                      (
                        'requests-visible',
                        copy.local(
                          'Allow contact request preview',
                          'اسمح بمعاينة طلبات التواصل',
                        ),
                      ),
                    ]
                  : [
                      (
                        'quotation-alerts',
                        copy.local('Quotation updates', 'تحديثات عروض الأسعار'),
                      ),
                      (
                        'message-alerts',
                        copy.local('Message reminders', 'تذكيرات الرسائل'),
                      ),
                    ])
            ContentPanel(
              children: [
                SwitchListTile(
                  title: Text(title),
                  value: state.preferences[id] ?? false,
                  onChanged: (value) => workspace.preference(id, value),
                ),
              ],
            ),
          if (privacy)
            ContentPanel(
              title: copy.local('Hidden sources', 'المصادر المخفية'),
              children: [
                if (state.blocked.isEmpty)
                  Text(
                    copy.local('No hidden sources.', 'لا توجد مصادر مخفية.'),
                  ),
                for (final id in state.blocked)
                  WorkspaceLink(
                    label: copy.local('Unhide $id', 'أظهر $id'),
                    onTap: () => workspace.toggleBlocked(id),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}
