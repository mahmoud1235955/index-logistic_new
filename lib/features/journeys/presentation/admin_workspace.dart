import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/local_workspace.dart';
import 'commercial_board.dart';
import 'workspace_widgets.dart';

enum _AdminArea {
  company,
  verification,
  moderation,
  reports,
  restrictions,
  appeals,
  audit,
  sources,
}

class AdminWorkspace extends StatelessWidget {
  const AdminWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;

  String _title(_AdminArea area) => switch (area) {
    _AdminArea.company => copy.local(
      'Company profile review',
      'مراجعة ملف الشركة',
    ),
    _AdminArea.verification => copy.local(
      'Data verification',
      'التحقق من البيانات',
    ),
    _AdminArea.moderation => copy.local(
      'Content moderation',
      'الإشراف على المحتوى',
    ),
    _AdminArea.reports => copy.local('User reports', 'بلاغات المستخدمين'),
    _AdminArea.restrictions => copy.local(
      'Evidence-based restrictions',
      'القيود القائمة على الأدلة',
    ),
    _AdminArea.appeals => copy.local('Appeals', 'التظلمات'),
    _AdminArea.audit => copy.local('Audit history', 'سجل التدقيق'),
    _AdminArea.sources => copy.local(
      'Data source management',
      'إدارة مصادر البيانات',
    ),
  };

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local('Administration preview', 'معاينة الإدارة'),
    children: [
      WorkspaceNotice(
        copy: copy,
        message: copy.local(
          'Training views illustrate staff workflows. Administrative access and actions require server authorization.',
          'تعرض الشاشات التدريبية سير عمل الموظفين. تتطلب صلاحيات الإدارة وإجراءاتها تفويض الخادم.',
        ),
      ),
      AdaptiveGrid(
        children: [
          for (final area in _AdminArea.values)
            WorkspaceLink(
              label: _title(area),
              onTap: () => _open(context, area),
            ),
        ],
      ),
    ],
  );

  void _open(BuildContext context, _AdminArea area) => openWorkspace(
    context,
    BlocBuilder<LocalWorkspace, WorkspaceState>(
      bloc: workspace,
      builder: (context, state) => WorkspacePage(
        title: _title(area),
        children: [
          WorkspaceNotice(copy: copy),
          switch (area) {
            _AdminArea.reports || _AdminArea.moderation => ContentPanel(
              children: [
                if (state.reports.isEmpty)
                  Text(
                    copy.local(
                      'No reports recorded in this session.',
                      'لا توجد بلاغات مسجلة في هذه الجلسة.',
                    ),
                  ),
                for (final report in state.reports)
                  LabelValue(report.subject, reportLabel(copy, report.reason)),
                Text(
                  copy.local(
                    'Protected evidence and moderation decisions require an authorized case record.',
                    'تتطلب الأدلة المحمية وقرارات الإشراف سجل قضية مصرحًا به.',
                  ),
                ),
              ],
            ),
            _AdminArea.restrictions => ContentPanel(
              children: [
                LabelValue(copy.local('Evidence', 'الأدلة'), copy.unavailable),
                LabelValue(
                  copy.local('Decision and scope', 'القرار والنطاق'),
                  copy.local(
                    'Pending authorized review',
                    'بانتظار مراجعة مخولة',
                  ),
                ),
                LabelValue(
                  copy.local(
                    'Effective date and expiry',
                    'تاريخ السريان والانتهاء',
                  ),
                  copy.unavailable,
                ),
              ],
            ),
            _AdminArea.appeals => ContentPanel(
              children: [
                LabelValue(
                  copy.local('Decision reference', 'مرجع القرار'),
                  copy.unavailable,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: copy.local(
                      'Example appeal grounds',
                      'أسباب تظلم توضيحية',
                    ),
                  ),
                ),
                Text(
                  copy.local(
                    'Submission and independent review require an authorized case.',
                    'يتطلب الإرسال والمراجعة المستقلة قضية مصرحًا بها.',
                  ),
                ),
              ],
            ),
            _AdminArea.audit => ContentPanel(
              children: [
                LabelValue(
                  copy.local('Recorded locally', 'مسجل محليًا'),
                  copy.local(
                    'Report drafts and display preferences',
                    'مسودات البلاغات وتفضيلات العرض',
                  ),
                ),
                LabelValue(
                  copy.local(
                    'Protected operational audit history',
                    'سجل التدقيق التشغيلي المحمي',
                  ),
                  copy.unavailable,
                ),
              ],
            ),
            _AdminArea.company ||
            _AdminArea.verification ||
            _AdminArea.sources => ContentPanel(
              children: [
                LabelValue(
                  copy.local('Record under review', 'السجل قيد المراجعة'),
                  copy.local('Demonstration record', 'سجل توضيحي'),
                ),
                LabelValue(
                  copy.local(
                    'Source, evidence and licence',
                    'المصدر والأدلة والترخيص',
                  ),
                  copy.unavailable,
                ),
                LabelValue(
                  copy.local('Review status', 'حالة المراجعة'),
                  copy.local('Verification pending', 'بانتظار التحقق'),
                ),
              ],
            ),
          },
        ],
      ),
    ),
  );
}
