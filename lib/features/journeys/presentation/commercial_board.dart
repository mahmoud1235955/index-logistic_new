import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/commercial_models.dart';
import '../domain/local_workspace.dart';
import 'workspace_widgets.dart';

String commercialTypeLabel(AppCopy copy, CommercialType type) => switch (type) {
  CommercialType.buying => copy.local('Buying requests', 'طلبات الشراء'),
  CommercialType.selling => copy.local('Selling offers', 'عروض البيع'),
  CommercialType.opportunity => copy.local(
    'Export opportunities',
    'فرص التصدير',
  ),
  CommercialType.logistics => copy.local(
    'Logistics requests',
    'طلبات الخدمات اللوجستية',
  ),
  CommercialType.question => copy.local(
    'Professional questions',
    'الأسئلة المهنية',
  ),
  CommercialType.announcement => copy.local(
    'Business announcements',
    'إعلانات الأعمال',
  ),
};

String reportLabel(AppCopy copy, ReportReason reason) => switch (reason) {
  ReportReason.inaccurate => copy.local(
    'Potentially inaccurate',
    'قد يكون غير دقيق',
  ),
  ReportReason.inappropriate => copy.local(
    'Inappropriate content',
    'محتوى غير ملائم',
  ),
  ReportReason.unwanted => copy.local('Unwanted contact', 'تواصل غير مرغوب'),
};

typedef CommercialPost = ({
  CommercialType type,
  String english,
  String arabic,
  String detail,
  String detailAr,
});

const _posts = <CommercialPost>[
  (
    type: CommercialType.buying,
    english: 'Sample fruit purchase request',
    arabic: 'طلب شراء فاكهة توضيحي',
    detail:
        'An example buyer requests product specifications, origin and indicative lead time.',
    detailAr: 'يطلب المشتري التوضيحي مواصفات المنتج والمنشأ والمدة المبدئية.',
  ),
  (
    type: CommercialType.selling,
    english: 'Sample textile selling offer',
    arabic: 'عرض بيع منسوجات توضيحي',
    detail:
        'An example supplier describes a textile category and asks for a specification review.',
    detailAr: 'يصف المورد التوضيحي فئة منسوجات ويطلب مراجعة المواصفات.',
  ),
  (
    type: CommercialType.opportunity,
    english: 'Sample market research opportunity',
    arabic: 'فرصة بحث سوق توضيحية',
    detail:
        'Review the demonstration scope. Current market demand, buyer identity and validity are unavailable.',
    detailAr:
        'راجع النطاق التوضيحي. الطلب الحالي وهوية المشتري وصلاحية الفرصة غير متاحة.',
  ),
  (
    type: CommercialType.logistics,
    english: 'Sample freight planning request',
    arabic: 'طلب تخطيط شحن توضيحي',
    detail:
        'An example shipper asks about preparing route, package and service details.',
    detailAr: 'يستفسر الشاحن التوضيحي عن تجهيز تفاصيل المسار والطرود والخدمات.',
  ),
  (
    type: CommercialType.question,
    english: 'Sample question about trade terms',
    arabic: 'سؤال توضيحي عن شروط التجارة',
    detail:
        'An example question asks how to document the agreed delivery place.',
    detailAr: 'يسأل المثال عن طريقة توثيق مكان التسليم المتفق عليه.',
  ),
  (
    type: CommercialType.announcement,
    english: 'Sample business announcement',
    arabic: 'إعلان أعمال توضيحي',
    detail:
        'This record illustrates the information a business announcement could contain.',
    detailAr: 'يوضح السجل المعلومات التي يمكن أن يتضمنها إعلان أعمال.',
  ),
];

typedef _BoardFilter = ({CommercialType? type, String search});

class _BoardCubit extends Cubit<_BoardFilter> {
  _BoardCubit(CommercialType? type) : super((type: type, search: ''));
  void filter(CommercialType? type) => emit((type: type, search: state.search));
  void search(String search) => emit((type: state.type, search: search));
}

