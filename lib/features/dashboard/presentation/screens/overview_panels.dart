import 'package:flutter/material.dart';

import '../../../settings/domain/entities/publish_log.dart';
import 'overview_content_health.dart';

final class OverviewMetric {
  const OverviewMetric(this.label, this.value);

  final String label;
  final int value;
}

class OverviewMetricGrid extends StatelessWidget {
  const OverviewMetricGrid({super.key, required this.metrics});

  final List<OverviewMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 116,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                Text(
                  metric.value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OverviewReadinessPanel extends StatelessWidget {
  const OverviewReadinessPanel({super.key, required this.health});

  final OverviewContentHealth health;

  @override
  Widget build(BuildContext context) {
    final warnings = health.warnings.take(8).toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              icon: Icons.health_and_safety_outlined,
              title: 'Publish Readiness',
              value: '${health.warnings.length} warnings',
            ),
            const SizedBox(height: 16),
            if (warnings.isEmpty)
              const Text('No content warnings detected for published items.')
            else
              for (final warning in warnings) _WarningRow(warning: warning),
            if (health.draftExperiments > 0) ...[
              const Divider(height: 28),
              Text('${health.draftExperiments} Lab drafts are waiting.'),
            ],
          ],
        ),
      ),
    );
  }
}

class OverviewDeploySnapshot extends StatelessWidget {
  const OverviewDeploySnapshot({super.key, required this.log});

  final PublishLog? log;

  @override
  Widget build(BuildContext context) {
    final status = log?.status.name ?? 'none';
    final createdAt = log?.createdAt?.toLocal().toString().split('.').first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              icon: Icons.rocket_launch_outlined,
              title: 'Latest Deployment',
              value: status.toUpperCase(),
            ),
            const SizedBox(height: 16),
            Text(log?.message ?? 'No deployment has been logged yet.'),
            const SizedBox(height: 12),
            Text('Timestamp: ${createdAt ?? '-'}'),
            if (log?.workflowRunUrl != null) ...[
              const SizedBox(height: 12),
              SelectableText(log!.workflowRunUrl!),
            ],
          ],
        ),
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.warning});

  final String warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(warning)),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
