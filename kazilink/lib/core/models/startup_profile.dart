import 'startup_verification.dart';

class StartupProfile {
  const StartupProfile({
    required this.id,
    required this.name,
    required this.tagline,
    required this.verificationStatus,
    required this.focusArea,
    required this.memberCount,
    required this.location,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String tagline;
  final StartupVerificationStatus verificationStatus;
  final String focusArea;
  final int memberCount;
  final String location;
  final DateTime createdAt;

  bool get verified => verificationStatus == StartupVerificationStatus.verified;
}


