import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/company.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({
    super.key,
    required this.company,
    required this.copy,
    required this.onPrimaryAction,
  });

  final Company company;
  final AppCopy copy;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final reviewedAt = company.effectiveReviewedAt;
    final dataSource = company.effectiveDataSource;
    return Container(
      key: ValueKey('company-card-${company.name}'),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTokens.white,
        border: Border.all(color: AppTokens.line),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Color(company.accent).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    company.initials,
                    style: TextStyle(
                      color: Color(company.accent),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _trustPill(context),
          ),
          const SizedBox(height: 15),
          _infoLine(
            context,
            copy.countryLabel,
            (copy.isArabic ? company.countryAr : company.country) ??
                copy.unavailable,
          ),
          _infoLine(
            context,
            copy.businessActivityLabel,
            (copy.isArabic
                    ? company.businessActivityAr
                    : company.businessActivity) ??
                copy.unavailable,
          ),
          _infoLine(
            context,
            copy.productCategoryLabel,
            (copy.isArabic ? company.productCategoryAr : null) ??
                company.productCategory ??
                copy.unavailable,
          ),
          _infoLine(
            context,
            copy.lastReviewedLabel,
            reviewedAt == null ? copy.unavailable : _date(reviewedAt),
          ),
          _infoLine(
            context,
            copy.primaryDataSourceLabel,
            dataSource ?? copy.unavailable,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: ValueKey('company-cta-${company.name}'),
            onPressed: onPrimaryAction,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(copy.viewCompanyDetails),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );

  Widget _trustPill(BuildContext context) {
    final verified = company.isVerified;
    final label = copy.companyTrustLabel(company);
    final color = verified ? AppTokens.green : AppTokens.navy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: verified ? AppTokens.greenSoft : AppTokens.canvas,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        runSpacing: 3,
        children: [
          if (verified)
            const Icon(
              Icons.verified_rounded,
              size: 15,
              color: AppTokens.green,
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
