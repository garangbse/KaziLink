import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController(text: 'ALU Student');
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Complete your profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the role that matches how you will use KaziLink so the platform can personalize your experience.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Display name'),
                  ),
                  const SizedBox(height: 16),
                  Text('Select your role', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: UserRole.values.map((role) {
                      final isSelected = role == _selectedRole;
                      return ChoiceChip(
                        label: Text(role.label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedRole = role),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    switch (_selectedRole) {
                      UserRole.student => 'Discover and apply for internships and project-based roles.',
                      UserRole.startupFounder => 'Post opportunities and verify startup needs.',
                      UserRole.startupTeam => 'Manage applications and applicant workflows.',
                    },
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).completeOnboarding(
                              displayName: _nameController.text.trim(),
                              role: _selectedRole,
                            ),
                    child: authState.isLoading ? const CircularProgressIndicator() : const Text('Finish onboarding'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
