import '../models/application_record.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';

abstract class OpportunityRepository {
  Future<List<StartupProfile>> fetchStartups();
  Future<List<Opportunity>> fetchOpportunities();
  Future<List<ApplicationRecord>> fetchApplications();
  Future<void> toggleBookmark(String opportunityId);
  Future<void> submitInterest(String opportunityId);
}
