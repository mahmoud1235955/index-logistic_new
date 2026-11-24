import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/state/app_view_state.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../../../core/widgets/app_state_panel.dart';
import '../../catalog/domain/service_category.dart';
import '../../directory/domain/company.dart';
import '../../home/domain/sector.dart';
import '../domain/commercial_models.dart';
import '../domain/local_workspace.dart';
import '../domain/reference_lookup.dart';
import 'commercial_board.dart';
import 'container_planner.dart';
import 'directory_workspace.dart';
import 'emissions_workspace.dart';
import 'jobs_workspace.dart';
import 'meeting_workspace.dart';
import 'payment_guides.dart';
import 'quote_workspace.dart';
import 'special_cargo_workspace.dart';
import 'user_guides.dart';
import 'workspace_widgets.dart';

typedef CatalogWorkspace = ({
  LocalWorkspace session,
  List<Sector> sectors,
  List<Company> companies,
});

class CategoryWorkspaceEntry extends StatelessWidget {
  const CategoryWorkspaceEntry({
    super.key,
    required this.copy,
    required this.category,
    required this.workspace,
  });
  final AppCopy copy;
  final ServiceCategory category;
  final CatalogWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final id = category.id;
    final (label, page) = switch (id) {
      'CAT-01' || 'CAT-02' => (
        copy.local('Open commercial directory', 'افتح الدليل التجاري'),
        DirectoryWorkspace(
          copy: copy,
          workspace: workspace.session,
          sectors: workspace.sectors,
          companies: workspace.companies,
          exporter: id == 'CAT-02',
          sectorsFirst: true,
        ),
      ),
      'CAT-24' => (
        copy.local(
          'Browse jobs and professional services',
          'تصفح الوظائف والخدمات المهنية',
        ),
        JobsWorkspace(copy: copy),
      ),
      'CAT-16' => (
        copy.local('Container planner', 'مخطط الحاويات'),
        ContainerPlanner(copy: copy),
      ),
      'CAT-25' => (
        copy.local('Time and meetings', 'التوقيت والاجتماعات'),
        MeetingWorkspace(copy: copy),
      ),
      'CAT-28' => (
        copy.local('International payment methods', 'طرق الدفع الدولية'),
        PaymentGuides(copy: copy),
      ),
      'CAT-30' => (
        copy.local('Emissions and CBAM', 'الانبعاثات وآلية CBAM'),
        EmissionsWorkspace(copy: copy),
      ),
      'CAT-33' => (
        copy.local('Special cargo preparation', 'تجهيز البضائع الخاصة'),
        SpecialCargoWorkspace(copy: copy),
      ),
      'CAT-34' => (
        copy.local('Cold chain preparation', 'تجهيز سلسلة التبريد'),
        ColdChainWorkspace(copy: copy),
      ),
      'CAT-27' => (
        copy.local('Freight quotation draft', 'مسودة طلب سعر الشحن'),
        QuoteWorkspace(copy: copy, workspace: workspace.session),
      ),
      'CAT-32' => (
        copy.local('Browse opportunity previews', 'تصفح معاينات الفرص'),
        CommercialBoard(
          copy: copy,
          workspace: workspace.session,
          initialType: CommercialType.opportunity,
        ),
      ),
      'CAT-35' => (
        copy.local(
          'Explore academy and advisory topics',
          'استكشف موضوعات الأكاديمية والاستشارات',
        ),
        _Academy(copy: copy),
      ),
      _ when _scopes.containsKey(id) => (
        copy.local('Open category filters', 'افتح مرشحات القسم'),
        ReferenceWorkspace(
          copy: copy,
          category: category,
          fields: _scopes[id]!,
        ),
      ),
      _ => ('', null),
    };
    return page == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: WorkspaceLink(
              key: const ValueKey('category-workspace-entry'),
              label: label,
              onTap: () => openWorkspace(context, page),
            ),
          );
  }
}

