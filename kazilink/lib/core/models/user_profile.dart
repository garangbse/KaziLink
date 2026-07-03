enum UserRole { student, startup }

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.student => 'Student',
    UserRole.startup => 'Startup',
  };
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.onboardingComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String email;
  final UserRole role;
  final bool onboardingComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile copyWith({
    String? displayName,
    String? email,
    UserRole? role,
    bool? onboardingComplete,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
