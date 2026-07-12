import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/opportunity_category.dart';
import '../../core/state/app_providers.dart';
import '../../shared/widgets/feature_cards.dart';

class StartupOpportunitiesScreen extends ConsumerWidget {
  const StartupOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(startupOpportunitiesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Startup roles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showCreateOpportunitySheet(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Create opportunities and track the roles your startup has published.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: opportunitiesAsync.when(
                data: (opportunities) {
                  if (opportunities.isEmpty) {
                    return const StateCard(
                      title: 'No roles created yet',
                      subtitle:
                          'Create your first opportunity so students can apply.',
                      icon: Icons.add_business_outlined,
                    );
                  }

                  return ListView.separated(
                    itemCount: opportunities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => OpportunityCard(
                      opportunity: opportunities[index],
                      showStudentActions: false,
                    ),
                  );
                },
                loading: () => const LoadingCard(height: 180),
                error: (error, stackTrace) => StateCard(
                  title: 'Unable to load roles',
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

  void _showCreateOpportunitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _CreateOpportunityForm(),
    );
  }
}

class _CreateOpportunityForm extends ConsumerStatefulWidget {
  const _CreateOpportunityForm();

  @override
  ConsumerState<_CreateOpportunityForm> createState() =>
      _CreateOpportunityFormState();
}

class _CreateOpportunityFormState
    extends ConsumerState<_CreateOpportunityForm> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController(text: 'Hybrid');
  final _modeController = TextEditingController(text: 'Part-time');
  final _compensationController = TextEditingController(
    text: 'Mentorship + stipend',
  );
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  OpportunityCategory _category = OpportunityCategory.development;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _modeController.dispose();
    _compensationController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create opportunity',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Role title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<OpportunityCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: OpportunityCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(
                () => _category = value ?? OpportunityCategory.development,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modeController,
              decoration: const InputDecoration(
                labelText: 'Mode or time commitment',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _compensationController,
              decoration: const InputDecoration(labelText: 'Compensation'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills, separated by commas',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Publish opportunity'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      return;
    }

    final skills = _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    setState(() => _isSaving = true);
    try {
      await ref
          .read(opportunityRepositoryProvider)
          .createOpportunity(
            startupUser: user,
            title: _titleController.text.trim(),
            category: _category,
            location: _locationController.text.trim(),
            mode: _modeController.text.trim(),
            compensation: _compensationController.text.trim(),
            description: _descriptionController.text.trim(),
            skills: skills,
          );
      ref.invalidate(startupOpportunitiesProvider);
      ref.invalidate(opportunitiesProvider);
      ref.invalidate(startupsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opportunity published')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
