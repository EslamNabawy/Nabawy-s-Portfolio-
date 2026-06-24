import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/experiment.dart';
import 'experiment_form_screen.dart';

class ExperimentListScreen extends ConsumerWidget {
  const ExperimentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experimentsState = ref.watch(experimentsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onRefresh: () => ref.invalidate(experimentsProvider),
            onCreate: () => _openForm(context, ref),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: experimentsState.when(
              data: (experiments) => _ExperimentTable(
                experiments: experiments,
                onEdit: (experiment) => _openForm(context, ref, experiment),
                onDelete: (experiment) =>
                    _deleteExperiment(context, ref, experiment),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: 'Failed to load experiments: $error',
                onRetry: () => ref.invalidate(experimentsProvider),
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
    Experiment? experiment,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExperimentFormScreen(experiment: experiment),
      ),
    );
    if (changed == true) {
      ref.invalidate(experimentsProvider);
    }
  }

  Future<void> _deleteExperiment(
    BuildContext context,
    WidgetRef ref,
    Experiment experiment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete experiment'),
        content: Text('Delete "${experiment.title}"? This cannot be undone.'),
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
    if (confirmed != true || experiment.id == null) {
      return;
    }
    try {
      await ref
          .read(experimentRepositoryProvider)
          .deleteExperiment(experiment.id!);
      ref.invalidate(experimentsProvider);
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
            'Experiments',
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
          label: const Text('New Experiment'),
        ),
      ],
    );
  }
}

class _ExperimentTable extends StatelessWidget {
  const _ExperimentTable({
    required this.experiments,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Experiment> experiments;
  final ValueChanged<Experiment> onEdit;
  final ValueChanged<Experiment> onDelete;

  @override
  Widget build(BuildContext context) {
    if (experiments.isEmpty) {
      return const Center(child: Text('No lab experiments yet.'));
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order')),
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Published')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final experiment in experiments)
                DataRow(
                  cells: [
                    DataCell(Text(experiment.displayOrder.toString())),
                    DataCell(
                      SizedBox(width: 220, child: Text(experiment.title)),
                    ),
                    DataCell(Text(experiment.category)),
                    DataCell(Text(experiment.status.name)),
                    DataCell(_StatusChip(isPublished: experiment.isPublished)),
                    DataCell(Text(_formatDate(experiment.updatedAt))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => onEdit(experiment),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: experiment.id == null
                                ? null
                                : () => onDelete(experiment),
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
