import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application_record.dart';
import '../models/opportunity.dart';
import '../models/opportunity_category.dart';
import '../models/opportunity_status.dart';
import '../models/startup_profile.dart';
import '../models/startup_verification.dart';
import '../models/user_profile.dart';
import 'opportunity_repository.dart';

class FirebaseOpportunityRepository implements OpportunityRepository {
  FirebaseOpportunityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups =>
      _firestore.collection('startups');
  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection('opportunities');
  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  @override
  Future<List<StartupProfile>> fetchStartups() async {
    final snapshot = await _startups
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(_startupFromDoc).toList();
  }

  @override
  Future<List<Opportunity>> fetchOpportunities() async {
    final snapshot = await _opportunities
        .where('status', isNotEqualTo: OpportunityStatus.closed.name)
        .get();
    return snapshot.docs.map(_opportunityFromDoc).toList();
  }

  @override
  Future<List<Opportunity>> fetchStartupOpportunities(String startupId) async {
    final snapshot = await _opportunities
        .where('startupId', isEqualTo: startupId)
        .get();
    final opportunities = snapshot.docs.map(_opportunityFromDoc).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    return opportunities;
  }

  @override
  Future<List<ApplicationRecord>> fetchApplications(UserProfile user) async {
    final field = user.role == UserRole.startup ? 'startupId' : 'studentId';
    final snapshot = await _applications.where(field, isEqualTo: user.id).get();
    final applications = snapshot.docs.map(_applicationFromDoc).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return applications;
  }

  @override
  Future<void> toggleBookmark({
    required String userId,
    required String opportunityId,
  }) async {
    final bookmarkRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(opportunityId);
    final doc = await bookmarkRef.get();
    if (doc.exists) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'opportunityId': opportunityId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> submitApplication({
    required String opportunityId,
    required UserProfile student,
  }) async {
    if (student.role != UserRole.student) {
      throw StateError('Only students can apply to opportunities.');
    }

    final opportunitySnapshot = await _opportunities.doc(opportunityId).get();
    final data = opportunitySnapshot.data();
    if (data == null) {
      throw StateError('Opportunity not found');
    }

    final existing = await _applications
        .where('opportunityId', isEqualTo: opportunityId)
        .where('studentId', isEqualTo: student.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('You have already applied to this opportunity.');
    }

    final applicationRef = _applications.doc();
    await applicationRef.set({
      'id': applicationRef.id,
      'opportunityId': opportunityId,
      'opportunityTitle': data['title'] as String? ?? 'Opportunity',
      'startupId': data['startupId'] as String? ?? '',
      'startupName': data['startupName'] as String? ?? 'Startup',
      'studentId': student.id,
      'studentName': student.displayName,
      'studentEmail': student.email,
      'status': 'Submitted',
      'appliedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
    if (startupUser.role != UserRole.startup) {
      throw StateError('Only startup users can create opportunities.');
    }

    final opportunityRef = _opportunities.doc();
    await opportunityRef.set({
      'id': opportunityRef.id,
      'startupId': startupUser.id,
      'startupName': startupUser.displayName,
      'title': title,
      'category': category.name,
      'location': location,
      'mode': mode,
      'compensation': compensation,
      'matchScore': 85,
      'status': OpportunityStatus.open.name,
      'description': description,
      'skills': skills,
      'bookmarked': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _startups.doc(startupUser.id).set({
      'name': startupUser.displayName,
      'tagline': 'Startup opportunities on KaziLink',
      'verificationStatus': StartupVerificationStatus.pending.name,
      'focusArea': category.label,
      'memberCount': 1,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    await _applications.doc(applicationId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  StartupProfile _startupFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return StartupProfile(
      id: doc.id,
      name: data['name'] as String? ?? 'Startup',
      tagline: data['tagline'] as String? ?? '',
      verificationStatus: StartupVerificationStatus.values.firstWhere(
        (value) => value.name == data['verificationStatus'],
        orElse: () => StartupVerificationStatus.pending,
      ),
      focusArea: data['focusArea'] as String? ?? '',
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
      location: data['location'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Opportunity _opportunityFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      category: OpportunityCategory.values.firstWhere(
        (value) => value.name == data['category'],
        orElse: () => OpportunityCategory.development,
      ),
      location: data['location'] as String? ?? '',
      mode: data['mode'] as String? ?? '',
      compensation: data['compensation'] as String? ?? '',
      matchScore: (data['matchScore'] as num?)?.toInt() ?? 0,
      status: OpportunityStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => OpportunityStatus.open,
      ),
      description: data['description'] as String? ?? '',
      skills: List<String>.from(data['skills'] as List<dynamic>? ?? const []),
      bookmarked: data['bookmarked'] as bool? ?? false,
    );
  }

  ApplicationRecord _applicationFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ApplicationRecord(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? 'Student',
      studentEmail: data['studentEmail'] as String? ?? '',
      status: data['status'] as String? ?? 'Submitted',
      appliedAt: _formatTimestamp(data['appliedAt'] as Timestamp?),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Just now';
    }
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
