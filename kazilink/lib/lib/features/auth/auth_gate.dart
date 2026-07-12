import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../auth/onboarding_screen.dart';
import '../auth/sign_in_screen.dart';
import '../../app/app_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authState.isAuthenticated) {
      return const SignInScreen();
    }

    if (authState.needsOnboarding) {
      return const OnboardingScreen();
    }

    return const AppShell();
  }
}
