import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/user_profile.dart';
import '../../shared/widgets/feature_cards.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          ProfileHeader(userName: authState.user?.displayName ?? 'ALU Student', userEmail: authState.user?.email ?? 'student@alu.ac.rw', roleLabel: authState.user?.role.label ?? 'Student'),
          const SizedBox(height: 20),
          SectionTitle(title: 'Workflow notes'),
          const SizedBox(height: 12),
          const WorkflowNote(
            title: 'Verified startups only',
            description: 'Startup onboarding includes an ALU verification review before opportunities can be published.',
          ),
          const WorkflowNote(
            title: 'Firebase-ready architecture',
            description: 'The repository abstraction allows Firestore and Auth to be wired in without changing the UI layer.',
          ),
          const WorkflowNote(
            title: 'State management',
            description: 'Riverpod handles data refresh, filters, and cross-screen state in a predictable way.',
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Suggested next build steps'),
          const SizedBox(height: 12),
          const WorkflowNote(
            title: 'Connect Firebase',
            description: 'Add Firebase initialization plus Firestore collections for users, startups, opportunities, and applications.',
          ),
          const WorkflowNote(
            title: 'Add auth flows',
            description: 'Create onboarding, login, and role-specific home states for students and startup operators.',
          ),
          const WorkflowNote(
            title: 'Persist actions',
            description: 'Save bookmarks and applications directly to the backend so demo actions appear in the Firebase console.',
          ),
        ],
      ),
    );
  }
}
