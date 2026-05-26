import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/section_providers.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_template.dart';
import 'page_section_canvas_view.dart';
import 'page_section_form_screen.dart';
import 'page_section_inspector.dart';
import 'page_section_list_header.dart';
import 'page_section_list_mode.dart';
import 'page_section_list_support.dart';
import 'page_section_preview_dialog.dart';
import 'page_section_table_view.dart';
import 'page_section_template_picker.dart';

class PageSectionListScreen extends ConsumerStatefulWidget {
  const PageSectionListScreen({super.key});

  @override
  ConsumerState<PageSectionListScreen> createState() =>
      _PageSectionListScreenState();
}

class _PageSectionListScreenState extends ConsumerState<PageSectionListScreen> {
  SectionListViewMode _view = SectionListViewMode.canvas;
  bool _isSaving = false;
  String? _selectedSectionId;

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
            onCreate: () => _openForm(),
            onTemplate: () => _openTemplate(),
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
                        selectedSectionId: _selectedSectionId,
                        onSelect: _selectSection,
                        onAddAtPlacement: _openAddAt,
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
                inspector: PageSectionInspector(
                  section: selectedPageSection(sections, _selectedSectionId),
                  isSaving: _isSaving,
                  onSave: _saveSection,
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

  Future<void> _openAddAt(PageSectionPlacement placement) async {
    final sections = ref.read(pageSectionsProvider).value ?? const [];
    await _openForm(
      PageSection(
        sectionKey: '',
        title: '',
        placement: placement,
        displayOrder: nextPageSectionDisplayOrder(sections, placement),
      ),
    );
  }

  Future<void> _openTemplate() async {
    final template = await showPageSectionTemplatePicker(context);
    if (template != null && mounted) {
      await _openForm(sectionFromTemplate(template));
    }
  }

  void _preview(PageSection section) {
    showPageSectionPreview(context, section);
  }

  void _selectSection(PageSection section) {
    setState(() => _selectedSectionId = pageSectionIdentity(section));
  }

  void _duplicate(PageSection section) {
    _openForm(duplicateSection(section));
  }

  Future<void> _togglePublished(PageSection section) async {
    await _saveMany([section.copyWith(isPublished: !section.isPublished)]);
  }

  Future<void> _saveSection(PageSection section) async {
    final sections = ref.read(pageSectionsProvider).value ?? const [];
    final original = selectedPageSection(
      sections,
      pageSectionIdentity(section),
    );
    final displayOrder =
        original != null && original.placement != section.placement
        ? nextPageSectionDisplayOrder(sections, section.placement)
        : section.displayOrder;
    await _saveMany([section.copyWith(displayOrder: displayOrder)]);
    setState(() => _selectedSectionId = pageSectionIdentity(section));
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

  Future<void> _saveMany(List<PageSection> sections) async {
    if (sections.isEmpty) {
      return;
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
    } on AppException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Section update failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteSection(PageSection section) async {
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
    setState(() => _isSaving = true);
    try {
      await ref.read(pageSectionRepositoryProvider).deleteSection(section.id!);
      ref.invalidate(pageSectionsProvider);
      if (_selectedSectionId == pageSectionIdentity(section)) {
        _selectedSectionId = null;
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

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
