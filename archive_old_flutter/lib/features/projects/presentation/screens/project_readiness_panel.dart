import 'package:flutter/material.dart';

import 'project_form_support.dart';
import 'project_publish_readiness.dart';

class ProjectReadinessPanel extends StatelessWidget {
  const ProjectReadinessPanel({
    super.key,
    required this.isPublished,
    required this.issues,
  });

  final bool isPublished;
  final List<PublishReadinessIssue> issues;

  @override
  Widget build(BuildContext context) {
    final blockers = issues
        .where((issue) => issue.severity == PublishIssueSeverity.blocker)
        .toList(growable: false);
    final warnings = issues
        .where((issue) => issue.severity == PublishIssueSeverity.warning)
        .toList(growable: false);

    return ProjectFormSection(
      title: 'Publish Readiness',
      children: [
        _SummaryBanner(
          isPublished: isPublished,
          blockerCount: blockers.length,
          warningCount: warnings.length,
        ),
        const SizedBox(height: 12),
        if (blockers.isNotEmpty)
          _IssueList(title: 'Blockers', issues: blockers),
        if (blockers.isNotEmpty && warnings.isNotEmpty)
          const SizedBox(height: 12),
        if (warnings.isNotEmpty)
          _IssueList(title: 'Warnings', issues: warnings),
      ],
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.isPublished,
    required this.blockerCount,
    required this.warningCount,
  });

  final bool isPublished;
  final int blockerCount;
  final int warningCount;

  @override
  Widget build(BuildContext context) {
    final ready = blockerCount == 0;
    final color = ready ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final textColor = ready ? const Color(0xFF166534) : const Color(0xFF991B1B);
    final message = ready
        ? isPublished
              ? 'Ready to publish. $warningCount quality warning(s).'
              : 'Draft can be published when you are ready.'
        : '$blockerCount blocker(s) must be fixed before publishing.';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.title, required this.issues});

  final String title;
  final List<PublishReadinessIssue> issues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  issue.severity == PublishIssueSeverity.blocker
                      ? Icons.error_outline
                      : Icons.info_outline,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(issue.message)),
              ],
            ),
          ),
      ],
    );
  }
}
