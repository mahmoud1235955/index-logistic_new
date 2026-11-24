import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../../trade/domain/decimal.dart';
import '../domain/logistics_tools.dart';
import 'closure_widgets.dart';
import 'workspace_widgets.dart';

enum _Section { transport, product, cbam }

class EmissionsWorkspace extends StatelessWidget {
  const EmissionsWorkspace({super.key, required this.copy});
  final AppCopy copy;
  String _title(_Section section) => switch (section) {
    _Section.transport => copy.local(
      'Transport emissions estimate',
      'تقدير انبعاثات النقل',
    ),
    _Section.product => copy.local(
      'Product embedded-emissions preparation',
      'تجهيز الانبعاثات المضمنة في المنتج',
    ),
    _Section.cbam => copy.local(
      'CBAM information and preparation',
      'معلومات وتجهيز CBAM',
    ),
  };

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local('Emissions and CBAM', 'الانبعاثات وآلية CBAM'),
    children: [
      for (final section in _Section.values)
        WorkspaceLink(
          label: _title(section),
          onTap: () => openWorkspace(context, _section(section)),
        ),
    ],
  );

  Widget _section(_Section section) => ClosureForm(
    builder: (context, state, cubit) {
      Decimal? estimate;
      final source = state.value('source');
      final date = state.value('date');
      if (section == _Section.transport) {
        estimate = transportEmissions(
          tonnes: state.value('tonnes'),
          kilometres: state.value('km'),
          factor: state.value('factor'),
          source: source,
          effectiveDate: date,
        );
      } else if (section == _Section.product) {
        final tonnes = Decimal.parse(state.value('tonnes'));
        final factor = Decimal.parse(state.value('factor'));
        if (tonnes != null &&
            tonnes.positive &&
            factor != null &&
            source.isNotEmpty &&
            exactDate(date) != null &&
            state.value('boundary').isNotEmpty) {
          estimate = tonnes * factor;
        }
      }
      return WorkspacePage(
        title: _title(section),
        children: [
          WorkspaceNotice(
            copy: copy,
            message: copy.local(
              'User-entered inputs are illustrative until independently verified. This worksheet issues no official factors, CBAM charges or compliance conclusions.',
              'المدخلات من المستخدم استرشادية حتى التحقق المستقل. لا تصدر ورقة العمل عوامل رسمية أو رسوم CBAM أو نتائج امتثال.',
            ),
          ),
          closureFields(state, cubit, [
            if (section == _Section.transport) ...[
              (
                id: 'mode',
                label: copy.local(
                  'Transport mode or leg description',
                  'وسيلة النقل أو وصف المرحلة',
                ),
              ),
              (
                id: 'tonnes',
                label: copy.local('Cargo mass (tonnes)', 'كتلة الشحنة (طن)'),
              ),
              (
                id: 'km',
                label: copy.local('Leg distance (km)', 'مسافة المرحلة (كم)'),
              ),
              (
                id: 'factor',
                label: copy.local(
                  'Factor (kg CO₂e per tonne-km)',
                  'عامل الانبعاث (كجم مكافئ CO₂ لكل طن-كم)',
                ),
              ),
            ],
            if (section == _Section.product) ...[
              (
                id: 'product',
                label: copy.local('Product and process', 'المنتج والعملية'),
              ),
              (
                id: 'boundary',
                label: copy.local(
                  'Method and system boundary',
                  'المنهجية وحدود النظام',
                ),
              ),
              (
                id: 'tonnes',
                label: copy.local(
                  'Product quantity (tonnes)',
                  'كمية المنتج (طن)',
                ),
              ),
              (
                id: 'factor',
                label: copy.local(
                  'Intensity (kg CO₂e per tonne of product)',
                  'الكثافة (كجم مكافئ CO₂ لكل طن منتج)',
                ),
              ),
            ],
            if (section == _Section.cbam) ...[
              (
                id: 'product',
                label: copy.local(
                  'Product / candidate classification',
                  'المنتج / التصنيف المحتمل',
                ),
              ),
              (
                id: 'operator',
                label: copy.local(
                  'Installation or production route',
                  'المنشأة أو مسار الإنتاج',
                ),
              ),
              (
                id: 'period',
                label: copy.local('Reporting period', 'فترة الإبلاغ'),
              ),
              (
                id: 'method',
                label: copy.local(
                  'Applicable method under review',
                  'المنهجية المنطبقة قيد المراجعة',
                ),
              ),
            ],
            (
              id: 'source',
              label: copy.local(
                'Source, version or evidence reference',
                'المصدر أو الإصدار أو مرجع الأدلة',
              ),
            ),
            (
              id: 'date',
              label: copy.local(
                'Source effective date (YYYY-MM-DD)',
                'تاريخ سريان المصدر (YYYY-MM-DD)',
              ),
            ),
          ]),
          if (section != _Section.cbam)
            ContentPanel(
              title: copy.local('User-input result', 'نتيجة المدخلات'),
              children: [
                Text(
                  estimate == null
                      ? copy.local(
                          'Incomplete: check mandatory measurements, factor, source and effective date.',
                          'غير مكتمل: تحقق من القياسات والعامل والمصدر وتاريخ السريان الإلزامية.',
                        )
                      : '${estimate.format(3)} kg CO₂e',
                ),
              ],
            ),
          if (section == _Section.cbam) ...[
            closureChecklist(state, cubit, {
              'classification': copy.local(
                'Product classification ready for verification',
                'تصنيف المنتج جاهز للتحقق',
              ),
              'data': copy.local(
                'Installation and emissions evidence gathered',
                'تم جمع أدلة المنشأة والانبعاثات',
              ),
              'review': copy.local(
                'Methodology and reporting period ready for review',
                'المنهجية وفترة الإبلاغ جاهزتان للمراجعة',
              ),
            }, copy),
            const SelectableText(
              'https://taxation-customs.ec.europa.eu/carbon-border-adjustment-mechanism_en',
              textDirection: TextDirection.ltr,
            ),
          ],
        ],
      );
    },
  );
}