const _scopes = <String, List<ReferenceField>>{
  'CAT-04': [
    ReferenceField.country,
    ReferenceField.product,
    ReferenceField.service,
  ],
  'CAT-05': [
    ReferenceField.country,
    ReferenceField.product,
    ReferenceField.service,
  ],
  'CAT-06': [
    ReferenceField.country,
    ReferenceField.product,
    ReferenceField.source,
  ],
  'CAT-07': [
    ReferenceField.region,
    ReferenceField.permit,
    ReferenceField.service,
  ],
  'CAT-08': [
    ReferenceField.region,
    ReferenceField.destination,
    ReferenceField.equipment,
  ],
  'CAT-09': [
    ReferenceField.port,
    ReferenceField.destination,
    ReferenceField.carrier,
    ReferenceField.date,
  ],
  'CAT-10': [
    ReferenceField.airport,
    ReferenceField.destination,
    ReferenceField.carrier,
  ],
  'CAT-11': [
    ReferenceField.country,
    ReferenceField.destination,
    ReferenceField.equipment,
  ],
  'CAT-12': [
    ReferenceField.country,
    ReferenceField.destination,
    ReferenceField.service,
  ],
  'CAT-13': [
    ReferenceField.country,
    ReferenceField.destination,
    ReferenceField.product,
  ],
  'CAT-14': [
    ReferenceField.country,
    ReferenceField.region,
    ReferenceField.source,
  ],
  'CAT-15': [
    ReferenceField.country,
    ReferenceField.product,
    ReferenceField.organizer,
    ReferenceField.date,
  ],
  'CAT-17': [
    ReferenceField.country,
    ReferenceField.port,
    ReferenceField.permit,
  ],
  'CAT-18': [
    ReferenceField.product,
    ReferenceField.equipment,
    ReferenceField.service,
  ],
  'CAT-19': [
    ReferenceField.country,
    ReferenceField.service,
    ReferenceField.source,
  ],
  'CAT-20': [
    ReferenceField.country,
    ReferenceField.product,
    ReferenceField.service,
  ],
  'CAT-21': [
    ReferenceField.destination,
    ReferenceField.product,
    ReferenceField.date,
  ],
  'CAT-22': [
    ReferenceField.destination,
    ReferenceField.permit,
    ReferenceField.product,
  ],
  'CAT-23': [
    ReferenceField.destination,
    ReferenceField.product,
    ReferenceField.service,
  ],
  'CAT-26': [
    ReferenceField.currency,
    ReferenceField.date,
    ReferenceField.source,
  ],
  'CAT-29': [ReferenceField.carrier, ReferenceField.tracking],
};

enum _ReferenceStatus { initial, loading, unavailable, empty, error, loaded }

typedef _LookupState = ({
  _ReferenceStatus status,
  List<ReferenceRecord> records,
  Map<ReferenceField, String> inputs,
});

class _LookupCubit extends Cubit<_LookupState> {
  _LookupCubit(this.category, this.provider)
    : super((status: _ReferenceStatus.initial, records: [], inputs: {}));
  final String category;
  final ReferenceProvider provider;
  int _version = 0;

  void edit(ReferenceField field, String value) {
    _version++;
    emit((
      status: _ReferenceStatus.initial,
      records: const [],
      inputs: Map.unmodifiable({...state.inputs, field: value}),
    ));
  }

  Future<void> lookup() async {
    final version = ++_version;
    final inputs = state.inputs;
    emit((status: _ReferenceStatus.loading, records: const [], inputs: inputs));
    try {
      final records = await provider.lookup((
        category: category,
        fields: inputs,
      ));
      if (isClosed || version != _version) return;
      emit((
        status: records == null
            ? _ReferenceStatus.unavailable
            : records.isEmpty
            ? _ReferenceStatus.empty
            : _ReferenceStatus.loaded,
        records: List.unmodifiable(records ?? const <ReferenceRecord>[]),
        inputs: inputs,
      ));
    } catch (_) {
      if (!isClosed && version == _version) {
        emit((
          status: _ReferenceStatus.error,
          records: const [],
          inputs: inputs,
        ));
      }
    }
  }
}

