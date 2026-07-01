import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application_record.dart';
import '../models/opportunity.dart';
import '../models/opportunity_category.dart';
import '../models/opportunity_status.dart';
import '../models/startup_profile.dart';
import '../models/startup_verification.dart';
import 'opportunity_repository.dart';

class FirebaseOpportunityRepository implements OpportunityRepository {
  FirebaseOpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups => _firestore.collection('startups');
  CollectionReference<Map<String, dynamic>> get _opportunities => _firestore.collection('opportunities');
  CollectionReference<Map<String, dynamic>> get _applications => _firestore.collection('applications');

  @override
  Future<List<StartupProfile>> fetchStartups() async {
    final snapshot = await _startups.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_startupFromDoc).toList();
  }

  @override
  Future<List<Opportunity>> fetchOpportunities() async {
    final snapshot = await _opportunities.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_opportunityFromDoc).toList();
  }

  @override
  Future<List<ApplicationRecord>> fetchApplications() async {
    final snapshot = await _applications.orderBy('updatedAt', descending: true).get();
    return snapshot.docs.map(_applicationFromDoc).toList();
  }

  @override
  Future<void> toggleBookmark(String opportunityId) async {
    final doc = await _opportunities.doc(opportunityId).get();
    final current = doc.data()?['bookmarked'] as bool? ?? false;
    await _opportunities.doc(opportunityId).set({'bookmarked': !current}, SetOptions(merge: true));
  }

  @override
  Future<void> submitInterest(String opportunityId) async {
    final opportunitySnapshot = await _opportunities.doc(opportunityId).get();
    final data = opportunitySnapshot.data();
    if (data == null) {
      throw StateError('Opportunity not found');
    }

    final applicationId = '${opportunityId}_${DateTime.now().millisecondsSinceEpoch}';
    await _applications.doc(applicationId).set({
      'id': applicationId,
      'opportunityId': opportunityId,
      'opportunityTitle': data['title'] as String? ?? 'Opportunity',
      'startupName': data['startupName'] as String? ?? 'Startup',
      'status': 'Submitted',
      'appliedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  StartupProfile _startupFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

  Opportunity _opportunityFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

  ApplicationRecord _applicationFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ApplicationRecord(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
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
