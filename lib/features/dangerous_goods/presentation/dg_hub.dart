import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../data/local_dg_repository.dart';
import '../domain/dg_assessment.dart';
import '../domain/dg_models.dart';
import '../domain/dg_providers.dart';
import 'dg_copy.dart';
import 'dg_reference_widgets.dart';
import 'dg_search.dart';
import 'dg_widgets.dart';
import 'dg_wizard.dart';

Future<void> openDgHub(BuildContext context, AppCopy copy, {DgMode? mode}) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DangerousGoodsHub(copy: copy, mode: mode),
      ),
    );

class DangerousGoodsHub extends StatelessWidget {
  const DangerousGoodsHub({
    super.key,
    required this.copy,
    this.mode,
    this.repository = const LocalDgRepository(),
    this.providers = const RuleProviders(),
  });
  final AppCopy copy;
  final DgMode? mode;
  final ClassificationRepository repository;
  final RuleProviders providers;

  @override
  Widget build(BuildContext context) {
    final labels = DgCopy(copy);
    void open(Widget page) => Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => page));
    DgAction topic(String en, String ar, IconData icon, Widget page) =>
        DgAction(title: labels.tr(en, ar), icon: icon, onTap: () => open(page));
    return DgPage(
      title: labels.title,
      children: [
        DgNotice(copy: labels),
        if (mode case final selected?) _ModePanel(copy: labels, mode: selected),
        ContentPanel(
          title: labels.tr('Search and prepare', 'البحث وتجهيز الشحنة'),
          children: [
            AdaptiveGrid(
              children: [
                DgAction(
                  key: const ValueKey('dg-search-action'),
                  title: labels.tr(
                    'UN number and substance search',
                    'البحث بالرقم الأممي أو المادة',
                  ),
                  icon: Icons.search,
                  onTap: () => open(
                    DgSearch(copy: labels, mode: mode, repository: repository),
                  ),
                ),
                DgAction(
                  key: const ValueKey('dg-wizard-action'),
                  title: labels.tr(
                    'Shipment readiness assessment',
                    'تقييم جاهزية الشحنة',
                  ),
                  icon: Icons.fact_check_outlined,
                  onTap: () => open(
                    DgWizard(
                      copy: labels,
                      mode: mode,
                      service: DgAssessmentService(repository, providers),
                    ),
                  ),
                ),
                topic(
                  'Hazard classes and divisions',
                  'فئات وأقسام المخاطر',
                  Icons.category_outlined,
                  DgPage(
                    title: labels.tr(
                      'Hazard classes and divisions',
                      'فئات وأقسام المخاطر',
                    ),
                    children: [
                      DgNotice(copy: labels),
                      for (final hazard in HazardClass.values)
                        ContentPanel(
                          title: labels.option(hazard),
                          children: [
                            if (hazard.divisions.isNotEmpty)
                              Text(
                                '${labels.tr('Divisions', 'الأقسام')} · ${hazard.divisions.join(' / ')}',
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                topic(
                  'Documentation checklist',
                  'قائمة الوثائق',
                  Icons.assignment_outlined,
                  DgPage(
                    title: labels.tr(
                      'Documentation checklist',
                      'قائمة الوثائق',
                    ),
                    children: [
                      DgNotice(copy: labels),
                      DgDocuments(copy: labels, mode: mode, battery: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ContentPanel(
          title: labels.tr('Transport and handling', 'النقل والمناولة'),
          children: [
            AdaptiveGrid(
              children: [
                for (final transport in DgMode.values)
                  DgAction(
                    title: labels.option(transport),
                    icon: switch (transport) {
                      DgMode.air => Icons.flight_outlined,
                      DgMode.sea => Icons.directions_boat_outlined,
                      DgMode.road => Icons.local_shipping_outlined,
                    },
                    onTap: () => open(
                      DgPage(
                        title: labels.option(transport),
                        children: [
                          DgNotice(copy: labels),
                          _ModePanel(copy: labels, mode: transport),
                          DgDocuments(copy: labels, mode: transport),
                          DgAction(
                            title: labels.tr(
                              'Start readiness assessment',
                              'ابدأ تقييم الجاهزية',
                            ),
                            icon: Icons.fact_check_outlined,
                            onTap: () => open(
                              DgWizard(
                                copy: labels,
                                mode: transport,
                                service: DgAssessmentService(
                                  repository,
                                  providers,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                topic(
                  'Lithium and other batteries',
                  'الليثيوم والبطاريات الأخرى',
                  Icons.battery_charging_full,
                  _info(
                    labels,
                    labels.tr(
                      'Lithium and other batteries',
                      'الليثيوم والبطاريات الأخرى',
                    ),
                    labels.tr(
                      'Prepare the chemistry, configuration, capacity with its unit, condition and available test records for a specialist. Confirm applicable requirements with the operator.',
                      'جهّز بيانات التركيب والتكوين والسعة ووحدتها وحالة البطارية وسجلات الاختبار المتاحة للمختص. تحقق من المتطلبات المنطبقة مع المشغّل.',
                    ),
                  ),
                ),
                topic(
                  'Packaging and labeling',
                  'التعبئة والملصقات',
                  Icons.inventory_2_outlined,
                  _info(
                    labels,
                    labels.tr('Packaging and labeling', 'التعبئة والملصقات'),
                    labels.tr(
                      'Ask a specialist to review your planned packaging, markings and records against the applicable edition and carrier conditions.',
                      'اطلب من مختص مراجعة العبوات والعلامات والسجلات المخططة وفق الإصدار المنطبق وشروط الناقل.',
                    ),
                  ),
                ),
                topic(
                  'Regulatory references',
                  'المراجع التنظيمية',
                  Icons.menu_book_outlined,
                  DgPage(
                    title: labels.tr(
                      'Regulatory references',
                      'المراجع التنظيمية',
                    ),
                    children: [
                      DgNotice(copy: labels),
                      DgReferences(copy: labels),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _info(DgCopy copy, String title, String info) => DgPage(
    title: title,
    children: [
      DgNotice(copy: copy),
      ContentPanel(children: [Text(info), Text(copy.unavailable)]),
    ],
  );
}

class _ModePanel extends StatelessWidget {
  const _ModePanel({required this.copy, required this.mode});
  final DgCopy copy;
  final DgMode mode;

  @override
  Widget build(BuildContext context) => ContentPanel(
    title:
        '${copy.tr('Transport review', 'مراجعة النقل')} · ${copy.option(mode)}',
    children: [
      Text(
        copy.tr(
          'Confirm the shipment details, route and operator with a specialist. Review the applicable edition, national variations and operator requirements.',
          'أكد تفاصيل الشحنة والمسار والمشغّل مع مختص. راجع الإصدار المنطبق والاختلافات الوطنية ومتطلبات المشغّل.',
        ),
      ),
      DgReferences(copy: copy, mode: mode),
    ],
  );
}
