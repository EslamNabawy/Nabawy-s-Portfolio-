import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/skill.dart';
import 'skill_form_screen.dart';

class SkillListScreen extends ConsumerWidget {
  const SkillListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsState = ref.watch(skillsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onRefresh: () => ref.invalidate(skillsProvider),
            onCreate: () => _openForm(context, ref),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: skillsState.when(
              data: (skills) => _SkillTable(
                skills: skills,
                onEdit: (skill) => _openForm(context, ref, skill),
                onDelete: (skill) => _deleteSkill(context, ref, skill),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: 'Failed to load skills: $error',
                onRetry: () => ref.invalidate(skillsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, [
    Skill? skill,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SkillFormScreen(skill: skill)),
    );
    if (changed == true) {
      ref.invalidate(skillsProvider);
    }
  }

  Future<void> _deleteSkill(
    BuildContext context,
    WidgetRef ref,
    Skill skill,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete skill group'),
        content: Text('Delete "${skill.category}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || skill.id == null) {
      return;
    }

    try {
      await ref.read(skillRepositoryProvider).deleteSkill(skill.id!);
      ref.invalidate(skillsProvider);
    } on AppException catch (error) {
      if (context.mounted) {
        _showMessage(context, error.message);
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          'Delete failed. Retry after checking connection.',
        );
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh, required this.onCreate});

  final VoidCallback onRefresh;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Skills',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('New Skill Group'),
        ),
      ],
    );
  }
}

class _SkillTable extends StatelessWidget {
  const _SkillTable({
    required this.skills,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Skill> skills;
  final ValueChanged<Skill> onEdit;
  final ValueChanged<Skill> onDelete;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const Center(child: Text('No skill groups yet.'));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Items')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final skill in skills)
                DataRow(
                  cells: [
                    DataCell(Text(skill.displayOrder.toString())),
                    DataCell(SizedBox(width: 180, child: Text(skill.category))),
                    DataCell(_StatusChip(isPublished: skill.isPublished)),
                    DataCell(
                      SizedBox(width: 360, child: Text(skill.items.join(', '))),
                    ),
                    DataCell(Text(_formatDate(skill.updatedAt))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => onEdit(skill),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: skill.id == null
                                ? null
                                : () => onDelete(skill),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return value.toLocal().toString().split('.').first;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isPublished});

  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    final background = isPublished
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFFF7ED);
    final foreground = isPublished
        ? const Color(0xFF166534)
        : const Color(0xFF9A3412);
    return Chip(
      label: Text(isPublished ? 'Published' : 'Draft'),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      side: BorderSide.none,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
