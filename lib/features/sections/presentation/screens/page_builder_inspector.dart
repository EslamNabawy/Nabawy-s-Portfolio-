import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../../../shared/ui/admin_shell.dart';
import '../../../deployment/domain/entities/deployment_result.dart';
import '../../domain/entities/page_section.dart';
import 'page_builder_selection.dart';
import 'page_section_inspector.dart';

class PageBuilderInspector extends StatelessWidget {
  const PageBuilderInspector({
    super.key,
    required this.selection,
    required this.section,
    required this.isSaving,
    required this.isDeploying,
    required this.onNavigate,
    required this.onCreateAtPlacement,
    required this.onSave,
    required this.onSaveAndDeploy,
    required this.onEditAdvanced,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
    this.deploymentProgress,
    this.deploymentResult,
    this.deploymentError,
  });

  final PageBuilderSelection selection;
  final PageSection? section;
  final bool isSaving;
  final bool isDeploying;
  final ValueChanged<AdminSection> onNavigate;
  final ValueChanged<PageSectionPlacement> onCreateAtPlacement;
  final Future<void> Function(PageSection section) onSave;
  final Future<void> Function(PageSection section) onSaveAndDeploy;
  final ValueChanged<PageSection> onEditAdvanced;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;
  final DeploymentProgress? deploymentProgress;
  final DeploymentResult? deploymentResult;
  final String? deploymentError;

  @override
  Widget build(BuildContext context) {
    final builtIn = selection.builtIn;
    if (builtIn != null) {
      return BuiltInSectionInspector(section: builtIn, onNavigate: onNavigate);
    }
    final placement = selection.placement;
    if (placement != null) {
      return EmptyPlacementInspector(
        placement: placement,
        onCreate: onCreateAtPlacement,
      );
    }
    return PageSectionInspector(
      section: section,
      isSaving: isSaving,
      isDeploying: isDeploying,
      onSave: onSave,
      onSaveAndDeploy: onSaveAndDeploy,
      onEditAdvanced: onEditAdvanced,
      onPreview: onPreview,
      onDuplicate: onDuplicate,
      onDelete: onDelete,
      onTogglePublished: onTogglePublished,
      deploymentProgress: deploymentProgress,
      deploymentResult: deploymentResult,
      deploymentError: deploymentError,
    );
  }
}

class BuiltInSectionInspector extends StatelessWidget {
  const BuiltInSectionInspector({
    super.key,
    required this.section,
    required this.onNavigate,
  });

  final BuiltInPageSection section;
  final ValueChanged<AdminSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      title: section.label,
      subtitle: 'Built-in portfolio section',
      actions: const [
        AdminStatusChip(label: 'Template-owned', tone: AdminStatusTone.info),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(section.description),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => onNavigate(_target(section)),
            icon: Icon(_icon(section)),
            label: Text('Open ${_target(section).label}'),
          ),
        ],
      ),
    );
  }

  AdminSection _target(BuiltInPageSection section) {
    return switch (section) {
      BuiltInPageSection.hero ||
      BuiltInPageSection.contact => AdminSection.config,
      BuiltInPageSection.projects => AdminSection.projects,
      BuiltInPageSection.lab => AdminSection.experiments,
      BuiltInPageSection.skills => AdminSection.skills,
    };
  }

  IconData _icon(BuiltInPageSection section) {
    return switch (section) {
      BuiltInPageSection.hero ||
      BuiltInPageSection.contact => Icons.tune_outlined,
      BuiltInPageSection.projects => Icons.view_list_outlined,
      BuiltInPageSection.lab => Icons.science_outlined,
      BuiltInPageSection.skills => Icons.bolt_outlined,
    };
  }
}

class EmptyPlacementInspector extends StatelessWidget {
  const EmptyPlacementInspector({
    super.key,
    required this.placement,
    required this.onCreate,
  });

  final PageSectionPlacement placement;
  final ValueChanged<PageSectionPlacement> onCreate;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      title: placement.label,
      subtitle: 'Empty insertion point',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add a template-backed section at this point in the page.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => onCreate(placement),
            icon: const Icon(Icons.add),
            label: const Text('Add Section Here'),
          ),
        ],
      ),
    );
  }
}
