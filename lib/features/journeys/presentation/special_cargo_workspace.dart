import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../../dangerous_goods/presentation/dg_hub.dart';
import '../../trade/domain/shipment.dart';
import '../../trade/presentation/trade_screen.dart';
import '../domain/logistics_tools.dart';
import 'closure_widgets.dart';
import 'container_planner.dart';
import 'package_editor.dart';
import 'workspace_widgets.dart';

enum _Temperature { chilled, frozen }

enum _Special { oversized, heavy, temperature, other }

class ColdChainWorkspace extends StatelessWidget {
  const ColdChainWorkspace({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => ClosureForm(
    builder: (context, state, cubit) {
      final profile = _Temperature.values
          .where((entry) => entry.name == state.value('profile'))
          .firstOrNull;
      final status = coldReadiness(
        commodity: state.value('commodity'),
        min: state.value('min'),
        max: state.value('max'),
        source: state.value('source'),
        packaging:
            state.checked.contains('package') &&
            state.value('packaging').isNotEmpty,
        equipment:
            state.checked.contains('equipment') &&
            state.value('equipment').isNotEmpty,
        monitoring:
            state.checked.contains('monitor') &&
            state.value('monitor').isNotEmpty,
        documentation: state.checked.contains('docs'),
      );
      return WorkspacePage(
        title: copy.local('Cold chain preparation', 'تجهيز سلسلة التبريد'),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'Use commodity requirements supplied by a qualified source. The selected preparation type sets no temperature.',
              'استخدم متطلبات السلعة من مصدر مؤهل. لا يحدد نوع التجهيز المختار درجة حرارة.',
            ),
          ),
          WorkspaceSelect(
            title: copy.local('Preparation type', 'نوع التجهيز'),
            options: _Temperature.values,
            selected: profile,
            copy: copy,
            label: (mode) => mode == _Temperature.chilled
                ? copy.local('Chilled', 'مبرد')
                : copy.local('Frozen', 'مجمد'),
            onChanged: (mode) => cubit.edit('profile', mode!.name),
          ),
          closureFields(state, cubit, [
            (id: 'commodity', label: copy.local('Commodity', 'السلعة')),
            (
              id: 'source',
              label: copy.local(
                'Temperature requirement source',
                'مصدر متطلب الحرارة',
              ),
            ),
            (id: 'min', label: copy.local('Minimum (°C)', 'الحد الأدنى (°C)')),
            (id: 'max', label: copy.local('Maximum (°C)', 'الحد الأقصى (°C)')),
            (
              id: 'packaging',
              label: copy.local('Packaging plan', 'خطة التغليف'),
            ),
            (
              id: 'equipment',
              label: copy.local(
                'Equipment or refrigeration plan',
                'خطة المعدات أو التبريد',
              ),
            ),
            (
              id: 'monitor',
              label: copy.local(
                'Monitoring and alarm plan',
                'خطة المراقبة والإنذار',
              ),
            ),
          ]),
          closureChecklist(state, cubit, {
            'package': copy.local(
              'Packaging requirements recorded',
              'تم تسجيل متطلبات التغليف',
            ),
            'equipment': copy.local(
              'Equipment requirements recorded',
              'تم تسجيل متطلبات المعدات',
            ),
            'monitor': copy.local(
              'Monitoring responsibilities recorded',
              'تم تسجيل مسؤوليات المراقبة',
            ),
            'docs': copy.local(
              'Handling, temperature and handover documents gathered',
              'تم تجهيز وثائق المناولة والحرارة والتسليم',
            ),
          }, copy),
          ContentPanel(
            title: copy.local(
              'Readiness for specialist review',
              'الجاهزية لمراجعة المختص',
            ),
            children: [
              Semantics(
                liveRegion: true,
                child: Text(switch (profile == null
                    ? ColdStatus.incomplete
                    : status) {
                  ColdStatus.incomplete => copy.local(
                    'Preparation type, commodity, sourced range and units required.',
                    'نوع التجهيز والسلعة والنطاق الموثق والوحدات مطلوبة.',
                  ),
                  ColdStatus.invalidRange => copy.local(
                    'Invalid Celsius range. Check the limits.',
                    'نطاق مئوي غير صالح. تحقق من الحدود.',
                  ),
                  ColdStatus.needsPreparation => copy.local(
                    'Packaging, equipment, monitoring or documentation still needs preparation.',
                    'لا يزال التغليف أو المعدات أو المراقبة أو الوثائق بحاجة إلى التجهيز.',
                  ),
                  ColdStatus.preparedForReview => copy.local(
                    'Worksheet complete for specialist review.',
                    'ورقة التجهيز مكتملة لمراجعة المختص.',
                  ),
                }),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class SpecialCargoWorkspace extends StatelessWidget {
  const SpecialCargoWorkspace({super.key, required this.copy});
  final AppCopy copy;

  String _label(_Special value) => switch (value) {
    _Special.oversized => copy.local('Oversized cargo', 'بضاعة زائدة الأبعاد'),
    _Special.heavy => copy.local('Heavy cargo', 'بضاعة ثقيلة'),
    _Special.temperature => copy.local(
      'Temperature-sensitive cargo',
      'بضاعة حساسة للحرارة',
    ),
    _Special.other => copy.local('Other special cargo', 'بضاعة خاصة أخرى'),
  };

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local('Special cargo preparation', 'تجهيز البضائع الخاصة'),
    children: [
      for (final type in _Special.values)
        WorkspaceLink(
          label: _label(type),
          onTap: () => openWorkspace(context, _prepare(type)),
        ),
    ],
  );

  Widget _prepare(_Special type) => ClosureForm(
    builder: (context, state, cubit) => WorkspacePage(
      title: _label(type),
      children: [
        WorkspaceNotice(
          copy: copy,
          message: copy.local(
            'Prepare information for the carrier and specialist to confirm.',
            'جهّز البيانات ليؤكدها الناقل والمختص.',
          ),
        ),
        closureFields(state, cubit, [
          (
            id: 'cargo',
            label: copy.local(
              'Commodity and handling description',
              'وصف السلعة والمناولة',
            ),
          ),
          (
            id: 'route',
            label: copy.local(
              'Route and loading points',
              'المسار ونقاط التحميل',
            ),
          ),
          if (type == _Special.oversized)
            (
              id: 'clearance',
              label: copy.local(
                'Route clearance and equipment needs',
                'الخلوص المطلوب على المسار والمعدات',
              ),
            ),
          if (type == _Special.heavy)
            (
              id: 'lift',
              label: copy.local(
                'Lifting and load-distribution requirements',
                'متطلبات الرفع وتوزيع الأحمال',
              ),
            ),
          if (type == _Special.temperature)
            (
              id: 'temp',
              label: copy.local(
                'Sourced temperature and monitoring requirement',
                'متطلب الحرارة والمراقبة من المصدر',
              ),
            ),
          if (type == _Special.other)
            (
              id: 'conditions',
              label: copy.local(
                'Special handling and documentation needs',
                'متطلبات المناولة الخاصة والوثائق',
              ),
            ),
        ]),
        PackageEditor(
          copy: copy,
          inputs: state.packages,
          onChanged: cubit.packages,
        ),
        if (type == _Special.oversized || type == _Special.heavy)
          WorkspaceLink(
            label: copy.local('Container planner', 'مخطط الحاويات'),
            onTap: () => openWorkspace(context, ContainerPlanner(copy: copy)),
          ),
        if (type == _Special.temperature)
          WorkspaceLink(
            label: copy.local('Cold chain preparation', 'تجهيز سلسلة التبريد'),
            onTap: () => openWorkspace(context, ColdChainWorkspace(copy: copy)),
          ),
        WorkspaceLink(
          label: copy.local(
            'Dangerous goods preparation',
            'تجهيز البضائع الخطرة',
          ),
          onTap: () => openDgHub(context, copy),
        ),
        WorkspaceLink(
          label: copy.local('Freight estimate', 'تقدير الشحن'),
          onTap: () => openTrade(context, copy, TradeMode.freight),
        ),
      ],
    ),
  );
}