class CommercialBoard extends StatelessWidget {
  const CommercialBoard({
    super.key,
    required this.copy,
    required this.workspace,
    this.initialType,
    this.embedded = false,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;
  final CommercialType? initialType;
  final bool embedded;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _BoardCubit(initialType),
    child: BlocBuilder<_BoardCubit, _BoardFilter>(
      builder: (context, filter) => BlocBuilder<LocalWorkspace, WorkspaceState>(
        bloc: workspace,
        builder: (context, local) {
          final cubit = context.read<_BoardCubit>();
          final posts = _posts
              .where(
                (post) =>
                    !local.blocked.contains(post.type.name) &&
                    (filter.type == null || filter.type == post.type) &&
                    '${post.english} ${post.arabic}'.toLowerCase().contains(
                      filter.search.trim().toLowerCase(),
                    ),
              )
              .toList();
          return WorkspacePage(
            title: initialType == null
                ? copy.communityTab
                : commercialTypeLabel(copy, initialType!),
            embedded: embedded,
            children: [
              WorkspaceNotice(
                copy: copy,
                message: copy.local(
                  'Fictional commercial examples. Member identity and activity are unavailable.',
                  'أمثلة تجارية خيالية. هوية الأعضاء ونشاطهم غير متاحين.',
                ),
              ),
              WorkspaceSelect(
                title: copy.local('Content type', 'نوع المحتوى'),
                options: CommercialType.values,
                selected: filter.type,
                canClear: true,
                copy: copy,
                label: (type) => commercialTypeLabel(copy, type),
                onChanged: cubit.filter,
              ),
              TextField(
                onChanged: cubit.search,
                decoration: InputDecoration(
                  labelText: copy.local(
                    'Search commercial content',
                    'ابحث في المحتوى التجاري',
                  ),
                ),
              ),
              if (posts.isEmpty) ContentPanel(children: [Text(copy.noResults)]),
              for (final post in posts)
                ContentPanel(
                  title: commercialTypeLabel(copy, post.type),
                  children: [
                    WorkspaceLink(
                      label: copy.local(post.english, post.arabic),
                      onTap: () => _detail(context, post),
                    ),
                  ],
                ),
              WorkspaceLink(
                label: copy.local(
                  'Structured submission preview',
                  'معاينة إضافة محتوى منظم',
                ),
                onTap: () => openWorkspace(
                  context,
                  StructuredSubmission(copy: copy, type: filter.type),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  void _detail(BuildContext context, CommercialPost post) {
    final title = copy.local(post.english, post.arabic);
    openWorkspace(
      context,
      BlocBuilder<LocalWorkspace, WorkspaceState>(
        bloc: workspace,
        builder: (context, state) => WorkspacePage(
          title: title,
          children: [
            WorkspaceNotice(copy: copy),
            ContentPanel(
              title: commercialTypeLabel(copy, post.type),
              children: [Text(copy.local(post.detail, post.detailAr))],
            ),
            ReportWorkspaceLink(
              copy: copy,
              workspace: workspace,
              id: post.type.name,
              title: title,
            ),
            WorkspaceLink(
              label: state.blocked.contains(post.type.name)
                  ? copy.local('Unhide sample source', 'أظهر المصدر التوضيحي')
                  : copy.local('Hide sample source', 'أخفِ المصدر التوضيحي'),
              onTap: () => workspace.toggleBlocked(post.type.name),
            ),
            WorkspaceLink(
              label: copy.local('Respond preview', 'معاينة الرد'),
              onTap: () => guestPreview(
                context,
                copy,
                copy.local('Respond preview', 'معاينة الرد'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportWorkspaceLink extends StatelessWidget {
  const ReportWorkspaceLink({
    super.key,
    required this.copy,
    required this.workspace,
    required this.id,
    required this.title,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;
  final String id, title;

  @override
  Widget build(BuildContext context) => WorkspaceLink(
    label: copy.local('Report preview', 'معاينة الإبلاغ'),
    icon: Icons.flag_outlined,
    onTap: () => openWorkspace(
      context,
      WorkspacePage(
        title: copy.local('Report preview', 'معاينة الإبلاغ'),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'Reports remain available in the local moderation preview.',
              'تظل البلاغات متاحة في معاينة الإشراف المحلية.',
            ),
          ),
          for (final reason in ReportReason.values)
            Builder(
              builder: (context) => WorkspaceLink(
                label: reportLabel(copy, reason),
                onTap: () {
                  workspace.report((id: id, subject: title, reason: reason));
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    ),
  );
}

class StructuredSubmission extends StatelessWidget {
  const StructuredSubmission({super.key, required this.copy, this.type});
  final AppCopy copy;
  final CommercialType? type;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _BoardCubit(type),
    child: BlocBuilder<_BoardCubit, _BoardFilter>(
      builder: (context, draft) => WorkspacePage(
        title: copy.local(
          'Structured submission preview',
          'معاينة إضافة محتوى منظم',
        ),
        children: [
          WorkspaceNotice(copy: copy),
          WorkspaceSelect(
            title: copy.local('Content type', 'نوع المحتوى'),
            options: CommercialType.values,
            selected: draft.type,
            copy: copy,
            label: (value) => commercialTypeLabel(copy, value),
            onChanged: context.read<_BoardCubit>().filter,
          ),
          if (draft.type case final selected?) ...[
            for (final label in [
              copy.local('Subject', 'الموضوع'),
              if (selected == CommercialType.buying ||
                  selected == CommercialType.selling ||
                  selected == CommercialType.opportunity)
                copy.local('Product and market', 'المنتج والسوق'),
              if (selected == CommercialType.logistics)
                copy.local('Route and service', 'المسار والخدمة'),
              copy.local('Details for review', 'تفاصيل للمراجعة'),
            ])
              TextFormField(
                key: ValueKey((selected, label)),
                decoration: InputDecoration(labelText: label),
              ),
            WorkspaceLink(
              label: copy.local(
                'Review account requirement',
                'راجع متطلبات الحساب',
              ),
              onTap: () => guestPreview(
                context,
                copy,
                commercialTypeLabel(copy, selected),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
