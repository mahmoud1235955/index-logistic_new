import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import 'workspace_widgets.dart';

class PaymentGuides extends StatelessWidget {
  const PaymentGuides({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => WorkspacePage(
    title: copy.local('International payment methods', 'طرق الدفع الدولية'),
    children: [
      ContentPanel(
        highlight: true,
        children: [
          Text(
            copy.local(
              'Compare payment timing, document responsibilities and risks. Agree the actual contract terms with the counterparty and bank.',
              'قارن توقيت الدفع ومسؤوليات المستندات والمخاطر. اتفق على الشروط الفعلية مع الطرف المقابل والبنك.',
            ),
          ),
        ],
      ),
      for (final (en, ar, detail, detailAr) in _methods)
        ContentPanel(
          title: copy.local(en, ar),
          children: [Text(copy.local(detail, detailAr))],
        ),
      const SelectableText(
        'https://www.trade.gov/report/trade-finance-guide',
        textDirection: TextDirection.ltr,
      ),
    ],
  );
}

const _methods = [
  (
    'Advance payment',
    'الدفع المقدم',
    'The buyer pays before dispatch. The seller checks receipt and fulfills the contract. The buyer carries exposure to delayed delivery or non-performance.',
    'يدفع المشتري قبل الإرسال. يتحقق البائع من الاستلام وينفذ العقد. يتحمل المشتري مخاطر تأخر التسليم أو عدم التنفيذ.',
  ),
  (
    'Open account',
    'الحساب المفتوح',
    'The seller invoices the buyer on agreed credit terms. The buyer pays at maturity. Assess buyer credit, late payment and exchange-rate exposure.',
    'يصدر البائع فاتورة بشروط ائتمان متفق عليها. يدفع المشتري عند الاستحقاق. قيّم الجدارة الائتمانية وتأخر الدفع ومخاطر الصرف.',
  ),
  (
    'Documentary collection',
    'التحصيل المستندي',
    'Banks pass documents and release instructions. The seller provides the documents and the buyer pays or accepts the relevant obligation. Refusal, delay or insufficient control of goods can leave the seller exposed.',
    'تنقل البنوك المستندات وتعليمات تسليمها. يقدم البائع المستندات ويدفع المشتري أو يقبل الالتزام المعني. قد يواجه البائع مخاطر الرفض أو التأخير أو ضعف السيطرة على البضاعة.',
  ),
  (
    'Documentary credit',
    'الاعتماد المستندي',
    'The buyer arranges a credit. The seller presents documents meeting its terms within the deadlines. Check discrepancies, bank and country risk, costs and the scope of any confirmation.',
    'يرتب المشتري اعتمادًا. يقدم البائع مستندات مطابقة لشروطه خلال المواعيد. تحقق من الاختلافات ومخاطر البنك والدولة والتكاليف ونطاق أي تعزيز.',
  ),
  (
    'Bank transfer',
    'التحويل المصرفي',
    'Transfer is a payment channel. Agree separately when payment is due and who pays fees. Confirm recipient details through a known channel and allow for settlement, intermediary fees and currency conversion.',
    'التحويل قناة للدفع. اتفق بشكل منفصل على موعد الاستحقاق ومن يدفع الرسوم. أكد بيانات المستلم عبر قناة معروفة وضع في الحسبان التسوية ورسوم الوسطاء وتحويل العملة.',
  ),
];
