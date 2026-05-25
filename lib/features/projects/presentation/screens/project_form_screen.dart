import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/project.dart';
import '../../domain/value_objects/project_image_upload.dart';
import 'project_form_body.dart';
import 'project_form_controllers.dart';
import 'project_form_projection.dart';
import 'project_form_support.dart';
import 'project_publish_readiness.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.project});

  final Project? project;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProjectFormControllers _controllers;
  late String _initialStateKey;
  bool _isPublished = false;
  bool _featured = false;
  bool _hasUnsavedChanges = false;
  bool _isUploadingImage = false;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _controllers = ProjectFormControllers.fromProject(project);
    _isPublished = project?.isPublished ?? false;
    _featured = project?.featured ?? false;
    _initialStateKey = _currentStateKey();
    for (final controller in _controllers.all) {
      controller.addListener(_onFormChanged);
    }
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_isSaving && !_isUploadingImage;
    final c = _controllers;
    return PopScope(
      canPop: !_hasUnsavedChanges && !_isSaving,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Project' : 'New Project'),
          actions: [
            if (_hasUnsavedChanges)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: Text('Unsaved changes')),
              ),
          ],
        ),
        body: ProjectFormBody(
          formKey: _formKey,
          controllers: c,
          error: _error,
          isUploadingImage: _isUploadingImage,
          isSaving: _isSaving,
          canSubmit: canSubmit,
          hasUnsavedChanges: _hasUnsavedChanges,
          isPublished: _isPublished,
          featured: _featured,
          submitLabel: _isEditing ? 'Save Changes' : 'Create Project',
          publishReadinessIssues: _publishReadinessIssues,
          galleryImageUrls: _galleryImageUrls,
          onTitleChanged: _syncSlug,
          onPickAndUpload: _pickAndUpload,
          imageValidator: _validateImageUrl,
          onRemoveGalleryImage: _removeGalleryImage,
          onPublishedChanged: _setPublished,
          onFeaturedChanged: _setFeatured,
          onCancel: _cancel,
          onSubmit: _save,
        ),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    setState(() {
      _isUploadingImage = true;
      _error = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'avif'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw const ValidationFailure('Could not read selected image bytes.');
      }
      final imageUrl = await ref
          .read(projectRepositoryProvider)
          .uploadProjectImage(
            ProjectImageUpload(
              bytes: Uint8List.fromList(bytes),
              fileName: file.name,
              contentType: contentTypeFor(file.extension),
            ),
          );
      _controllers.imageUrl.text = imageUrl;
    } on AppException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Image upload failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _save() async {
    if (_isUploadingImage) {
      _setError('Wait for image upload to finish before saving.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final blockers = _publishReadinessIssues
        .where((issue) => issue.severity == PublishIssueSeverity.blocker)
        .toList(growable: false);
    if (_isPublished && blockers.isNotEmpty) {
      _setError(
        'Fix publish blockers: ${blockers.map((issue) => issue.message).join(' ')}',
      );
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final project = projectFromControllerSet(
        existingProject: widget.project,
        controllers: _controllers,
        isPublished: _isPublished,
        featured: _featured,
      );
      final repository = ref.read(projectRepositoryProvider);
      if (_isEditing) {
        await repository.updateProject(project);
      } else {
        await repository.createProject(project);
      }
      ref.invalidate(projectsProvider);
      _initialStateKey = _currentStateKey();
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
        });
        Navigator.of(context).pop(true);
      }
    } on AppException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Save failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _syncSlug(String value) {
    if (_controllers.slug.text.trim().isNotEmpty || _isEditing) {
      return;
    }
    _controllers.slug.text = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  String? _validateImageUrl(String? value) {
    final url = value?.trim() ?? '';
    if (_isPublished && url.isEmpty) {
      return 'Published projects require an image.';
    }
    return validateImageUrl(value);
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
  }

  List<PublishReadinessIssue> get _publishReadinessIssues {
    return assessControllerPublishReadiness(_controllers);
  }

  List<String> get _galleryImageUrls {
    return galleryImageUrlsFromController(_controllers);
  }

  Future<void> _cancel() async {
    if (!_hasUnsavedChanges || await _confirmDiscardChanges()) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  Future<void> _handlePopInvoked(bool didPop, Object? result) async {
    if (didPop || !_hasUnsavedChanges || _isSaving) {
      return;
    }
    if (await _confirmDiscardChanges() && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved edits on this project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _removeGalleryImage(String imageUrl) {
    final remaining = _galleryImageUrls
        .where((url) => url != imageUrl)
        .toList(growable: false);
    _controllers.galleryImages.text = remaining.join('\n');
  }

  void _setPublished(bool value) {
    setState(() => _isPublished = value);
    _formKey.currentState?.validate();
    _onFormChanged();
  }

  void _setFeatured(bool value) {
    setState(() => _featured = value);
    _onFormChanged();
  }

  void _onFormChanged() {
    if (!mounted) {
      return;
    }
    setState(() => _hasUnsavedChanges = _currentStateKey() != _initialStateKey);
  }

  String _currentStateKey() {
    return _controllers.stateKey(
      isPublished: _isPublished,
      featured: _featured,
    );
  }
}
