import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../deployment/presentation/controllers/cms_deployment_state.dart';
import '../../../deployment/presentation/widgets/deployment_automation_panel.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../application/settings_providers.dart';
import '../../domain/entities/site_config.dart';

class SiteConfigScreen extends ConsumerWidget {
  const SiteConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configState = ref.watch(siteConfigProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: configState.when(
        data: (config) => SiteConfigForm(
          key: ValueKey(config.updatedAt?.toIso8601String() ?? config.id),
          config: config,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: 'Failed to load site config: $error',
          onRetry: () => ref.invalidate(siteConfigProvider),
        ),
      ),
    );
  }
}

class SiteConfigForm extends ConsumerStatefulWidget {
  const SiteConfigForm({super.key, required this.config});

  final SiteConfig config;

  @override
  ConsumerState<SiteConfigForm> createState() => _SiteConfigFormState();
}

class _SiteConfigFormState extends ConsumerState<SiteConfigForm>
    with CmsDeploymentState<SiteConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _headline;
  late final TextEditingController _bio;
  late final TextEditingController _resumeUrl;
  late final TextEditingController _githubUrl;
  late final TextEditingController _linkedinUrl;
  late final TextEditingController _email;
  bool _isSaving = false;
  bool _deployAfterSave = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    _name = TextEditingController(text: config.name);
    _headline = TextEditingController(text: config.headline);
    _bio = TextEditingController(text: config.bio);
    _resumeUrl = TextEditingController(text: config.resumeUrl ?? '');
    _githubUrl = TextEditingController(text: config.githubUrl ?? '');
    _linkedinUrl = TextEditingController(text: config.linkedinUrl ?? '');
    _email = TextEditingController(text: config.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _headline.dispose();
    _bio.dispose();
    _resumeUrl.dispose();
    _githubUrl.dispose();
    _linkedinUrl.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Site Config',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _isSaving || isDeploying
                    ? null
                    : () => ref.invalidate(siteConfigProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            ErrorPanel(message: _error!),
            const SizedBox(height: 16),
          ],
          ProjectFormSection(
            title: 'Profile',
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: requiredField('Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _headline,
                decoration: const InputDecoration(labelText: 'Headline'),
                validator: requiredField('Headline'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bio,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                ),
                validator: requiredField('Bio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProjectFormSection(
            title: 'Links',
            children: [
              TextFormField(
                controller: _resumeUrl,
                decoration: const InputDecoration(labelText: 'Resume URL'),
                validator: validateOptionalUrl,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _githubUrl,
                decoration: const InputDecoration(labelText: 'GitHub URL'),
                validator: validateOptionalUrl,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkedinUrl,
                decoration: const InputDecoration(labelText: 'LinkedIn URL'),
                validator: validateOptionalUrl,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateOptionalEmail,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DeploymentAutomationPanel(
            enabled: true,
            disabledReason: '',
            deployAfterSave: _deployAfterSave,
            isSaving: _isSaving,
            isDeploying: isDeploying,
            progress: deploymentProgress,
            result: deploymentResult,
            error: deploymentError,
            onDeployAfterSaveChanged: _setDeployAfterSave,
            onSaveAndDeploy: _saveAndDeploy,
          ),
          const SizedBox(height: 24),
          ProjectFormActions(
            isSaving: _isSaving,
            canSubmit: !_isSaving && !isDeploying,
            hasUnsavedChanges: false,
            submitLabel: 'Save Config',
            canCancel: !isDeploying,
            onCancel: () => ref.invalidate(siteConfigProvider),
            onSubmit: _saveOnly,
          ),
        ],
      ),
    );
  }

  Future<void> _saveOnly() async {
    await _save(deployAfterSave: _deployAfterSave);
  }

  Future<void> _saveAndDeploy() async {
    await _save(deployAfterSave: true);
  }

  Future<void> _save({required bool deployAfterSave}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
      clearDeploymentFeedback();
    });

    try {
      await ref
          .read(siteConfigRepositoryProvider)
          .updateGlobalConfig(
            SiteConfig(
              name: _name.text.trim(),
              headline: _headline.text.trim(),
              bio: _bio.text.trim(),
              resumeUrl: optionalText(_resumeUrl.text),
              githubUrl: optionalText(_githubUrl.text),
              linkedinUrl: optionalText(_linkedinUrl.text),
              email: optionalText(_email.text),
            ),
          );
      ref.invalidate(siteConfigProvider);
      if (mounted) {
        setState(() => _isSaving = false);
        if (deployAfterSave) {
          await _deploySavedConfig();
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Site config saved.')));
        }
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

  Future<void> _deploySavedConfig() async {
    await runCmsDeployment(
      message: 'Deployment requested after saving site config.',
    );
  }

  String? _validateOptionalEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
  }

  void _setDeployAfterSave(bool value) {
    setState(() => _deployAfterSave = value);
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
