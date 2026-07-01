import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/application_record.dart';
import '../../core/models/opportunity.dart';
import '../../core/models/opportunity_category.dart';
import '../../core/models/opportunity_status.dart';
import '../../core/models/startup_profile.dart';
import '../../core/models/startup_verification.dart';
import '../../core/state/app_providers.dart';

class OpportunityCard extends ConsumerWidget {
  const OpportunityCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(opportunityRepositoryProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${opportunity.startupName} · ${opportunity.category.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              MatchPill(score: opportunity.matchScore),
            ],
          ),
          const SizedBox(height: 14),
          Text(opportunity.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opportunity.skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    backgroundColor: const Color(0xFFF1F5FF),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: InfoPill(icon: Icons.location_on_outlined, text: opportunity.location)),
              const SizedBox(width: 8),
              Expanded(child: InfoPill(icon: Icons.schedule_outlined, text: opportunity.mode)),
            ],
          ),
          const SizedBox(height: 8),
          InfoPill(icon: Icons.payments_outlined, text: opportunity.compensation),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () async {
                  await repository.toggleBookmark(opportunity.id);
                  if (context.mounted) {
                    ref.invalidate(opportunitiesProvider);
                  }
                },
                icon: Icon(opportunity.bookmarked ? Icons.bookmark : Icons.bookmark_border),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: opportunity.status == OpportunityStatus.closed
                      ? null
                      : () async {
                          await repository.submitInterest(opportunity.id);
                          if (context.mounted) {
                            ref.invalidate(applicationsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Interest submitted for ${opportunity.title}')),
                            );
                          }
                        },
                  child: Text(opportunity.status == OpportunityStatus.closed ? 'Closed' : 'Apply now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MatchPill extends StatelessWidget {
  const MatchPill({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$score% match',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF0B5FFF), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.title, required this.subtitle, required this.accent, required this.onAction});

  final String title;
  final String subtitle;
  final String accent;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B5FFF), Color(0xFF17326D)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0B5FFF).withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(accent, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.45)),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: onAction,
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF17326D)),
            child: const Text('Refresh discovery'),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0B5FFF)),
          const SizedBox(height: 14),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }
}

class StartupCard extends StatelessWidget {
  const StartupCard({super.key, required this.startup});

  final StartupProfile startup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: startup.verified ? const Color(0xFFE8F0FF) : const Color(0xFFF4F4F4),
            child: Icon(startup.verified ? Icons.verified : Icons.business_outlined, color: startup.verified ? const Color(0xFF0B5FFF) : Colors.black54),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(startup.name, style: Theme.of(context).textTheme.titleMedium)),
                    VerificationBadge(status: startup.verificationStatus),
                  ],
                ),
                const SizedBox(height: 4),
                Text(startup.tagline, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                const SizedBox(height: 10),
                Text('${startup.focusArea} · ${startup.memberCount} members · ${startup.location}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application});

  final ApplicationRecord application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(application.opportunityTitle, style: Theme.of(context).textTheme.titleMedium)),
              ApplicationStatusBadge(status: application.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(application.startupName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          const SizedBox(height: 10),
          Text('Applied ${application.appliedAt}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status});

  final StartupVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (status) {
      StartupVerificationStatus.verified => const Color(0xFFE8F6EC),
      StartupVerificationStatus.underReview => const Color(0xFFFFF4D9),
      StartupVerificationStatus.pending => const Color(0xFFF1F5FF),
      StartupVerificationStatus.rejected => const Color(0xFFFCE8E8),
    };
    final foregroundColor = switch (status) {
      StartupVerificationStatus.verified => const Color(0xFF127A3D),
      StartupVerificationStatus.underReview => const Color(0xFF8A5A00),
      StartupVerificationStatus.pending => const Color(0xFF0B5FFF),
      StartupVerificationStatus.rejected => const Color(0xFFB42318),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foregroundColor)),
    );
  }
}

class ApplicationStatusBadge extends StatelessWidget {
  const ApplicationStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final backgroundColor = switch (normalized) {
      'submitted' => const Color(0xFFF1F5FF),
      'under review' => const Color(0xFFFFF4D9),
      'shortlisted' => const Color(0xFFE8F6EC),
      'accepted' => const Color(0xFFE8F6EC),
      'rejected' => const Color(0xFFFCE8E8),
      _ => const Color(0xFFF1F5FF),
    };
    final foregroundColor = switch (normalized) {
      'submitted' => const Color(0xFF0B5FFF),
      'under review' => const Color(0xFF8A5A00),
      'shortlisted' => const Color(0xFF127A3D),
      'accepted' => const Color(0xFF127A3D),
      'rejected' => const Color(0xFFB42318),
      _ => const Color(0xFF0B5FFF),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foregroundColor)),
    );
  }
}

class WorkflowNote extends StatelessWidget {
  const WorkflowNote({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.45)),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.userName, required this.userEmail, required this.roleLabel});

  final String userName;
  final String userEmail;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF17326D), Color(0xFF0B5FFF)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.school, color: Color(0xFF0B5FFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(userEmail, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 4),
                Text(roleLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

class StateCard extends StatelessWidget {
  const StateCard({super.key, required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF0B5FFF)),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}
