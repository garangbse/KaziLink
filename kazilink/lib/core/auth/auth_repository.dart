import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> loadCurrentUser();
  Future<UserProfile> signUp({required String email, required String password});
  Future<UserProfile> signIn({required String email, required String password});
  Future<UserProfile> completeOnboarding({
    required UserProfile user,
    required String displayName,
    required UserRole role,
  });
  Future<void> signOut();
}
