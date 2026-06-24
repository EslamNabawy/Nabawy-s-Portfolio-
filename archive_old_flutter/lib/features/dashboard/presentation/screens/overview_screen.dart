import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/application/project_providers.dart';
import '../../../projects/domain/entities/experiment.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/entities/skill.dart';
import '../../../sections/application/section_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../../settings/domain/entities/publish_log.dart';
import 'overview_content_health.dart';
import 'overview_panels.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsProvider);
    final skillsState = ref.watch(skillsProvider);
    final experimentsState = ref.watch(experimentsProvider);
    final sectionsState = ref.watch(pageSectionsProvider);
    final logsState = ref.watch(publishLogsProvider);

    if (projectsState.isLoading ||
        skillsState.isLoading ||
        experimentsState.isLoading ||
        sectionsState.isLoading ||
        logsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error =
        projectsState.error ??
        skillsState.error ??
        experimentsState.error ??
        sectionsState.error ??
        logsState.error;
    if (error != null) {
      return _ErrorState(message: '$error', onRetry: () => _refresh(ref));
    }

    final projects = projectsState.value ?? const <Project>[];
    final skills = skillsState.value ?? const <Skill>[];
    final experiments = experimentsState.value ?? const <Experiment>[];
    final sections = sectionsState.value ?? const [];
    final logs = logsState.value ?? const <PublishLog>[];
    final health = OverviewContentHealth.from(projects, skills, experiments);

    return RefreshIndicator(
      onRefresh: () async => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Header(onRefresh: () => _refresh(ref)),
          const SizedBox(height: 16),
          OverviewMetricGrid(
            metrics: [
              OverviewMetric('Published Projects', health.publishedProjects),
              OverviewMetric('Draft Projects', health.draftProjects),
              OverviewMetric('Lab Experiments', health.publishedExperiments),
              OverviewMetric('Skill Groups', health.publishedSkillGroups),
              OverviewMetric('Custom Sections', sections.length),
              OverviewMetric(
                'Draft Sections',
                sections.where((section) => !section.isPublished).length,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ResponsivePanels(
            health: health,
            latestLog: logs.isEmpty ? null : logs.first,
          ),
        ],
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref
      ..invalidate(projectsProvider)
      ..invalidate(skillsProvider)
      ..invalidate(experimentsProvider)
      ..invalidate(pageSectionsProvider)
      ..invalidate(publishLogsProvider);
  }
}

class _ResponsivePanels extends StatelessWidget {
  const _ResponsivePanels({required this.health, required this.latestLog});

  final OverviewContentHealth health;
  final PublishLog? latestLog;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final children = [
          OverviewReadinessPanel(health: health),
          OverviewDeploySnapshot(log: latestLog),
        ];
        if (constraints.maxWidth < 920) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [children[0], const SizedBox(height: 16), children[1]],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 16),
            Expanded(child: children[1]),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              const Text(
                'Content health, Lab readiness, and deployment state.',
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
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
