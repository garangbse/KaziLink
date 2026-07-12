import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../core/models/user_profile.dart';
import '../features/applications/applications_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/opportunities/opportunity_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/startup/startup_applications_screen.dart';
import '../features/startup/startup_opportunities_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final isStartup = user?.role == UserRole.startup;
    final pages = isStartup
        ? const [
            DashboardScreen(),
            StartupOpportunitiesScreen(),
            StartupApplicationsScreen(),
            ProfileScreen(),
          ]
        : const [
            DashboardScreen(),
            OpportunityScreen(),
            ApplicationsScreen(),
            ProfileScreen(),
          ];
    final destinations = isStartup
        ? const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_business_outlined),
              selectedIcon: Icon(Icons.add_business),
              label: 'Roles',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Applicants',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Applied',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: destinations,
      ),
    );
  }
}
