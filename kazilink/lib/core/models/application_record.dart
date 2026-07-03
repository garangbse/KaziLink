class ApplicationRecord {
  const ApplicationRecord({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String status;
  final String appliedAt;
  final DateTime updatedAt;
}
