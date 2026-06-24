import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../application/deployment_providers.dart';
import '../../domain/entities/deployment_result.dart';
import '../widgets/deployment_status_panels.dart';

class DeployScreen extends ConsumerStatefulWidget {
  const DeployScreen({super.key});

  @override
  ConsumerState<DeployScreen> createState() => _DeployScreenState();
}

class _DeployScreenState extends ConsumerState<DeployScreen> {
  bool _isDeploying = false;
  DeploymentProgress? _progress;
  DeploymentResult? _result;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Deploy', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Trigger GitHub Pages, watch the run, and write the result to publish_log.',
              ),
              const SizedBox(height: 24),
              _DeployPanel(isDeploying: _isDeploying, onDeploy: _triggerDeploy),
              const SizedBox(height: 16),
              if (_progress != null)
                DeploymentProgressPanel(progress: _progress!),
              if (_result != null) DeploymentResultPanel(result: _result!),
              if (_error != null) DeploymentErrorPanel(message: _error!),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerDeploy() async {
    setState(() {
      _isDeploying = true;
      _progress = const DeploymentProgress(
        message: 'Creating publish log entry...',
        status: 'pending',
      );
      _error = null;
      _result = null;
    });

    final session = ref.read(authSessionProvider).value;

    try {
      final result = await ref
          .read(deploymentCoordinatorProvider)
          .deploy(
            message: 'Deployment requested from dashboard.',
            triggeredBy: session?.userId,
            onProgress: _setProgress,
          );
      ref.invalidate(publishLogsProvider);
      if (!mounted) {
        return;
      }
      setState(() => _result = result);
    } on AppException catch (error) {
      ref.invalidate(publishLogsProvider);
      _setError(error.message);
    } catch (_) {
      const message =
          'Deployment failed. Check GitHub CLI authentication and retry.';
      ref.invalidate(publishLogsProvider);
      _setError(message);
    } finally {
      if (mounted) {
        setState(() => _isDeploying = false);
      }
    }
  }

  void _setProgress(DeploymentProgress progress) {
    if (mounted) {
      setState(() => _progress = progress);
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
  }
}

class _DeployPanel extends StatelessWidget {
  const _DeployPanel({required this.isDeploying, required this.onDeploy});

  final bool isDeploying;
  final VoidCallback onDeploy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Public site deployment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Requires GitHub CLI installed and authenticated with workflow permission on this machine.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isDeploying ? null : onDeploy,
              icon: isDeploying
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rocket_launch_outlined),
              label: Text(isDeploying ? 'Deploying...' : 'Deploy Site'),
            ),
          ],
        ),
      ),
    );
  }
}
