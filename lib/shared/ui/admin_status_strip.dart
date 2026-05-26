import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/screens/overview_content_health.dart';
import '../../features/projects/application/project_providers.dart';
import '../../features/sections/application/section_providers.dart';
import '../../features/settings/application/settings_providers.dart';
import '../../features/settings/domain/entities/publish_log.dart';
import 'admin_components.dart';

class AdminStatusStrip extends ConsumerWidget {
  const AdminStatusStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(siteConfigProvider).value;
    final sections = ref.watch(pageSectionsProvider).value ?? const [];
    final logs = ref.watch(publishLogsProvider).value ?? const [];
    final projects = ref.watch(projectsProvider).value ?? const [];
    final skills = ref.watch(skillsProvider).value ?? const [];
    final experiments = ref.watch(experimentsProvider).value ?? const [];
    final health = OverviewContentHealth.from(projects, skills, experiments);
    final draftSections = sections
        .where((section) => !section.isPublished)
        .length;
    final latestSuccess = _latestSuccess(logs);
    final latestChange = _latestDate([
      config?.updatedAt,
      ...sections
          .where((section) => section.isPublished)
          .map((section) => section.updatedAt),
    ]);
    final needsDeploy =
        latestChange != null &&
        (latestSuccess?.createdAt == null ||
            latestChange.isAfter(latestSuccess!.createdAt!));
    final latestDeploy = needsDeploy
        ? 'NEEDS DEPLOY'
        : logs.isEmpty
        ? 'NO DEPLOY'
        : logs.first.status.name.toUpperCase();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFC7D2CC))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _StripItem(
            label: 'Design',
            value: config?.designVariant.label ?? 'Loading',
            tone: AdminStatusTone.info,
          ),
          _StripItem(
            label: 'Deploy',
            value: latestDeploy,
            tone: latestDeploy == 'SUCCESS'
                ? AdminStatusTone.success
                : AdminStatusTone.warning,
          ),
          _StripItem(
            label: 'Draft Sections',
            value: draftSections.toString(),
            tone: draftSections == 0
                ? AdminStatusTone.success
                : AdminStatusTone.warning,
          ),
          _StripItem(
            label: 'Warnings',
            value: health.warnings.length.toString(),
            tone: health.warnings.isEmpty
                ? AdminStatusTone.success
                : AdminStatusTone.danger,
          ),
        ],
      ),
    );
  }
}

PublishLog? _latestSuccess(List<PublishLog> logs) {
  for (final log in logs) {
    if (log.status == PublishStatus.success) {
      return log;
    }
  }
  return null;
}

DateTime? _latestDate(Iterable<DateTime?> values) {
  DateTime? latest;
  for (final value in values.whereType<DateTime>()) {
    if (latest == null || value.isAfter(latest)) {
      latest = value;
    }
  }
  return latest;
}

class _StripItem extends StatelessWidget {
  const _StripItem({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final AdminStatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            AdminStatusChip(label: value, tone: tone),
          ],
        ),
      ),
    );
  }
}
