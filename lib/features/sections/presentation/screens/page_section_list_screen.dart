import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/ui/admin_shell.dart';
import '../../../deployment/presentation/controllers/cms_deployment_state.dart';
import '../../application/section_providers.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_template.dart';
import 'page_builder_inspector.dart';
import 'page_builder_selection.dart';
import 'page_section_canvas_view.dart';
import 'page_section_form_screen.dart';
import 'page_section_list_header.dart';
import 'page_section_list_mode.dart';
import 'page_section_list_support.dart';
import 'page_section_preview_dialog.dart';
import 'page_section_table_view.dart';
import 'page_section_template_picker.dart';

class PageSectionListScreen extends ConsumerStatefulWidget {
  const PageSectionListScreen({super.key, this.onNavigate});

  final ValueChanged<AdminSection>? onNavigate;

  @override
  ConsumerState<PageSectionListScreen> createState() =>
      _PageSectionListScreenState();
}

class _PageSectionListScreenState extends ConsumerState<PageSectionListScreen>
    with CmsDeploymentState<PageSectionListScreen> {
  SectionListViewMode _view = SectionListViewMode.canvas;
  bool _isSaving = false;
  PageBuilderSelection _selection = const PageBuilderSelection.none();

  @override
  Widget build(BuildContext context) {
    final sectionsState = ref.watch(pageSectionsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageSectionListHeader(
            view: _view,
            isSaving: _isSaving,
            onViewChanged: (view) => setState(() => _view = view),
            onRefresh: () => ref.invalidate(pageSectionsProvider),
            onCreate: _openTemplate,
            onTemplate: () => _openTemplate(),
            onDeploy: () => runCmsDeployment(
              message: 'Deployment requested from Page Builder.',
            ),
            onPublishAll: () => _bulkPublish(true),
            onUnpublishAll: () => _bulkPublish(false),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sectionsState.when(
              data: (sections) => PageSectionEditorSurface(
                preview: _view == SectionListViewMode.canvas
                    ? PageSectionCanvasView(
                        sections: sections,
                        selection: _selection,
                        onSelectionChanged: (selection) =>
                            setState(() => _selection = selection),
                        onAddAtPlacement: _openTemplateAt,
                        onEdit: _openForm,
                        onPreview: _preview,
                        onDuplicate: _duplicate,
                        onDelete: _deleteSection,
                        onTogglePublished: _togglePublished,
                        onReorder: (placement, oldIndex, newIndex) =>
                            _reorder(sections, placement, oldIndex, newIndex),
                      )
                    : PageSectionTableView(
                        sections: sections,
                        onEdit: _openForm,
                        onPreview: _preview,
                        onDuplicate: _duplicate,
                        onDelete: _deleteSection,
                        onTogglePublished: _togglePublished,
                      ),
                inspector: PageBuilderInspector(
                  selection: _selection,
                  section: selectedPageSection(sections, _selection.sectionId),
                  isSaving: _isSaving,
                  isDeploying: isDeploying,
                  deploymentProgress: deploymentProgress,
                  deploymentResult: deploymentResult,
                  deploymentError: deploymentError,
                  onNavigate: _navigate,
                  onCreateAtPlacement: _openTemplateAt,
                  onSave: _saveSection,
                  onSaveAndDeploy: _saveAndDeploySection,
                  onEditAdvanced: _openForm,
                  onPreview: _preview,
                  onDuplicate: _duplicate,
                  onDelete: _deleteSection,
                  onTogglePublished: _togglePublished,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => PageSectionErrorState(
                message: 'Failed to load sections: $error',
                onRetry: () => ref.invalidate(pageSectionsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm([PageSection? section]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => section?.id == null
            ? PageSectionFormScreen(initialSection: section)
            : PageSectionFormScreen(section: section),
      ),
    );
    if (changed == true) {
      ref.invalidate(pageSectionsProvider);
    }
  }

  Future<void> _openTemplate() async {
    final template = await showPageSectionTemplatePicker(context);
    if (template != null && mounted) {
      final sections = ref.read(pageSectionsProvider).value ?? const [];
      final draft = sectionFromTemplate(template);
      await _openForm(
        draft.copyWith(
          displayOrder: nextPageSectionDisplayOrder(sections, draft.placement),
        ),
      );
    }
  }

  Future<void> _openTemplateAt(PageSectionPlacement placement) async {
    final template = await showPageSectionTemplatePicker(
      context,
      placement: placement,
    );
    if (template != null && mounted) {
      final sections = ref.read(pageSectionsProvider).value ?? const [];
      await _openForm(
        sectionFromTemplate(
          template,
          placement: placement,
          displayOrder: nextPageSectionDisplayOrder(sections, placement),
        ),
      );
    }
  }

  void _preview(PageSection section) {
    showPageSectionPreview(context, section);
  }

  void _duplicate(PageSection section) {
    _openForm(duplicateSection(section));
  }

  Future<void> _togglePublished(PageSection section) async {
    await _saveMany([section.copyWith(isPublished: !section.isPublished)]);
  }

  Future<void> _saveSection(PageSection section) async {
    final sections = ref.read(pageSectionsProvider).value ?? const [];
    final saved = await _saveMany([
      normalizePageSectionOrder(sections, section),
    ]);
    if (saved) {
      setState(
        () => _selection = PageBuilderSelection.customSection(
          pageSectionIdentity(section),
        ),
      );
    }
  }

  Future<void> _saveAndDeploySection(PageSection section) async {
    final sections = ref.read(pageSectionsProvider).value ?? const [];
    final saved = await _saveMany([
      normalizePageSectionOrder(sections, section),
    ]);
    if (saved) {
      await runCmsDeployment(
        message:
            'Deployment requested after saving page section "${section.title}".',
      );
    }
  }

  Future<void> _bulkPublish(bool isPublished) async {
    final sections = ref.read(pageSectionsProvider).value ?? const [];
    await _saveMany(
      sections
          .where((section) => section.isPublished != isPublished)
          .map((section) => section.copyWith(isPublished: isPublished))
          .toList(growable: false),
    );
  }

  Future<void> _reorder(
    List<PageSection> allSections,
    PageSectionPlacement placement,
    int oldIndex,
    int newIndex,
  ) async {
    final lane = allSections
        .where((section) => section.placement == placement)
        .toList(growable: true);
    final moved = lane.removeAt(oldIndex);
    lane.insert(newIndex, moved);
    final updated = <PageSection>[];
    for (var index = 0; index < lane.length; index++) {
      final order = (index + 1) * 10;
      if (lane[index].displayOrder != order) {
        updated.add(lane[index].copyWith(displayOrder: order));
      }
    }
    await _saveMany(updated);
  }

  Future<bool> _saveMany(List<PageSection> sections) async {
    if (sections.isEmpty) {
      return true;
    }
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(pageSectionRepositoryProvider);
      for (final section in sections) {
        await repository.updateSection(section);
      }
      ref.invalidate(pageSectionsProvider);
      _showMessage(
        'Sections saved. Deploy when ready to update the public site.',
      );
      return true;
    } on AppException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Section update failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
    return false;
  }

  Future<void> _deleteSection(PageSection section) async {
    final confirmed = await confirmDeletePageSection(context, section);
    if (!confirmed || section.id == null) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(pageSectionRepositoryProvider).deleteSection(section.id!);
      ref.invalidate(pageSectionsProvider);
      if (_selection.isCustom(section)) {
        _selection = const PageBuilderSelection.none();
      }
    } on AppException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Delete failed. Retry after checking connection.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _navigate(AdminSection section) {
    final navigate = widget.onNavigate;
    if (navigate == null) {
      _showMessage('Navigation is unavailable in this context.');
      return;
    }
    navigate(section);
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
