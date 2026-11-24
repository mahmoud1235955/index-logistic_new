enum Verification { verified, unverified, synthetic }

class LegalReference {
  const LegalReference({
    required this.verification,
    required this.effectiveFrom,
    this.effectiveUntil,
    this.title,
    this.url,
  });

  final Verification verification;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final String? title;
  final Uri? url;

  bool covers(DateTime date) =>
      !date.isBefore(effectiveFrom) &&
      (effectiveUntil == null || !date.isAfter(effectiveUntil!));

  bool get hasOfficialCitation =>
      verification == Verification.verified &&
      (title?.trim().isNotEmpty ?? false) &&
      url?.scheme == 'https' &&
      (url?.hasAuthority ?? false);
}
