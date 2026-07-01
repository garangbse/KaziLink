class ApplicationRecord {
  const ApplicationRecord({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String status;
  final String appliedAt;
  final DateTime updatedAt;
}
