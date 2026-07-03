import '../models/application_record.dart';
import '../models/opportunity.dart';
import '../models/opportunity_category.dart';
import '../models/opportunity_status.dart';
import '../models/startup_profile.dart';
import '../models/startup_verification.dart';
import '../models/user_profile.dart';
import 'opportunity_repository.dart';

class MockOpportunityRepository implements OpportunityRepository {
  final List<StartupProfile> _startups = [
    StartupProfile(
      id: 'startup-1',
      name: 'Kigali Campus Eats',
      tagline: 'Student meal planning and delivery coordination',
      verificationStatus: StartupVerificationStatus.verified,
      focusArea: 'Operations + Product',
      memberCount: 8,
      location: 'ALU Kigali',
      createdAt: DateTime.now(),
    ),
    StartupProfile(
      id: 'startup-2',
      name: 'GreenLoop',
      tagline: 'Sustainability tools for student communities',
      verificationStatus: StartupVerificationStatus.verified,
      focusArea: 'Research + Marketing',
      memberCount: 6,
      location: 'ALU Kigali',
      createdAt: DateTime.now(),
    ),
    StartupProfile(
      id: 'startup-3',
      name: 'Unverified Studio',
      tagline: 'Design experiments without ALU verification',
      verificationStatus: StartupVerificationStatus.pending,
      focusArea: 'Creative',
      memberCount: 3,
      location: 'ALU Lagos',
      createdAt: DateTime.now(),
    ),
  ];

  final List<ApplicationRecord> _applications = [
    ApplicationRecord(
      id: 'app-1',
      opportunityId: 'opp-1',
      opportunityTitle: 'Frontend Product Intern',
      startupId: 'startup-1',
      startupName: 'Kigali Campus Eats',
      studentId: 'student-1',
      studentName: 'ALU Student',
      studentEmail: 'student@alu.ac.rw',
      status: 'Shortlisted',
      appliedAt: 'Today',
      updatedAt: DateTime.now(),
    ),
    ApplicationRecord(
      id: 'app-2',
      opportunityId: 'opp-2',
      opportunityTitle: 'Community Growth Associate',
      startupId: 'startup-2',
      startupName: 'GreenLoop',
      studentId: 'student-1',
      studentName: 'ALU Student',
      studentEmail: 'student@alu.ac.rw',
      status: 'Under review',
      appliedAt: '2 days ago',
      updatedAt: DateTime.now(),
    ),
  ];

  final List<Opportunity> _opportunities = [
    Opportunity(
      id: 'opp-1',
      startupId: 'startup-1',
      title: 'Frontend Product Intern',
      startupName: 'Kigali Campus Eats',
      category: OpportunityCategory.development,
      location: 'Hybrid',
      mode: '10-12 hrs/week',
      compensation: 'Stipend + mentorship',
      matchScore: 96,
      status: OpportunityStatus.open,
      description:
          'Help build the student ordering dashboard, improve accessibility, and ship features with a small founding team.',
      skills: ['Flutter', 'UI systems', 'Firebase'],
      bookmarked: true,
    ),
    Opportunity(
      id: 'opp-2',
      startupId: 'startup-2',
      title: 'Community Growth Associate',
      startupName: 'GreenLoop',
      category: OpportunityCategory.community,
      location: 'On campus',
      mode: 'Part-time',
      compensation: 'Volunteer + portfolio credit',
      matchScore: 88,
      status: OpportunityStatus.open,
      description:
          'Coordinate ambassador activities, events, and onboarding for new campus users in the ALU ecosystem.',
      skills: ['Community', 'Events', 'Content'],
      bookmarked: false,
    ),
    Opportunity(
      id: 'opp-3',
      startupId: 'startup-2',
      title: 'Research and Insights Intern',
      startupName: 'GreenLoop',
      category: OpportunityCategory.research,
      location: 'Remote',
      mode: 'Flexible',
      compensation: 'Certificate + references',
      matchScore: 81,
      status: OpportunityStatus.review,
      description:
          'Conduct interviews, analyze feedback, and produce insights that guide product and go-to-market decisions.',
      skills: ['Research', 'Writing', 'Analysis'],
      bookmarked: false,
    ),
    Opportunity(
      id: 'opp-4',
      startupId: 'startup-1',
      title: 'Design Systems Assistant',
      startupName: 'Kigali Campus Eats',
      category: OpportunityCategory.design,
      location: 'Hybrid',
      mode: 'Project-based',
      compensation: 'Mentorship + showcase',
      matchScore: 79,
      status: OpportunityStatus.closed,
      description:
          'Improve visual consistency across the startup dashboard and create reusable mobile-first components.',
      skills: ['Figma', 'Design systems', 'Accessibility'],
      bookmarked: false,
    ),
  ];

  @override
  Future<List<StartupProfile>> fetchStartups() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _startups;
  }

  @override
  Future<List<Opportunity>> fetchOpportunities() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return _opportunities;
  }

  @override
  Future<List<Opportunity>> fetchStartupOpportunities(String startupId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _opportunities.where((item) => item.startupId == startupId).toList();
  }

  @override
  Future<List<ApplicationRecord>> fetchApplications(UserProfile user) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (user.role == UserRole.startup) {
      return _applications.where((item) => item.startupId == user.id).toList();
    }
    return _applications
        .where(
          (item) => item.studentId == user.id || item.studentId == 'student-1',
        )
        .toList();
  }

  @override
  Future<void> submitApplication({
    required String opportunityId,
    required UserProfile student,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final opportunity = _opportunities.firstWhere(
      (item) => item.id == opportunityId,
    );
    _applications.insert(
      0,
      ApplicationRecord(
        id: 'app-${DateTime.now().millisecondsSinceEpoch}',
        opportunityId: opportunity.id,
        opportunityTitle: opportunity.title,
        startupId: opportunity.startupId,
        startupName: opportunity.startupName,
        studentId: student.id,
        studentName: student.displayName,
        studentEmail: student.email,
        status: 'Submitted',
        appliedAt: 'Just now',
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> toggleBookmark({
    required String userId,
    required String opportunityId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _opportunities.indexWhere((item) => item.id == opportunityId);
    if (index != -1) {
      _opportunities[index] = _opportunities[index].copyWith(
        bookmarked: !_opportunities[index].bookmarked,
      );
    }
  }

  @override
  Future<void> createOpportunity({
    required UserProfile startupUser,
    required String title,
    required OpportunityCategory category,
    required String location,
    required String mode,
    required String compensation,
    required String description,
    required List<String> skills,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _opportunities.insert(
      0,
      Opportunity(
        id: 'opp-${DateTime.now().millisecondsSinceEpoch}',
        startupId: startupUser.id,
        title: title,
        startupName: startupUser.displayName,
        category: category,
        location: location,
        mode: mode,
        compensation: compensation,
        matchScore: 85,
        status: OpportunityStatus.open,
        description: description,
        skills: skills,
        bookmarked: false,
      ),
    );
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _applications.indexWhere((item) => item.id == applicationId);
    if (index == -1) {
      return;
    }
    final existing = _applications[index];
    _applications[index] = ApplicationRecord(
      id: existing.id,
      opportunityId: existing.opportunityId,
      opportunityTitle: existing.opportunityTitle,
      startupId: existing.startupId,
      startupName: existing.startupName,
      studentId: existing.studentId,
      studentName: existing.studentName,
      studentEmail: existing.studentEmail,
      status: status,
      appliedAt: existing.appliedAt,
      updatedAt: DateTime.now(),
    );
  }
}
