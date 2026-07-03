import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/app_providers.dart';
import '../../shared/widgets/feature_cards.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

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
              'Your applications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Track interest submissions and status changes in one place.',
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
                    'Shortlisted',
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
                itemCount: 6,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: applicationsAsync.when(
                data: (applications) => ListView.separated(
                  itemCount: applications.where((application) {
                    if (selectedStatus == null) {
                      return true;
                    }
                    return application.status.toLowerCase() ==
                        selectedStatus.toLowerCase();
                  }).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final filteredApplications = applications.where((
                      application,
                    ) {
                      if (selectedStatus == null) {
                        return true;
                      }
                      return application.status.toLowerCase() ==
                          selectedStatus.toLowerCase();
                    }).toList();
                    final application = filteredApplications[index];
                    return ApplicationCard(application: application);
                  },
                ),
                loading: () => const LoadingCard(height: 180),
                error: (error, stackTrace) => StateCard(
                  title: 'Unable to load applications',
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
