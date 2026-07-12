import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<UserProfile?> loadCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    final snapshot = await _users.doc(firebaseUser.uid).get();
    if (!snapshot.exists) {
      return UserProfile(
        id: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'ALU User',
        email: firebaseUser.email ?? '',
        role: UserRole.student,
        onboardingComplete: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return _fromDoc(snapshot);
  }

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Sign up succeeded but Firebase user is null.');
    }

    final profile = UserProfile(
      id: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? 'ALU User',
      email: firebaseUser.email ?? email,
      role: UserRole.student,
      onboardingComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _users
        .doc(firebaseUser.uid)
        .set(_toDoc(profile), SetOptions(merge: true));
    return profile;
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Sign in succeeded but Firebase user is null.');
    }

    final snapshot = await _users.doc(firebaseUser.uid).get();
    if (snapshot.exists) {
      return _fromDoc(snapshot);
    }

    final profile = UserProfile(
      id: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? 'ALU User',
      email: firebaseUser.email ?? email,
      role: UserRole.student,
      onboardingComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _users
        .doc(firebaseUser.uid)
        .set(_toDoc(profile), SetOptions(merge: true));
    return profile;
  }

  @override
  Future<UserProfile> completeOnboarding({
    required UserProfile user,
    required String displayName,
    required UserRole role,
  }) async {
    final updated = user.copyWith(
      displayName: displayName,
      role: role,
      onboardingComplete: true,
      updatedAt: DateTime.now(),
    );
    await _users.doc(updated.id).set(_toDoc(updated), SetOptions(merge: true));
    await _auth.currentUser?.updateDisplayName(displayName);
    return updated;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserProfile _fromDoc(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final roleName = data['role'] as String?;
    final role = roleName == 'startupFounder' || roleName == 'startupTeam'
        ? UserRole.startup
        : UserRole.values.firstWhere(
            (value) => value.name == roleName,
            orElse: () => UserRole.student,
          );

    return UserProfile(
      id: snapshot.id,
      displayName: data['displayName'] as String? ?? 'ALU User',
      email: data['email'] as String? ?? '',
      role: role,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toDoc(UserProfile profile) {
    return {
      'displayName': profile.displayName,
      'email': profile.email,
      'role': profile.role.name,
      'onboardingComplete': profile.onboardingComplete,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': Timestamp.fromDate(profile.updatedAt),
    };
  }
}
