import '../models/application_record.dart';
import '../models/opportunity.dart';
import '../models/opportunity_category.dart';
import '../models/startup_profile.dart';
import '../models/user_profile.dart';

abstract class OpportunityRepository {
  Future<List<StartupProfile>> fetchStartups();
  Future<List<Opportunity>> fetchOpportunities();
  Future<List<Opportunity>> fetchStartupOpportunities(String startupId);
  Future<List<ApplicationRecord>> fetchApplications(UserProfile user);
  Future<void> toggleBookmark({
    required String userId,
    required String opportunityId,
  });
  Future<void> submitApplication({
    required String opportunityId,
    required UserProfile student,
  });
  Future<void> createOpportunity({
    required UserProfile startupUser,
    required String title,
    required OpportunityCategory category,
    required String location,
    required String mode,
    required String compensation,
    required String description,
    required List<String> skills,
  });
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  });
}
