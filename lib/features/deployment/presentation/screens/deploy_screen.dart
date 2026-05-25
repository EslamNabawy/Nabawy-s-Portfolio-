import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../../settings/domain/entities/publish_log.dart';
import '../../application/deployment_providers.dart';
import '../../domain/entities/deployment_result.dart';

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
              if (_progress != null) _ProgressPanel(progress: _progress!),
              if (_result != null) _ResultPanel(result: _result!),
              if (_error != null) _ErrorPanel(message: _error!),
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

    PublishLog? log;
    final publishLogs = ref.read(publishLogRepositoryProvider);
    final session = ref.read(authSessionProvider).value;

    try {
      log = await publishLogs.createLog(
        PublishLog(
          status: PublishStatus.pending,
          message: 'Deployment requested from dashboard.',
          triggeredBy: session?.userId,
        ),
      );
      ref.invalidate(publishLogsProvider);

      final result = await ref
          .read(deploymentRepositoryProvider)
          .triggerDeploy(onProgress: _setProgress);
      await _completeLog(log, result);
      if (!mounted) {
        return;
      }
      setState(() => _result = result);
    } on AppException catch (error) {
      await _failLog(log, error.message);
      _setError(error.message);
    } catch (_) {
      const message =
          'Deployment failed. Check GitHub CLI authentication and retry.';
      await _failLog(log, message);
      _setError(message);
    } finally {
      if (mounted) {
        setState(() => _isDeploying = false);
      }
    }
  }

  Future<void> _completeLog(PublishLog log, DeploymentResult result) async {
    final status = result.isSuccess
        ? PublishStatus.success
        : PublishStatus.failed;
    await ref
        .read(publishLogRepositoryProvider)
        .updateLog(
          log.copyWith(
            status: status,
            message: result.message,
            workflowRunUrl: result.runUrl,
          ),
        );
    ref.invalidate(publishLogsProvider);
  }

  Future<void> _failLog(PublishLog? log, String message) async {
    if (log == null) {
      return;
    }
    try {
      await ref
          .read(publishLogRepositoryProvider)
          .updateLog(
            log.copyWith(status: PublishStatus.failed, message: message),
          );
      ref.invalidate(publishLogsProvider);
    } catch (_) {
      // The primary deployment failure is more useful to show than a log update failure.
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

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.progress});

  final DeploymentProgress progress;

  @override
  Widget build(BuildContext context) {
    return _StatusPanel(
      color: const Color(0xFFDBEAFE),
      foreground: const Color(0xFF1D4ED8),
      title: 'Deployment status: ${progress.status}',
      body: _body,
    );
  }

  String get _body {
    final run = progress.runUrl == null ? '' : '\nRun: ${progress.runUrl}';
    return '${progress.message}$run';
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result});

  final DeploymentResult result;

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;
    return _StatusPanel(
      color: success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
      foreground: success ? const Color(0xFF166534) : const Color(0xFF991B1B),
      title: result.message,
      body: result.runUrl == null
          ? 'Open GitHub Actions to inspect the deployment.'
          : 'Run: ${result.runUrl}',
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _StatusPanel(
      color: const Color(0xFFFEE2E2),
      foreground: const Color(0xFF991B1B),
      title: 'Deployment failed',
      body: message,
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.color,
    required this.foreground,
    required this.title,
    required this.body,
  });

  final Color color;
  final Color foreground;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(body, style: TextStyle(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
