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
    String? title,
    String? startupName,
    OpportunityCategory? category,
    String? location,
    String? mode,
    String? compensation,
    int? matchScore,
    String? description,
    List<String>? skills,
  }) {
    return Opportunity(
      id: id,
      startupId: startupId,
      title: title ?? this.title,
      startupName: startupName ?? this.startupName,
      category: category ?? this.category,
      location: location ?? this.location,
      mode: mode ?? this.mode,
      compensation: compensation ?? this.compensation,
      matchScore: matchScore ?? this.matchScore,
      status: status ?? this.status,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      bookmarked: bookmarked ?? this.bookmarked,
    );
  }
}
