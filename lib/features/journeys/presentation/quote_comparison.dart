import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import 'workspace_widgets.dart';

class QuoteComparison extends StatelessWidget {
  const QuoteComparison({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local('Synthetic quotation comparison', 'مقارنة عروض اصطناعية'),
    children: [
      WorkspaceNotice(
        copy: copy,
        message: copy.local(
          'Fictional alternatives for the same example route, cargo and service scope. Supplier offers remain unavailable.',
          'بدائل خيالية لنفس المسار والبضاعة ونطاق الخدمة التوضيحي. عروض المزودين غير متاحة.',
        ),
      ),
      ContentPanel(
        children: [
          LabelValue(
            copy.local('Shared scope', 'النطاق المشترك'),
            copy.local(
              'Example port A → port B · 2 cartons · port-to-port sea carriage',
              'ميناء توضيحي أ ← ميناء توضيحي ب · كرتونتان · شحن بحري بين الميناءين',
            ),
          ),
          LabelValue(
            copy.local('Included', 'المشمول'),
            copy.local(
              'Sea freight and terminal handling',
              'الشحن البحري ومناولة المحطة',
            ),
          ),
          LabelValue(
            copy.local('Excluded', 'المستثنى'),
            copy.local(
              'Inland transport, insurance and taxes',
              'النقل الداخلي والتأمين والضرائب',
            ),
          ),
        ],
      ),
      AdaptiveGrid(
        children: [
          for (final (id, freight, handling, days, validity) in [
            ('A', 180, 30, 8, 5),
            ('B', 190, 25, 6, 4),
          ])
            ContentPanel(
              title: copy.local('Synthetic offer $id', 'عرض اصطناعي $id'),
              children: [
                LabelValue(
                  copy.local('Base freight', 'أجرة الشحن الأساسية'),
                  '$freight USD',
                ),
                LabelValue(
                  copy.local('Terminal handling', 'مناولة المحطة'),
                  '$handling USD',
                ),
                LabelValue(
                  copy.local(
                    'Comparable subtotal',
                    'المجموع الفرعي القابل للمقارنة',
                  ),
                  '${freight + handling} USD',
                ),
                LabelValue(
                  copy.local('Illustrative transit', 'مدة النقل التوضيحية'),
                  copy.local('$days days', '$days أيام'),
                ),
                LabelValue(
                  copy.local(
                    'Illustrative validity window',
                    'مدة الصلاحية التوضيحية',
                  ),
                  copy.local(
                    '$validity days in the example',
                    '$validity أيام في المثال',
                  ),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}
