import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../auth/firebase_auth_repository.dart';

import '../data/firebase_opportunity_repository.dart';
import '../data/opportunity_repository.dart';
import '../models/application_record.dart';
import '../models/opportunity.dart';
import '../models/opportunity_category.dart';
import '../models/startup_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return FirebaseOpportunityRepository();
});

final startupsProvider = FutureProvider<List<StartupProfile>>((ref) async {
  return ref.watch(opportunityRepositoryProvider).fetchStartups();
});

final opportunitiesProvider = FutureProvider<List<Opportunity>>((ref) async {
  return ref.watch(opportunityRepositoryProvider).fetchOpportunities();
});

final applicationsProvider = FutureProvider<List<ApplicationRecord>>((ref) async {
  return ref.watch(opportunityRepositoryProvider).fetchApplications();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<OpportunityCategory?>((ref) => null);

final selectedApplicationStatusFilterProvider = StateProvider<String?>((ref) => null);
