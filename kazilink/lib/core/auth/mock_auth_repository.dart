import '../models/user_profile.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserProfile? _currentUser;

  @override
  Future<UserProfile?> loadCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _currentUser;
  }

  @override
  Future<UserProfile> signUp({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = UserProfile(
      id: 'alu-demo-user',
      displayName: 'ALU User',
      email: email,
      role: UserRole.student,
      onboardingComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<UserProfile> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = UserProfile(
      id: 'alu-demo-student',
      displayName: 'ALU Student',
      email: email,
      role: UserRole.student,
      onboardingComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<UserProfile> completeOnboarding({
    required UserProfile user,
    required String displayName,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _currentUser = user.copyWith(
      displayName: displayName,
      role: role,
      onboardingComplete: true,
      updatedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }
}