class ReferenceWorkspace extends StatelessWidget {
  const ReferenceWorkspace({
    super.key,
    required this.copy,
    required this.category,
    required this.fields,
    this.provider = const LocalReferenceProvider(),
  });
  final AppCopy copy;
  final ServiceCategory category;
  final List<ReferenceField> fields;
  final ReferenceProvider provider;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _LookupCubit(category.id, provider),
    child: BlocBuilder<_LookupCubit, _LookupState>(
      builder: (context, state) {
        final cubit = context.read<_LookupCubit>();
        return WorkspacePage(
          title: copy.local(category.nameEn, category.nameAr),
          children: [
            WorkspaceNotice(
              copy: copy,
              message: copy.local(
                'Use the fields to define the lookup scope. Connected records are unavailable in this preview.',
                'استخدم الحقول لتحديد نطاق البحث. السجلات المتصلة غير متاحة في هذه المعاينة.',
              ),
            ),
            AdaptiveGrid(
              children: [
                for (final field in fields)
                  TextField(
                    key: ValueKey(field),
                    decoration: InputDecoration(labelText: _label(field)),
                    onChanged: (value) => cubit.edit(field, value),
                  ),
              ],
            ),
            WorkspaceLink(
              key: const ValueKey('category-lookup-check'),
              label: copy.local(
                'Check source availability',
                'تحقق من توفر المصدر',
              ),
              onTap: cubit.lookup,
            ),
            switch (state.status) {
              _ReferenceStatus.loading => AppStatePanel(
                state: AppViewState.loading,
                copy: copy,
              ),
              _ReferenceStatus.error => AppStatePanel(
                state: AppViewState.error,
                copy: copy,
                onAction: cubit.lookup,
              ),
              _ReferenceStatus.empty => AppStatePanel(
                state: AppViewState.empty,
                copy: copy,
              ),
              _ReferenceStatus.unavailable => ContentPanel(
                title: copy.local(
                  'Verified data unavailable',
                  'البيانات الموثقة غير متاحة',
                ),
                children: [
                  Text(
                    copy.local(
                      'This search scope requires a connected and verified source.',
                      'يتطلب نطاق البحث مصدرًا متصلًا وموثقًا.',
                    ),
                  ),
                ],
              ),
              _ReferenceStatus.loaded => Column(
                children: [
                  for (final row in state.records)
                    ContentPanel(
                      title: row.label,
                      children: [
                        LabelValue(copy.local('Source', 'المصدر'), row.source),
                        LabelValue(
                          copy.local('Reviewed', 'تاريخ المراجعة'),
                          row.reviewedAt.toIso8601String().substring(0, 10),
                        ),
                      ],
                    ),
                ],
              ),
              _ReferenceStatus.initial => const SizedBox.shrink(),
            },
          ],
        );
      },
    ),
  );

  String _label(ReferenceField field) => switch (field) {
    ReferenceField.country => copy.local(
      'Country of origin or jurisdiction',
      'بلد المنشأ أو الاختصاص',
    ),
    ReferenceField.destination => copy.local('Destination', 'الوجهة'),
    ReferenceField.region => copy.local(
      'City or service area',
      'المدينة أو نطاق الخدمة',
    ),
    ReferenceField.product => copy.local(
      'Product or specialty',
      'المنتج أو التخصص',
    ),
    ReferenceField.service => copy.local(
      'Service or procedure',
      'الخدمة أو الإجراء',
    ),
    ReferenceField.equipment => copy.local(
      'Equipment or packaging type',
      'نوع المعدات أو التغليف',
    ),
    ReferenceField.port => copy.local(
      'Port or entry point',
      'الميناء أو المنفذ',
    ),
    ReferenceField.airport => copy.local('Origin airport', 'مطار الانطلاق'),
    ReferenceField.permit => copy.local(
      'Licence or regime type',
      'نوع الترخيص أو النظام',
    ),
    ReferenceField.organizer => copy.local('Organizer', 'المنظم'),
    ReferenceField.date => copy.local(
      'Event, shipment or source date',
      'تاريخ الحدث أو الشحنة أو المصدر',
    ),
    ReferenceField.currency => copy.local('Currency pair', 'زوج العملات'),
    ReferenceField.carrier => copy.local(
      'Carrier or operator',
      'الناقل أو المشغل',
    ),
    ReferenceField.tracking => copy.local(
      'Example tracking reference',
      'مرجع تتبع توضيحي',
    ),
    ReferenceField.source => copy.local(
      'Source or framework',
      'المصدر أو الإطار المرجعي',
    ),
    ReferenceField.temperature => copy.local(
      'Product temperature requirement and unit',
      'متطلب حرارة المنتج ووحدته',
    ),
    ReferenceField.language => copy.local('Language', 'اللغة'),
  };
}

class _Academy extends StatelessWidget {
  const _Academy({required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local(
      'Academy and advisory topics',
      'موضوعات الأكاديمية والاستشارات',
    ),
    children: [
      WorkspaceNotice(copy: copy),
      for (final (title, body) in [
        (
          copy.local('Shipment preparation', 'تجهيز الشحنة'),
          copy.local(
            'Start with the route, cargo description, package measurements and service scope.',
            'ابدأ بالمسار ووصف البضاعة وقياسات العبوات ونطاق الخدمة.',
          ),
        ),
        (
          copy.local(
            'Commercial source checking',
            'التحقق من المصادر التجارية',
          ),
          copy.local(
            'Check source date, scope and evidence before relying on a company claim.',
            'تحقق من تاريخ المصدر ونطاقه وأدلته قبل الاعتماد على ادعاء شركة.',
          ),
        ),
      ])
        ContentPanel(title: title, children: [Text(body)]),
      WorkspaceLink(
        label: copy.local(
          'Consulting services preview',
          'معاينة الخدمات الاستشارية',
        ),
        onTap: () => openWorkspace(
          context,
          JobsWorkspace(copy: copy, area: JobArea.consulting),
        ),
      ),
      WorkspaceLink(
        label: copy.local(
          'Walkthrough and glossary',
          'دليل الاستخدام والمصطلحات',
        ),
        onTap: () => openWorkspace(context, UserGuides(copy: copy)),
      ),
    ],
  );
}
