import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import 'workspace_widgets.dart';

enum JobArea { freight, trade, consulting }

class _JobFilter extends Cubit<JobArea?> {
  _JobFilter(super.initialState);
  void select(JobArea? area) => emit(area);
}

class JobsWorkspace extends StatelessWidget {
  const JobsWorkspace({super.key, required this.copy, this.area});
  final AppCopy copy;
  final JobArea? area;

  String label(JobArea area) => switch (area) {
    JobArea.freight => copy.local('Freight operations', 'عمليات الشحن'),
    JobArea.trade => copy.local('Trade documentation', 'وثائق التجارة'),
    JobArea.consulting => copy.local(
      'Professional and consulting services',
      'الخدمات المهنية والاستشارية',
    ),
  };

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _JobFilter(area),
    child: BlocBuilder<_JobFilter, JobArea?>(
      builder: (context, filter) => WorkspacePage(
        title: copy.local(
          'Jobs and professional services',
          'الوظائف والخدمات المهنية',
        ),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'Fictional listings illustrate the journey.',
              'تعرض السجلات الخيالية مسار الاستخدام.',
            ),
          ),
          WorkspaceSelect(
            title: copy.local('Specialty', 'التخصص'),
            options: JobArea.values,
            selected: filter,
            canClear: true,
            copy: copy,
            label: label,
            onChanged: context.read<_JobFilter>().select,
          ),
          for (final item in JobArea.values)
            if (filter == null || item == filter)
              WorkspaceLink(
                label: label(item),
                onTap: () => _details(context, item),
              ),
          WorkspaceLink(
            label: copy.local(
              'Job seeker profile preview',
              'معاينة ملف الباحث عن عمل',
            ),
            onTap: () => _form(
              context,
              copy.local(
                'Job seeker profile preview',
                'معاينة ملف الباحث عن عمل',
              ),
              [
                copy.local('Professional headline', 'العنوان المهني'),
                copy.local('Skills and experience', 'المهارات والخبرة'),
              ],
            ),
          ),
          WorkspaceLink(
            label: copy.local('Job posting preview', 'معاينة نشر وظيفة'),
            onTap: () => _form(
              context,
              copy.local('Job posting preview', 'معاينة نشر وظيفة'),
              [
                copy.local('Role title', 'عنوان الوظيفة'),
                copy.local('Location', 'الموقع'),
                copy.local('Responsibilities', 'المسؤوليات'),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  void _details(BuildContext context, JobArea area) => openWorkspace(
    context,
    WorkspacePage(
      title: label(area),
      children: [
        WorkspaceNotice(copy: copy),
        ContentPanel(
          children: [
            LabelValue(copy.local('Scope', 'النطاق'), label(area)),
            LabelValue(copy.local('Availability', 'التوفر'), copy.unavailable),
          ],
        ),
        Builder(
          builder: (context) => WorkspaceLink(
            label: copy.local(
              'Employer profile preview',
              'معاينة ملف صاحب العمل',
            ),
            onTap: () => openWorkspace(
              context,
              previewResult(
                copy,
                copy.local('Employer profile preview', 'معاينة ملف صاحب العمل'),
                copy.local(
                  'Example organization profile. Employer identity and contact channels are unavailable.',
                  'ملف جهة توضيحي. هوية صاحب العمل وقنوات التواصل غير متاحة.',
                ),
              ),
            ),
          ),
        ),
        Builder(
          builder: (context) => WorkspaceLink(
            label: area == JobArea.consulting
                ? copy.local(
                    'Consultation request preview',
                    'معاينة طلب استشارة',
                  )
                : copy.local('Application preview', 'معاينة التقديم'),
            onTap: () => _form(
              context,
              copy.local('Expression of interest', 'إبداء اهتمام'),
              [
                copy.local(
                  'Relevant experience or service need',
                  'الخبرة ذات الصلة أو الخدمة المطلوبة',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  void _form(BuildContext context, String title, List<String> fields) =>
      openWorkspace(
        context,
        WorkspacePage(
          title: title,
          children: [
            WorkspaceNotice(copy: copy),
            for (final field in fields)
              TextField(decoration: InputDecoration(labelText: field)),
            Builder(
              builder: (context) => WorkspaceLink(
                label: copy.local(
                  'Review account requirement',
                  'راجع متطلبات الحساب',
                ),
                onTap: () => guestPreview(context, copy, title),
              ),
            ),
          ],
        ),
      );
}
