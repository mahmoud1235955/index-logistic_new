import 'legal_reference.dart';

enum EligibilityStatus { eligible, notEligible, conditional, undetermined }

enum AssessmentIssue { noApplicableRule, unverifiedRule, confirmEvidence }

enum SupportingDocument {
  purchaseEvidence,
  vehicleSpecification,
  originEvidence,
  regimeEvidence,
}

class EligibilityRule {
  const EligibilityRule({
    required this.status,
    required this.reference,
    this.documents = const [],
    this.reason,
  });

  final EligibilityStatus status;
  final LegalReference reference;
  final List<SupportingDocument> documents;
  final ({String english, String arabic})? reason;
}

class EligibilityAssessment {
  const EligibilityAssessment({
    required this.status,
    required this.issues,
    this.rule,
  });

  final EligibilityStatus status;
  final List<AssessmentIssue> issues;
  final EligibilityRule? rule;

  static EligibilityAssessment evaluate(
    EligibilityRule? rule,
    DateTime date, {
    required bool demonstration,
  }) {
    if (rule == null || !rule.reference.covers(date)) {
      return const EligibilityAssessment(
        status: EligibilityStatus.undetermined,
        issues: [AssessmentIssue.noApplicableRule],
      );
    }
    final usable = demonstration
        ? rule.reference.verification == Verification.synthetic
        : rule.reference.hasOfficialCitation;
    if (!usable) {
      return EligibilityAssessment(
        status: EligibilityStatus.undetermined,
        issues: const [AssessmentIssue.unverifiedRule],
        rule: rule,
      );
    }
    return EligibilityAssessment(
      status: rule.status,
      issues: [
        if (rule.status == EligibilityStatus.conditional)
          AssessmentIssue.confirmEvidence,
        if (rule.status == EligibilityStatus.undetermined)
          AssessmentIssue.noApplicableRule,
      ],
      rule: rule,
    );
  }
}
