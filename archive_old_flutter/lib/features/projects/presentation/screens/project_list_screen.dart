import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/project.dart';
import 'project_form_screen.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onRefresh: () => ref.invalidate(projectsProvider),
            onCreate: () => _openForm(context, ref),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: projectsState.when(
              data: (projects) => _ProjectTable(
                projects: projects,
                onEdit: (project) => _openForm(context, ref, project),
                onDelete: (project) => _deleteProject(context, ref, project),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: 'Failed to load projects: $error',
                onRetry: () => ref.invalidate(projectsProvider),
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
    Project? project,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProjectFormScreen(project: project)),
    );
    if (changed == true) {
      ref.invalidate(projectsProvider);
    }
  }

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project'),
        content: Text('Delete "${project.title}"? This cannot be undone.'),
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
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(projectRepositoryProvider).deleteProject(project.id!);
      ref.invalidate(projectsProvider);
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, error.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Delete failed. Retry after checking connection.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
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
            'Projects',
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
          label: const Text('New Project'),
        ),
      ],
    );
  }
}

class _ProjectTable extends StatelessWidget {
  const _ProjectTable({
    required this.projects,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Project> projects;
  final ValueChanged<Project> onEdit;
  final ValueChanged<Project> onDelete;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Center(child: Text('No projects yet.'));
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
              DataColumn(label: Text('Slug')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Featured')),
              DataColumn(label: Text('Stack')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final project in projects)
                DataRow(
                  cells: [
                    DataCell(Text(project.displayOrder.toString())),
                    DataCell(SizedBox(width: 220, child: Text(project.title))),
                    DataCell(Text(project.slug)),
                    DataCell(_StatusChip(isPublished: project.isPublished)),
                    DataCell(_FeaturedChip(featured: project.featured)),
                    DataCell(
                      SizedBox(
                        width: 260,
                        child: Text(project.techStack.join(', ')),
                      ),
                    ),
                    DataCell(Text(_formatDate(project.updatedAt))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => onEdit(project),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: project.id == null
                                ? null
                                : () => onDelete(project),
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

class _FeaturedChip extends StatelessWidget {
  const _FeaturedChip({required this.featured});

  final bool featured;

  @override
  Widget build(BuildContext context) {
    if (!featured) {
      return const Text('-');
    }
    return const Chip(
      avatar: Icon(Icons.star, size: 16, color: Color(0xFF854D0E)),
      label: Text('Featured'),
      backgroundColor: Color(0xFFFEF3C7),
      labelStyle: TextStyle(
        color: Color(0xFF854D0E),
        fontWeight: FontWeight.w700,
      ),
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
