import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/section_providers.dart';
import '../../domain/entities/page_section.dart';
import 'page_section_form_screen.dart';

class PageSectionListScreen extends ConsumerWidget {
  const PageSectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsState = ref.watch(pageSectionsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onRefresh: () => ref.invalidate(pageSectionsProvider),
            onCreate: () => _openForm(context, ref),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sectionsState.when(
              data: (sections) => _SectionTable(
                sections: sections,
                onEdit: (section) => _openForm(context, ref, section),
                onDelete: (section) => _deleteSection(context, ref, section),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: 'Failed to load sections: $error',
                onRetry: () => ref.invalidate(pageSectionsProvider),
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
    PageSection? section,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PageSectionFormScreen(section: section),
      ),
    );
    if (changed == true) {
      ref.invalidate(pageSectionsProvider);
    }
  }

  Future<void> _deleteSection(
    BuildContext context,
    WidgetRef ref,
    PageSection section,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete section'),
        content: Text('Delete "${section.title}"? This cannot be undone.'),
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
    if (confirmed != true || section.id == null) {
      return;
    }
    try {
      await ref.read(pageSectionRepositoryProvider).deleteSection(section.id!);
      ref.invalidate(pageSectionsProvider);
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
            'Page Sections',
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
          label: const Text('New Section'),
        ),
      ],
    );
  }
}

class _SectionTable extends StatelessWidget {
  const _SectionTable({
    required this.sections,
    required this.onEdit,
    required this.onDelete,
  });

  final List<PageSection> sections;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onDelete;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('No custom page sections yet.'));
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
              DataColumn(label: Text('Placement')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Tone')),
              DataColumn(label: Text('Layout')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final section in sections)
                DataRow(
                  cells: [
                    DataCell(Text(section.displayOrder.toString())),
                    DataCell(SizedBox(width: 220, child: Text(section.title))),
                    DataCell(Text(section.placement.label)),
                    DataCell(Text(section.sectionType.label)),
                    DataCell(Text(section.tone.label)),
                    DataCell(Text(section.layout.label)),
                    DataCell(_StatusChip(isPublished: section.isPublished)),
                    DataCell(Text(_formatDate(section.updatedAt))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => onEdit(section),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: section.id == null
                                ? null
                                : () => onDelete(section),
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
