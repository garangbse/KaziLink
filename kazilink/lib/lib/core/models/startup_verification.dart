enum StartupVerificationStatus { pending, underReview, verified, rejected }

extension StartupVerificationStatusX on StartupVerificationStatus {
  String get label => switch (this) {
    StartupVerificationStatus.pending => 'Pending',
    StartupVerificationStatus.underReview => 'Under review',
    StartupVerificationStatus.verified => 'Verified',
    StartupVerificationStatus.rejected => 'Rejected',
  };
}
