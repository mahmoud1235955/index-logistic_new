import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/company.dart';

class CompanyDetailsScreen extends StatelessWidget {
  const CompanyDetailsScreen({
    super.key,
    required this.company,
    required this.copy,
  });

  final Company company;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final reviewedAt = company.effectiveReviewedAt;
    final source = company.effectiveDataSource;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          company.name,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.end,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTokens.white,
                    border: Border.all(color: AppTokens.line),
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        company.name,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        copy.companyTrustLabel(company),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTokens.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _field(
                        context,
                        copy.countryLabel,
                        (copy.isArabic ? company.countryAr : company.country) ??
                            copy.unavailable,
                      ),
                      _field(
                        context,
                        copy.businessActivityLabel,
                        (copy.isArabic
                                ? company.businessActivityAr
                                : company.businessActivity) ??
                            copy.unavailable,
                      ),
                      _field(
                        context,
                        copy.productCategoryLabel,
                        (copy.isArabic ? company.productCategoryAr : null) ??
                            company.productCategory ??
                            copy.unavailable,
                      ),
                      _field(
                        context,
                        copy.lastReviewedLabel,
                        reviewedAt == null
                            ? copy.unavailable
                            : '${reviewedAt.year.toString().padLeft(4, '0')}-'
                                  '${reviewedAt.month.toString().padLeft(2, '0')}-'
                                  '${reviewedAt.day.toString().padLeft(2, '0')}',
                      ),
                      _field(
                        context,
                        copy.primaryDataSourceLabel,
                        source ?? copy.unavailable,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        copy.sectorDemoNote,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 3),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}
