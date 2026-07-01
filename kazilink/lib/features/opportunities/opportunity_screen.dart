import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/opportunity_category.dart';
import '../../core/state/app_providers.dart';
import '../../shared/widgets/feature_cards.dart';

class OpportunityScreen extends ConsumerWidget {
  const OpportunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search startup roles, skills, or locations',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final item = index == 0 ? null : OpportunityCategory.values[index - 1];
                  final selected = item == category;
                  final label = index == 0 ? 'All' : item!.label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = item,
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemCount: OpportunityCategory.values.length + 1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: opportunitiesAsync.when(
                data: (opportunities) {
                  final filtered = opportunities.where((opportunity) {
                    final matchesQuery = query.isEmpty ||
                        opportunity.title.toLowerCase().contains(query.toLowerCase()) ||
                        opportunity.startupName.toLowerCase().contains(query.toLowerCase()) ||
                        opportunity.skills.any((skill) => skill.toLowerCase().contains(query.toLowerCase()));
                    final matchesCategory = category == null || opportunity.category == category;
                    return matchesQuery && matchesCategory;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const StateCard(
                      title: 'No roles match your search',
                      subtitle: 'Try a different keyword or clear the category filter.',
                      icon: Icons.manage_search,
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => OpportunityCard(opportunity: filtered[index]),
                  );
                },
                loading: () => const LoadingCard(height: 180),
                error: (error, stackTrace) => StateCard(
                  title: 'Search failed',
                  subtitle: '$error',
                  icon: Icons.cloud_off_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
