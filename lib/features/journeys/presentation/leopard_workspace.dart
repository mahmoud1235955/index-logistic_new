import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/commercial_models.dart';
import '../domain/local_workspace.dart';
import 'commercial_board.dart';
import 'quote_workspace.dart';
import 'workspace_widgets.dart';

enum _Service { sea, air, road, customs, logistics }

enum _Feed { alfalfa, maize, soybeanMeal }

class LeopardWorkspace extends StatelessWidget {
  const LeopardWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;

  String _service(_Service service) => switch (service) {
    _Service.sea => copy.local('Sea freight', 'الشحن البحري'),
    _Service.air => copy.local('Air freight', 'الشحن الجوي'),
    _Service.road => copy.local('Road transport', 'النقل البري'),
    _Service.customs => copy.local('Customs clearance', 'التخليص الجمركي'),
    _Service.logistics => copy.local(
      'Logistics and consolidation',
      'الخدمات اللوجستية والتجميع',
    ),
  };

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: 'Leopard',
    children: [
      WorkspaceNotice(
        copy: copy,
        message: copy.local(
          'Service availability, company contacts and quotations are pending verification.',
          'توافر الخدمات وبيانات اتصال الشركة وعروض الأسعار بانتظار التحقق.',
        ),
      ),
      ContentPanel(
        title: copy.local('Service preparation', 'تجهيز الخدمات'),
        children: [
          AdaptiveGrid(
            children: [
              for (final service in _Service.values)
                WorkspaceLink(
                  label: _service(service),
                  onTap: () => _open(context, service),
                ),
            ],
          ),
        ],
      ),
      WorkspaceLink(
        label: copy.local('Freight quotation draft', 'مسودة طلب سعر الشحن'),
        onTap: () => openWorkspace(
          context,
          QuoteWorkspace(copy: copy, workspace: workspace),
        ),
      ),
      WorkspaceLink(
        label: copy.local('Feed trade preparation', 'تجهيز تجارة الأعلاف'),
        onTap: () => openWorkspace(
          context,
          _FeedWorkspace(copy: copy, workspace: workspace),
        ),
      ),
      WorkspaceLink(
        label: commercialTypeLabel(copy, CommercialType.opportunity),
        onTap: () => openWorkspace(
          context,
          CommercialBoard(
            copy: copy,
            workspace: workspace,
            initialType: CommercialType.opportunity,
          ),
        ),
      ),
    ],
  );

  void _open(BuildContext context, _Service service) => openWorkspace(
    context,
    WorkspacePage(
      title: _service(service),
      children: [
        WorkspaceNotice(copy: copy),
        ContentPanel(
          children: [
            LabelValue(copy.local('Availability', 'التوفر'), copy.unavailable),
            Text(
              copy.local(
                'Prepare the route, cargo, timing and any service-specific documents for review.',
                'جهّز المسار والبضاعة والتوقيت وأي وثائق خاصة بالخدمة للمراجعة.',
              ),
            ),
          ],
        ),
        Builder(
          builder: (context) => WorkspaceLink(
            label: copy.local(
              'Prepare quotation draft',
              'جهّز مسودة طلب السعر',
            ),
            onTap: () => openWorkspace(
              context,
              QuoteWorkspace(
                copy: copy,
                workspace: workspace,
                mode: switch (service) {
                  _Service.sea => FreightMode.sea,
                  _Service.air => FreightMode.air,
                  _Service.road => FreightMode.road,
                  _ => null,
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

typedef _FeedSelection = ({_Feed? product, String? country});

class _FeedCubit extends Cubit<_FeedSelection> {
  _FeedCubit() : super((product: null, country: null));
  void product(_Feed product) =>
      emit((product: product, country: state.country));
  void country(String? country) =>
      emit((product: state.product, country: country));
}

class _FeedWorkspace extends StatelessWidget {
  const _FeedWorkspace({required this.copy, required this.workspace});
  final AppCopy copy;
  final LocalWorkspace workspace;

  String label(_Feed product) => switch (product) {
    _Feed.alfalfa => copy.local('Alfalfa', 'البرسيم'),
    _Feed.maize => copy.local('Corn (maize)', 'الذرة'),
    _Feed.soybeanMeal => copy.local('Soybean meal', 'كسب الصويا'),
  };

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _FeedCubit(),
    child: BlocBuilder<_FeedCubit, _FeedSelection>(
      builder: (context, state) => WorkspacePage(
        title: copy.local('Feed trade preparation', 'تجهيز تجارة الأعلاف'),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'Market and participant records are unavailable.',
              'سجلات الأسواق والمشاركين غير متاحة.',
            ),
          ),
          WorkspaceSelect(
            title: copy.countryLabel,
            options: ['EG', 'JO', 'SD'],
            selected: state.country,
            canClear: true,
            copy: copy,
            label: (code) => switch (code) {
              'EG' => copy.local('Egypt', 'مصر'),
              'JO' => copy.local('Jordan', 'الأردن'),
              _ => copy.local('Sudan', 'السودان'),
            },
            onChanged: context.read<_FeedCubit>().country,
          ),
          AdaptiveGrid(
            children: [
              for (final product in _Feed.values)
                WorkspaceLink(
                  label: label(product),
                  onTap: () => context.read<_FeedCubit>().product(product),
                ),
            ],
          ),
          if (state.product case final selected?) ...[
            ContentPanel(
              title: label(selected),
              children: [
                for (final title in [
                  copy.local(
                    'Moisture, protein and fibre',
                    'الرطوبة والبروتين والألياف',
                  ),
                  copy.local('Packaging and quantity', 'التعبئة والكمية'),
                  copy.local('Inspection and availability', 'الفحص والتوفر'),
                ])
                  LabelValue(title, copy.unavailable),
              ],
            ),
            _FeedParticipants(copy: copy),
            WorkspaceLink(
              label: copy.local(
                'Use product name in freight draft',
                'استخدم اسم المنتج في مسودة الشحن',
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialog) => AlertDialog(
                    title: Text(
                      copy.local(
                        'Copy product name to the local draft?',
                        'نسخ اسم المنتج إلى المسودة المحلية؟',
                      ),
                    ),
                    content: Text(
                      copy.local(
                        'This replaces the cargo description in your local draft.',
                        'يستبدل هذا الإجراء وصف البضاعة في مسودتك المحلية.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialog, false),
                        child: Text(copy.local('Cancel', 'إلغاء')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialog, true),
                        child: Text(copy.local('Copy name', 'انسخ الاسم')),
                      ),
                    ],
                  ),
                );
                if (context.mounted && confirmed == true) {
                  final draft = workspace.state.quote;
                  workspace.saveQuote(
                    QuoteDraft(
                      mode: draft?.mode,
                      services: draft?.services ?? {},
                      packages: draft?.packages ?? [],
                      fields: {
                        ...?draft?.fields,
                        QuoteField.cargo: label(selected),
                      },
                    ),
                  );
                  await openWorkspace(
                    context,
                    QuoteWorkspace(copy: copy, workspace: workspace),
                  );
                }
              },
            ),
          ],
        ],
      ),
    ),
  );
}

class _FeedParticipants extends StatelessWidget {
  const _FeedParticipants({required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final titles = [
      copy.local('Suppliers', 'الموردون'),
      copy.local('Buyers', 'المشترون'),
    ];
    Widget panel(String title) =>
        ContentPanel(title: title, children: [Text(copy.unavailable)]);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >=
            MediaQuery.textScalerOf(context).scale(580)) {
          return AdaptiveGrid(children: titles.map(panel).toList());
        }
        return DefaultTabController(
          length: titles.length,
          child: Builder(
            builder: (context) {
              final tabs = DefaultTabController.of(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: [for (final title in titles) Tab(child: Text(title))],
                  ),
                  AnimatedBuilder(
                    animation: tabs,
                    builder: (context, _) => panel(titles[tabs.index]),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
