import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../../trade/domain/decimal.dart';
import '../domain/logistics_tools.dart';
import 'closure_widgets.dart';
import 'package_editor.dart';
import 'workspace_widgets.dart';

class ContainerPlanner extends StatelessWidget {
  const ContainerPlanner({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => ClosureForm(
    builder: (context, state, cubit) {
      Decimal? parse(String field) => Decimal.parse(state.value(field));
      final length = parse('length');
      final width = parse('width');
      final height = parse('height');
      final doorWidth = parse('doorWidth');
      final doorHeight = parse('doorHeight');
      final payload = parse('payload');
      final result = containerFit(
        length == null ||
                width == null ||
                height == null ||
                doorWidth == null ||
                doorHeight == null ||
                payload == null
            ? null
            : (
                length: length,
                width: width,
                height: height,
                doorWidth: doorWidth,
                doorHeight: doorHeight,
                payloadKg: payload,
              ),
        state.packages,
      );
      return WorkspacePage(
        title: copy.local('Container planner', 'مخطط الحاويات'),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'Preliminary checks use rectangular package dimensions and straight entry through the door. Package rotation must be permitted in practice.',
              'تستخدم الفحوص الأولية أبعاد الطرود المستطيلة والدخول المستقيم من الباب. يجب التأكد من السماح بتدوير العبوات عمليًا.',
            ),
          ),
          ContentPanel(
            title: copy.local('Container and doorway', 'الحاوية وفتحة الباب'),
            children: [
              closureFields(state, cubit, [
                (
                  id: 'length',
                  label: copy.local('Internal length (m)', 'الطول الداخلي (م)'),
                ),
                (
                  id: 'width',
                  label: copy.local('Internal width (m)', 'العرض الداخلي (م)'),
                ),
                (
                  id: 'height',
                  label: copy.local(
                    'Internal height (m)',
                    'الارتفاع الداخلي (م)',
                  ),
                ),
                (
                  id: 'doorWidth',
                  label: copy.local('Door width (m)', 'عرض الباب (م)'),
                ),
                (
                  id: 'doorHeight',
                  label: copy.local('Door height (m)', 'ارتفاع الباب (م)'),
                ),
                (
                  id: 'payload',
                  label: copy.local('Payload limit (kg)', 'حد الحمولة (كجم)'),
                ),
              ]),
            ],
          ),
          PackageEditor(
            copy: copy,
            inputs: state.packages,
            onChanged: cubit.packages,
          ),
          ContentPanel(
            title: copy.local('Preliminary result', 'النتيجة الأولية'),
            children: [
              if (result.utilization case final percent?)
                LabelValue(
                  copy.local(
                    'Cargo volume / internal volume',
                    'حجم الشحنة / الحجم الداخلي',
                  ),
                  '${percent.format()}%',
                ),
              Semantics(
                liveRegion: true,
                child: Text(switch (result.status) {
                  FitStatus.incomplete => copy.local(
                    'Enter valid positive measurements, limits and package groups. The opening must fit within the internal cross-section.',
                    'أدخل قياسات وحدودًا ومجموعات طرود موجبة وصحيحة. يجب أن تقع فتحة الباب ضمن المقطع الداخلي.',
                  ),
                  FitStatus.outsideLimits => copy.local(
                    'One or more entered limits were exceeded.',
                    'تم تجاوز حد واحد أو أكثر من الحدود المدخلة.',
                  ),
                  FitStatus.individualFitOnly => copy.local(
                    'Each package type has an individual straight-entry orientation. Combined loading remains unassessed.',
                    'لكل نوع طرد اتجاه دخول مستقيم منفرد. لم تُقيّم خطة تحميل الطرود معًا.',
                  ),
                }),
              ),
              if (result.payloadExceeded)
                Text(copy.local('Payload exceeded.', 'تم تجاوز الحمولة.')),
              if (result.volumeExceeded)
                Text(
                  copy.local(
                    'Internal volume exceeded.',
                    'تم تجاوز الحجم الداخلي.',
                  ),
                ),
              if (result.failingGroups.isNotEmpty)
                Text(
                  copy.local(
                    'No straight-entry orientation for groups ${result.failingGroups.join(', ')}.',
                    'لا يوجد اتجاه دخول مستقيم للمجموعات ${result.failingGroups.join(', ')}.',
                  ),
                ),
              Text(
                copy.local(
                  'Volume utilization is a ratio. Confirm stacking, manoeuvring, securing, load distribution and dangerous-goods compatibility with a specialist.',
                  'استغلال الحجم نسبة حسابية. تحقق مع مختص من الرص والمناورة والتثبيت وتوزيع الأحمال وتوافق البضائع الخطرة.',
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
