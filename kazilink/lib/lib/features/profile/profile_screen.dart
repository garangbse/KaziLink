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
          ProfileHeader(
            userName: authState.user?.displayName ?? 'ALU Student',
            userEmail: authState.user?.email ?? 'student@alu.ac.rw',
            roleLabel: authState.user?.role.label ?? 'Student',
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Workflow notes'),
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Suggested next build steps'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
