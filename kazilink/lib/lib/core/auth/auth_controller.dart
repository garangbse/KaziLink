import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../state/app_providers.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.user,
    required this.errorMessage,
  });

  const AuthState.unknown()
    : isLoading = true,
      user = null,
      errorMessage = null;

  final bool isLoading;
  final UserProfile? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  bool get needsOnboarding => user != null && !user!.onboardingComplete;

  AuthState copyWith({
    bool? isLoading,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref)..loadSession();
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState.unknown());

  final Ref _ref;

  Future<void> loadSession() async {
    try {
      final user = await _ref.read(authRepositoryProvider).loadCurrentUser();
      state = AuthState(isLoading: false, user: user, errorMessage: null);
    } catch (error) {
      state = AuthState(
        isLoading: false,
        user: null,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = AuthState(isLoading: false, user: user, errorMessage: null);
    } catch (error) {
      state = AuthState(
        isLoading: false,
        user: null,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password);
      state = AuthState(isLoading: false, user: user, errorMessage: null);
    } catch (error) {
      state = AuthState(
        isLoading: false,
        user: null,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> completeOnboarding({
    required String displayName,
    required UserRole role,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .completeOnboarding(
            user: currentUser,
            displayName: displayName,
            role: role,
          );
      state = AuthState(isLoading: false, user: user, errorMessage: null);
    } catch (error) {
      state = AuthState(
        isLoading: false,
        user: currentUser,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    state = const AuthState(isLoading: false, user: null, errorMessage: null);
  }
}
