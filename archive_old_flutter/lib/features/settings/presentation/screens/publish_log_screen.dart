import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings_providers.dart';
import '../../domain/entities/publish_log.dart';

class PublishLogScreen extends ConsumerWidget {
  const PublishLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsState = ref.watch(publishLogsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Publish Log',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => ref.invalidate(publishLogsProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logsState.when(
              data: (logs) => _PublishLogTable(logs: logs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: 'Failed to load publish log: $error',
                onRetry: () => ref.invalidate(publishLogsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishLogTable extends StatelessWidget {
  const _PublishLogTable({required this.logs});

  final List<PublishLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Text('No deploy activity has been logged yet.'),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Message')),
              DataColumn(label: Text('Workflow Run')),
              DataColumn(label: Text('Created')),
            ],
            rows: [
              for (final log in logs)
                DataRow(
                  cells: [
                    DataCell(_StatusChip(status: log.status)),
                    DataCell(
                      SizedBox(width: 320, child: Text(log.message ?? '-')),
                    ),
                    DataCell(
                      SizedBox(
                        width: 320,
                        child: SelectableText(log.workflowRunUrl ?? '-'),
                      ),
                    ),
                    DataCell(Text(_formatDate(log.createdAt))),
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
  const _StatusChip({required this.status});

  final PublishStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (status) {
      PublishStatus.pending => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
        'Pending',
      ),
      PublishStatus.success => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
        'Success',
      ),
      PublishStatus.failed => (
        const Color(0xFFFEE2E2),
        const Color(0xFF991B1B),
        'Failed',
      ),
    };
    return Chip(
      label: Text(label),
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
