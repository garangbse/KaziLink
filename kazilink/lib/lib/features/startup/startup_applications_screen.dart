import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/application_record.dart';
import '../../core/state/app_providers.dart';
import '../../shared/widgets/feature_cards.dart';

class StartupApplicationsScreen extends ConsumerWidget {
  const StartupApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsProvider);
    final selectedStatus = ref.watch(selectedApplicationStatusFilterProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student applicants',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Review students who applied and accept or reject each application.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final options = <String?>[
                    null,
                    'Submitted',
                    'Under review',
                    'Accepted',
                    'Rejected',
                  ];
                  final item = options[index];
                  final isSelected = item == selectedStatus;
                  return ChoiceChip(
                    label: Text(item ?? 'All'),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref
                                .read(
                                  selectedApplicationStatusFilterProvider
                                      .notifier,
                                )
                                .state =
                            item,
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemCount: 5,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: applicationsAsync.when(
                data: (applications) {
                  final filteredApplications = applications.where((
                    application,
                  ) {
                    if (selectedStatus == null) {
                      return true;
                    }
                    return application.status.toLowerCase() ==
                        selectedStatus.toLowerCase();
                  }).toList();

                  if (filteredApplications.isEmpty) {
                    return const StateCard(
                      title: 'No applicants found',
                      subtitle: 'Applications from students will appear here.',
                      icon: Icons.fact_check_outlined,
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredApplications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => StartupApplicationCard(
                      application: filteredApplications[index],
                    ),
                  );
                },
                loading: () => const LoadingCard(height: 180),
                error: (error, stackTrace) => StateCard(
                  title: 'Unable to load applicants',
                  subtitle: '$error',
                  icon: Icons.assignment_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StartupApplicationCard extends ConsumerWidget {
  const StartupApplicationCard({super.key, required this.application});

  final ApplicationRecord application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canDecide =
        application.status != 'Accepted' && application.status != 'Rejected';

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
              Expanded(
                child: Text(
                  application.studentName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ApplicationStatusBadge(status: application.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            application.studentEmail,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Text(
            application.opportunityTitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (canDecide) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _updateStatus(context, ref, 'Rejected'),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _updateStatus(context, ref, 'Accepted'),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    await ref
        .read(opportunityRepositoryProvider)
        .updateApplicationStatus(applicationId: application.id, status: status);
    ref.invalidate(applicationsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Application marked $status')));
    }
  }
}
