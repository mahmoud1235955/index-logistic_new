enum CompanyTrustStatus { sample, unclaimed, claimed, reviewed, verified }

/// Evidence required before a verified badge can be shown.
///
/// Values are intentionally absent from local demo fixtures. A data provider
/// must supply the actual source, review date, and evidence reference.
class CompanyVerificationEvidence {
  const CompanyVerificationEvidence({
    required this.source,
    required this.reviewedAt,
    required this.reference,
  });

  final String source;
  final DateTime reviewedAt;
  final String reference;

  bool get isComplete =>
      source.trim().isNotEmpty && reference.trim().isNotEmpty;
}

class Company {
  const Company({
    required this.name,
    required this.category,
    required this.location,
    required this.initials,
    required this.accent,
    this.country,
    this.countryAr,
    this.businessActivityAr,
    this.productCategory,
    this.productCategoryAr,
    this.lastReviewedAt,
    this.primaryDataSource,
    this.sectorId,
    this.trustStatus = CompanyTrustStatus.sample,
    this.verificationEvidence,
  });

  final String name;

  /// English business activity. Kept as `category` for existing callers.
  final String category;
  final String? businessActivityAr;
  final String? country;
  final String? countryAr;
  final String? productCategory;
  final String? productCategoryAr;
  final String location;
  final String initials;
  final int accent;
  final DateTime? lastReviewedAt;
  final String? primaryDataSource;
  final String? sectorId;
  final CompanyTrustStatus trustStatus;
  final CompanyVerificationEvidence? verificationEvidence;

  String get businessActivity => category;

  bool get isVerified =>
      trustStatus == CompanyTrustStatus.verified &&
      verificationEvidence?.isComplete == true;

  DateTime? get effectiveReviewedAt =>
      lastReviewedAt ?? (isVerified ? verificationEvidence!.reviewedAt : null);

  String? get effectiveDataSource =>
      primaryDataSource ?? (isVerified ? verificationEvidence!.source : null);
}
