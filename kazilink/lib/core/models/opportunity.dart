import 'opportunity_category.dart';
import 'opportunity_status.dart';

class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.title,
    required this.startupName,
    required this.category,
    required this.location,
    required this.mode,
    required this.compensation,
    required this.matchScore,
    required this.status,
    required this.description,
    required this.skills,
    required this.bookmarked,
  });

  final String id;
  final String startupId;
  final String title;
  final String startupName;
  final OpportunityCategory category;
  final String location;
  final String mode;
  final String compensation;
  final int matchScore;
  final OpportunityStatus status;
  final String description;
  final List<String> skills;
  final bool bookmarked;

  Opportunity copyWith({
    bool? bookmarked,
    OpportunityStatus? status,
  }) {
    return Opportunity(
      id: id,
      startupId: startupId,
      title: title,
      startupName: startupName,
      category: category,
      location: location,
      mode: mode,
      compensation: compensation,
      matchScore: matchScore,
      status: status ?? this.status,
      description: description,
      skills: skills,
      bookmarked: bookmarked ?? this.bookmarked,
    );
  }
}
