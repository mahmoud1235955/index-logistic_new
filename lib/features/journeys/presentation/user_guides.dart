import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import 'workspace_widgets.dart';

class UserGuides extends StatelessWidget {
  const UserGuides({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local('Walkthrough and glossary', 'دليل الاستخدام والمصطلحات'),
    children: [
      ContentPanel(
        title: copy.local('Choose a journey', 'اختر مسارًا'),
        children: [
          Text(
            copy.local(
              'Use Discover to filter products, companies and sectors. Use the catalog for the tools associated with a service.',
              'استخدم اكتشف لتصفية المنتجات والشركات والقطاعات. استخدم الفهرس للوصول إلى أدوات كل خدمة.',
            ),
          ),
        ],
      ),
      ContentPanel(
        title: copy.local(
          'Prepare and review a shipment',
          'جهّز الشحنة وراجعها',
        ),
        children: [
          Text(
            copy.local(
              'Describe your route and enter identical packages as groups. Review totals and confirm cargo requirements with a qualified source before using the draft.',
              'صف المسار وأدخل العبوات المتطابقة كمجموعات. راجع الإجماليات وأكد المتطلبات مع مصدر مؤهل قبل استخدام المسودة.',
            ),
          ),
          Text(
            copy.local(
              'Public tools are available as a guest. Publishing, delivery and staff actions require authorized accounts in the live product.',
              'الأدوات العامة متاحة للزوار. يتطلب النشر والإرسال وإجراءات الموظفين حسابات مخولة في المنتج الفعلي.',
            ),
          ),
        ],
      ),
      ContentPanel(
        title: copy.local('Glossary', 'المصطلحات'),
        children: [
          for (final (term, en, ar) in [
            (
              'CBM',
              'Cubic metres of cargo volume.',
              'حجم البضاعة بالمتر المكعب.',
            ),
            (
              'RFQ',
              'Request for quotation describing the shipment scope.',
              'طلب عرض سعر يصف نطاق الشحنة.',
            ),
            (
              'HS',
              'Harmonized System identifier used in customs classification.',
              'رمز النظام المنسق للتصنيف الجمركي.',
            ),
            (
              'UN number',
              'Dangerous-goods identifier checked against applicable references.',
              'معرّف للبضائع الخطرة يُراجع وفق المراجع المنطبقة.',
            ),
            (
              'SDS',
              'Safety data sheet prepared by a qualified source.',
              'صحيفة بيانات السلامة من مصدر مؤهل.',
            ),
            (
              'CBAM',
              'Carbon Border Adjustment Mechanism.',
              'آلية تعديل حدود الكربون.',
            ),
            (
              'Incoterms',
              'Trade terms allocating selected obligations, costs and risk.',
              'شروط تجارة لتوزيع التزامات وتكاليف ومخاطر محددة.',
            ),
          ])
            LabelValue(term, copy.local(en, ar)),
        ],
      ),
    ],
  );
}
