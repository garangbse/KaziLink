import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/opportunity.dart';
import '../../core/models/opportunity_category.dart';
import '../../core/models/opportunity_status.dart';
import '../../core/models/user_profile.dart';
import '../../core/state/app_providers.dart';
import '../../shared/widgets/feature_cards.dart';

enum DashboardOpportunityFilter { all, tech, entrepreneurship }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardOpportunityFilter _selectedFilter = DashboardOpportunityFilter.all;

  @override
  Widget build(BuildContext context) {
    final startupsAsync = ref.watch(startupsProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(startupsProvider);
          ref.invalidate(opportunitiesProvider);
          ref.invalidate(applicationsProvider);
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            HeroCard(
              title: 'KaziLink',
              subtitle:
                  'Match ALU students with verified startups and meaningful internships.',
              accent: 'ALU ecosystem ready',
              onAction: () => ref.read(searchQueryProvider.notifier).state = '',
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Verified startups',
                    value: '24',
                    icon: Icons.verified_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MetricTile(
                    label: 'Open roles',
                    value: '61',
                    icon: Icons.work_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Match rate',
                    value: '91%',
                    icon: Icons.insights_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MetricTile(
                    label: 'Applications',
                    value: '128',
                    icon: Icons.send_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Verified startup pipeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            startupsAsync.when(
              data: (startups) => Column(
                children: startups
                    .map(
                      (startup) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StartupCard(startup: startup),
                      ),
                    )
                    .toList(),
              ),
              loading: () => const LoadingCard(height: 120),
              error: (error, stackTrace) => StateCard(
                title: 'Unable to load startups',
                subtitle: '$error',
                icon: Icons.error_outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Opportunities',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DashboardFilterChip(
                    label: 'All',
                    selected: _selectedFilter == DashboardOpportunityFilter.all,
                    onTap: () => setState(
                      () => _selectedFilter = DashboardOpportunityFilter.all,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DashboardFilterChip(
                    label: 'Tech',
                    selected:
                        _selectedFilter == DashboardOpportunityFilter.tech,
                    onTap: () => setState(
                      () => _selectedFilter = DashboardOpportunityFilter.tech,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DashboardFilterChip(
                    label: 'Entrepreneurship',
                    selected:
                        _selectedFilter ==
                        DashboardOpportunityFilter.entrepreneurship,
                    onTap: () => setState(
                      () => _selectedFilter =
                          DashboardOpportunityFilter.entrepreneurship,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            opportunitiesAsync.when(
              data: (opportunities) {
                final filteredOpportunities = opportunities
                    .where(_matchesFilter)
                    .take(3)
                    .toList();
                if (filteredOpportunities.isEmpty) {
                  return const StateCard(
                    title: 'No opportunities found',
                    subtitle:
                        'Try switching the filter to see more internships.',
                    icon: Icons.search_off_outlined,
                  );
                }

                return Column(
                  children: filteredOpportunities
                      .map(
                        (opportunity) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DashboardOpportunityCard(
                            opportunity: opportunity,
                            onTap: () =>
                                _showOpportunityDetails(context, opportunity),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const LoadingCard(height: 160),
              error: (error, stackTrace) => StateCard(
                title: 'Unable to load opportunities',
                subtitle: '$error',
                icon: Icons.explore_off_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(Opportunity opportunity) {
    return switch (_selectedFilter) {
      DashboardOpportunityFilter.all => true,
      DashboardOpportunityFilter.tech =>
        opportunity.category == OpportunityCategory.development ||
            opportunity.category == OpportunityCategory.design ||
            opportunity.category == OpportunityCategory.research,
      DashboardOpportunityFilter.entrepreneurship =>
        opportunity.category == OpportunityCategory.marketing ||
            opportunity.category == OpportunityCategory.operations ||
            opportunity.category == OpportunityCategory.community,
    };
  }

  void _showOpportunityDetails(BuildContext context, Opportunity opportunity) {
    final repository = ref.read(opportunityRepositoryProvider);
    final user = ref.read(authControllerProvider).user;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${opportunity.startupName} · ${opportunity.category.label}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    MatchPill(score: opportunity.matchScore),
                    const SizedBox(width: 8),
                    _detailChip(context, _statusLabel(opportunity.status)),
                  ],
                ),
                const SizedBox(height: 18),
                _detailSection(context, 'Description', opportunity.description),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          backgroundColor: const Color(0xFFF1F5FF),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _detailInfo(
                        context,
                        Icons.location_on_outlined,
                        opportunity.location,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _detailInfo(
                        context,
                        Icons.schedule_outlined,
                        opportunity.mode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _detailInfo(
                  context,
                  Icons.payments_outlined,
                  opportunity.compensation,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            opportunity.status == OpportunityStatus.closed ||
                                user?.role != UserRole.student
                            ? null
                            : () async {
                                if (user == null) {
                                  return;
                                }
                                try {
                                  await repository.submitApplication(
                                    opportunityId: opportunity.id,
                                    student: user,
                                  );
                                  if (context.mounted) {
                                    ref.invalidate(applicationsProvider);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Application submitted for ${opportunity.title}',
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$error')),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.send_outlined),
                        label: Text(
                          opportunity.status == OpportunityStatus.closed
                              ? 'Closed'
                              : 'Apply now',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: user?.role != UserRole.student
                          ? null
                          : () async {
                              final student = user;
                              if (student == null) {
                                return;
                              }
                              await repository.toggleBookmark(
                                userId: student.id,
                                opportunityId: opportunity.id,
                              );
                              if (context.mounted) {
                                ref.invalidate(opportunitiesProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      opportunity.bookmarked
                                          ? 'Bookmark removed'
                                          : 'Bookmarked',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        opportunity.bookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(OpportunityStatus status) {
    return switch (status) {
      OpportunityStatus.open => 'Open',
      OpportunityStatus.review => 'In review',
      OpportunityStatus.closed => 'Closed',
    };
  }

  Widget _detailSection(BuildContext context, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.45),
        ),
      ],
    );
  }

  Widget _detailInfo(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF0B5FFF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DashboardFilterChip extends StatelessWidget {
  const _DashboardFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B5FFF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF0B5FFF)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class DashboardOpportunityCard extends StatelessWidget {
  const DashboardOpportunityCard({
    required this.opportunity,
    required this.onTap,
    super.key,
  });

  final Opportunity opportunity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.work_outline, color: Color(0xFF0B5FFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${opportunity.startupName} · ${opportunity.location}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _miniChip(context, opportunity.category.label),
                        _miniChip(context, '${opportunity.matchScore}% match'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.black87),
      ),
    );
  }
}
