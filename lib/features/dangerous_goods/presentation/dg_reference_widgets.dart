import 'package:flutter/material.dart';

import '../domain/dg_models.dart';
import 'dg_copy.dart';
import 'dg_widgets.dart';

class DgReferences extends StatelessWidget {
  const DgReferences({super.key, required this.copy, this.mode});
  final DgCopy copy;
  final DgMode? mode;

  @override
  Widget build(BuildContext context) => ContentPanel(
    title: copy.tr('Publication directories', 'أدلة المنشورات'),
    children: [
      Text(
        copy.tr(
          'Directory links are for specialist reference. Applicable editions, amendments and rule records are unavailable in this preview.',
          'روابط الأدلة مرجعية للمختص. الإصدارات والتعديلات وسجلات القواعد المنطبقة غير متاحة في هذه المعاينة.',
        ),
      ),
      for (final source in Framework.values)
        if (mode == null || source.mode == mode) ...[
          Text(
            copy.framework(source),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (source.url.isNotEmpty)
            SelectableText(source.url, textDirection: TextDirection.ltr),
        ],
    ],
  );
}

class DgDocuments extends StatelessWidget {
  const DgDocuments({
    super.key,
    required this.copy,
    this.mode,
    this.battery = false,
  });
  final DgCopy copy;
  final DgMode? mode;
  final bool battery;

  @override
  Widget build(BuildContext context) => ContentPanel(
    title: copy.tr(
      'Documents to discuss with a specialist',
      'وثائق تُناقش مع المختص',
    ),
    children: [
      Text(
        copy.tr(
          'This is a preparation checklist. A specialist must confirm applicability.',
          'هذه قائمة للتجهيز. يجب أن يؤكد المختص انطباق الوثائق.',
        ),
      ),
      for (final doc in DgDocument.values)
        if (battery || doc != DgDocument.batteryTests)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('• ${copy.document(doc)}'),
          ),
      if (mode != null)
        Text(switch (mode!) {
          DgMode.air => copy.tr(
            'Confirm the air waybill and operator paperwork.',
            'تحقق من بوليصة الشحن الجوي ووثائق المشغّل.',
          ),
          DgMode.sea => copy.tr(
            'Confirm sea transport and any container-related paperwork.',
            'تحقق من وثائق النقل البحري وأي وثائق مرتبطة بالحاوية.',
          ),
          DgMode.road => copy.tr(
            'Confirm road transport and jurisdiction-specific paperwork.',
            'تحقق من وثائق النقل البري والوثائق الخاصة بالاختصاص.',
          ),
        }),
    ],
  );
}
