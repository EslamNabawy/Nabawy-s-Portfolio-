import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../../projects/application/project_providers.dart';
import '../../../sections/application/section_providers.dart';
import '../../../sections/domain/entities/page_section_readiness.dart';
import '../../../settings/application/settings_providers.dart';
import 'overview_content_health.dart';

class HealthChecksScreen extends ConsumerWidget {
  const HealthChecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsProvider);
    final skillsState = ref.watch(skillsProvider);
    final experimentsState = ref.watch(experimentsProvider);
    final sectionsState = ref.watch(pageSectionsProvider);
    final configState = ref.watch(siteConfigProvider);

    if (projectsState.isLoading ||
        skillsState.isLoading ||
        experimentsState.isLoading ||
        sectionsState.isLoading ||
        configState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error =
        projectsState.error ??
        skillsState.error ??
        experimentsState.error ??
        sectionsState.error ??
        configState.error;
    if (error != null) {
      return Center(child: Text('Health check failed: $error'));
    }

    final health = OverviewContentHealth.from(
      projectsState.value ?? const [],
      skillsState.value ?? const [],
      experimentsState.value ?? const [],
    );
    final sections = sectionsState.value ?? const [];
    final sectionWarnings = [
      for (final section in sections)
        ...assessPageSectionReadiness(
          section,
        ).messages.map((message) => '${section.title}: $message'),
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Health Checks', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width < 900 ? 1 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          children: [
            AdminMetricTile(
              label: 'Content Warnings',
              value: health.warnings.length.toString(),
              tone: health.warnings.isEmpty
                  ? AdminStatusTone.success
                  : AdminStatusTone.danger,
            ),
            AdminMetricTile(
              label: 'Section Warnings',
              value: sectionWarnings.length.toString(),
              tone: sectionWarnings.isEmpty
                  ? AdminStatusTone.success
                  : AdminStatusTone.warning,
            ),
            AdminMetricTile(
              label: 'Design',
              value: configState.value?.designVariant.label ?? '-',
              tone: AdminStatusTone.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveTwoPane(
          primary: AdminPanel(
            title: 'Content Validation',
            child: ValidationList(messages: health.warnings),
          ),
          secondary: AdminPanel(
            title: 'Section Validation',
            child: ValidationList(messages: sectionWarnings),
          ),
        ),
      ],
    );
  }
}
