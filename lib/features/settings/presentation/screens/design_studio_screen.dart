import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/ui/admin_components.dart';
import '../../../deployment/presentation/controllers/cms_deployment_state.dart';
import '../../../deployment/presentation/widgets/deployment_automation_panel.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../application/settings_providers.dart';
import '../../domain/entities/site_config.dart';
import '../../domain/entities/site_theme_config.dart';
import '../../domain/entities/site_theme_preset.dart';
import 'design_studio_widgets.dart';

class DesignStudioScreen extends ConsumerWidget {
  const DesignStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configState = ref.watch(siteConfigProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: configState.when(
        data: (config) => DesignStudioForm(
          key: ValueKey(config.updatedAt?.toIso8601String() ?? config.id),
          config: config,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load design config: $error')),
      ),
    );
  }
}

class DesignStudioForm extends ConsumerStatefulWidget {
  const DesignStudioForm({super.key, required this.config});

  final SiteConfig config;

  @override
  ConsumerState<DesignStudioForm> createState() => _DesignStudioFormState();
}

class _DesignStudioFormState extends ConsumerState<DesignStudioForm>
    with CmsDeploymentState<DesignStudioForm> {
  late PublicDesignVariant _variant;
  late SiteThemeConfig _theme;
  bool _isSaving = false;
  bool _deployAfterSave = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _variant = widget.config.designVariant;
    _theme = widget.config.themeConfig;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Header(onRefresh: () => ref.invalidate(siteConfigProvider)),
        const SizedBox(height: 16),
        if (_error != null) ...[
          ErrorPanel(message: _error!),
          const SizedBox(height: 16),
        ],
        ResponsiveTwoPane(
          primary: Column(
            children: [
              AdminPanel(
                title: 'Design Presets',
                subtitle: 'Switch the public portfolio mood safely.',
                child: DesignPresetGrid(
                  selected: _variant,
                  onSelected: _applyPreset,
                ),
              ),
              const SizedBox(height: 16),
              AdminPanel(
                title: 'Theme Tokens',
                subtitle:
                    'Bounded controls rendered as CSS variables at build.',
                child: ThemeTokenControls(
                  theme: _theme,
                  onChanged: (theme) => setState(() => _theme = theme),
                ),
              ),
            ],
          ),
          secondary: Column(
            children: [
              AdminPanel(
                title: 'Preview',
                subtitle: 'Approximation of public surface tokens.',
                child: ThemePreview(variant: _variant, theme: _theme),
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
                onDeployAfterSaveChanged: (value) =>
                    setState(() => _deployAfterSave = value),
                onSaveAndDeploy: _saveAndDeploy,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommandButton(
                      label: 'Reset',
                      icon: Icons.restart_alt,
                      onPressed: _isSaving || isDeploying ? null : _reset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommandButton(
                      label: 'Save Design',
                      icon: Icons.save_outlined,
                      primary: true,
                      onPressed: _isSaving || isDeploying ? null : _saveOnly,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyPreset(SiteThemePreset preset) {
    setState(() {
      _variant = PublicDesignVariant.fromJson(preset.variantValue);
      _theme = preset.config;
    });
  }

  void _reset() {
    setState(() {
      _variant = widget.config.designVariant;
      _theme = widget.config.themeConfig;
      _error = null;
      clearDeploymentFeedback();
    });
  }

  Future<void> _saveOnly() => _save(deployAfterSave: _deployAfterSave);

  Future<void> _saveAndDeploy() => _save(deployAfterSave: true);

  Future<void> _save({required bool deployAfterSave}) async {
    setState(() {
      _isSaving = true;
      _error = null;
      clearDeploymentFeedback();
    });
    try {
      await ref
          .read(siteConfigRepositoryProvider)
          .updateGlobalConfig(
            widget.config.copyWith(
              designVariant: _variant,
              themeConfig: _theme,
            ),
          );
      ref.invalidate(siteConfigProvider);
      if (mounted && deployAfterSave) {
        setState(() => _isSaving = false);
        await runCmsDeployment(
          message: 'Deployment requested after design save.',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Design saved.')));
      }
    } on AppException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Design save failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
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
          child: Text(
            'Design Studio',
            style: Theme.of(context).textTheme.headlineSmall,
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
